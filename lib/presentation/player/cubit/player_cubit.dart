import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/models/course.dart';
import '../../../domain/progress_rules.dart';
import '../playback/lesson_playback.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this._courses,
    required this._progress,
    required this._settings,
    required this.courseId,
    required this.lessonId,
    LessonPlaybackFactory? playbackFactory,
  }) : _playbackFactory = playbackFactory ?? VideoLessonPlayback.new,
       super(const PlayerLoading());

  static const speeds = [1.0, 1.25, 1.5, 2.0];
  static const _saveInterval = Duration(seconds: 5);

  final String courseId;
  final String lessonId;
  final CourseRepository _courses;
  final ProgressRepository _progress;
  final SettingsRepository _settings;
  final LessonPlaybackFactory _playbackFactory;

  LessonPlayback? _playback;
  StreamSubscription<PlaybackSnapshot>? _snapshots;
  bool _completed = false;
  bool _wasPlaying = false;
  DateTime _lastSavedAt = DateTime.now();

  Future<void> load() async {
    emit(const PlayerLoading());
    await _releasePlayback(save: false);

    final Course? course;
    final Lesson? lesson;
    final bool unlocked;
    final Duration savedPosition;
    final double speed;
    try {
      course = await _courses.courseById(courseId);
      lesson = course?.lessonById(lessonId);
      final snapshot = await _progress.snapshot();
      unlocked = course != null && ProgressRules.isUnlocked(course, lessonId, snapshot);
      final saved = snapshot.of(courseId, lessonId);
      _completed = saved?.completed ?? false;
      savedPosition = saved?.position ?? Duration.zero;
      final savedSpeed = await _settings.playbackSpeed();
      speed = speeds.contains(savedSpeed) ? savedSpeed! : 1.0;
    } on Object {
      if (!isClosed) emit(const PlayerFailure(PlayerFailureReason.loadFailed));
      return;
    }
    if (isClosed) return;
    if (course == null || lesson == null) return emit(const PlayerFailure(PlayerFailureReason.lessonNotFound));
    if (!unlocked) return emit(PlayerFailure(PlayerFailureReason.lessonLocked, course: course, lesson: lesson));

    final playback = _playbackFactory(lesson.video);
    _playback = playback;
    try {
      await playback.initialize();
      if (isClosed || _playback != playback) return;

      final duration = playback.snapshot.duration;
      final resumeAt = ProgressRules.resumePosition(savedPosition, duration);
      if (resumeAt > Duration.zero) await playback.seekTo(resumeAt);
      await playback.setSpeed(speed);
      if (isClosed || _playback != playback) return;

      emit(
        PlayerReady(
          playback: playback,
          course: course,
          lesson: lesson,
          position: resumeAt,
          duration: duration,
          speed: speed,
          completed: _completed,
          resumedFrom: resumeAt,
        ),
      );
      _snapshots = playback.snapshots.listen(_onSnapshot);
      await playback.play();
    } on Object {
      if (_playback == playback) await _releasePlayback(save: false);
      if (!isClosed) {
        emit(PlayerFailure(PlayerFailureReason.videoUnavailable, course: course, lesson: lesson));
      }
    }
  }

  Future<void> togglePlay() async {
    final playback = _playback;
    if (playback == null) return;
    if (playback.snapshot.isPlaying) return pause();
    if (playback.snapshot.isCompleted) await playback.seekTo(Duration.zero);
    await playback.play();
  }

  Future<void> pause() async {
    final playback = _playback;
    if (playback == null) return;
    await playback.pause();
    await _savePosition(playback);
  }

  Future<void> seekTo(Duration target) async {
    final playback = _playback;
    if (playback == null) return;
    await playback.seekTo(target);
    await _savePosition(playback);
  }

  Future<void> setSpeed(double speed) async {
    final playback = _playback;
    if (playback == null || !speeds.contains(speed)) return;
    await playback.setSpeed(speed);
    if (state case final PlayerReady current when !isClosed) emit(current.copyWith(speed: speed));
    try {
      await _settings.savePlaybackSpeed(speed);
    } on Object catch (error) {
      log('Saving playback speed failed: $error', name: 'player');
    }
  }

  void _onSnapshot(PlaybackSnapshot snapshot) {
    final playback = _playback;
    final current = state;
    if (isClosed || playback == null || current is! PlayerReady) return;

    if (snapshot.hasError) {
      unawaited(_failPlayback(current));
      return;
    }

    if (!_completed && ProgressRules.isCompleted(position: snapshot.position, duration: snapshot.duration)) {
      _completed = true;
      unawaited(_savePosition(playback));
    } else if (_wasPlaying && !snapshot.isPlaying) {
      unawaited(_savePosition(playback));
    } else if (snapshot.isPlaying && DateTime.now().difference(_lastSavedAt) >= _saveInterval) {
      unawaited(_savePosition(playback));
    }
    _wasPlaying = snapshot.isPlaying;

    emit(
      current.copyWith(
        position: snapshot.position,
        duration: snapshot.duration,
        isPlaying: snapshot.isPlaying,
        isBuffering: snapshot.isBuffering,
        completed: _completed,
      ),
    );
  }

  Future<void> _failPlayback(PlayerReady current) async {
    emit(PlayerFailure(PlayerFailureReason.videoUnavailable, course: current.course, lesson: current.lesson));
    await _releasePlayback(save: true);
  }

  Future<void> _savePosition(LessonPlayback playback) async {
    final snapshot = playback.snapshot;
    if (snapshot.duration <= Duration.zero) return;
    _lastSavedAt = DateTime.now();
    try {
      await _progress.save(
        courseId: courseId,
        lessonId: lessonId,
        position: snapshot.position,
        duration: snapshot.duration,
        completed: _completed,
      );
    } on Object catch (error) {
      log('Saving progress failed: $error', name: 'player');
    }
  }

  /// Teardown order matters: stop listening, pause, persist, then dispose.
  /// The playback waits for any in-flight command before disposing.
  Future<void> _releasePlayback({required bool save}) async {
    await _snapshots?.cancel();
    _snapshots = null;
    final playback = _playback;
    _playback = null;
    if (playback == null) return;
    if (save) {
      await playback.pause();
      await _savePosition(playback);
    }
    await playback.dispose();
  }

  @override
  Future<void> close() async {
    await _releasePlayback(save: true);
    return super.close();
  }
}
