part of 'player_cubit.dart';

enum PlayerFailureReason { loadFailed, lessonNotFound, lessonLocked, videoUnavailable }

sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

final class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

final class PlayerFailure extends PlayerState {
  const PlayerFailure(this.reason, {this.course, this.lesson});

  final PlayerFailureReason reason;
  final Course? course;
  final Lesson? lesson;

  @override
  List<Object?> get props => [reason, course, lesson];
}

final class PlayerReady extends PlayerState {
  const PlayerReady({
    required this.playback,
    required this.course,
    required this.lesson,
    required this.position,
    required this.duration,
    required this.speed,
    required this.completed,
    this.isPlaying = false,
    this.isBuffering = false,
    this.resumedFrom = Duration.zero,
  });

  final LessonPlayback playback;
  final Course course;
  final Lesson lesson;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool completed;
  final bool isPlaying;
  final bool isBuffering;
  final Duration resumedFrom;

  Lesson? get nextLesson => ProgressRules.nextLesson(course, lesson.id);

  bool get isNextUnlocked => completed && nextLesson != null;

  PlayerReady copyWith({
    Duration? position,
    Duration? duration,
    double? speed,
    bool? completed,
    bool? isPlaying,
    bool? isBuffering,
  }) => PlayerReady(
    playback: playback,
    course: course,
    lesson: lesson,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    speed: speed ?? this.speed,
    completed: completed ?? this.completed,
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
    resumedFrom: resumedFrom,
  );

  @override
  List<Object?> get props => [
    playback,
    course,
    lesson,
    position,
    duration,
    speed,
    completed,
    isPlaying,
    isBuffering,
    resumedFrom,
  ];
}
