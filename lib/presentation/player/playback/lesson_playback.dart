import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

final class PlaybackSnapshot extends Equatable {
  const PlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isCompleted = false,
    this.hasError = false,
  });

  factory PlaybackSnapshot.fromValue(VideoPlayerValue value) => PlaybackSnapshot(
    position: value.position,
    duration: value.duration,
    isPlaying: value.isPlaying,
    isBuffering: value.isBuffering,
    isCompleted: value.isCompleted,
    hasError: value.hasError,
  );

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;
  final bool hasError;

  @override
  List<Object> get props => [position, duration, isPlaying, isBuffering, isCompleted, hasError];
}

typedef LessonPlaybackFactory = LessonPlayback Function(String asset);

/// Owns one video for its whole life. Commands run one at a time, and after
/// [dispose] every command becomes a no-op, so callers never touch a dead player.
abstract interface class LessonPlayback {
  PlaybackSnapshot get snapshot;

  Stream<PlaybackSnapshot> get snapshots;

  /// Throws if the video can't be loaded.
  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Future<void> setSpeed(double speed);

  Future<void> dispose();
}

final class VideoLessonPlayback implements LessonPlayback {
  VideoLessonPlayback(this.asset);

  static const _initTimeout = Duration(seconds: 15);
  static const _commandTimeout = Duration(seconds: 5);

  final String asset;
  final _snapshots = StreamController<PlaybackSnapshot>.broadcast();

  VideoPlayerController? _controller;
  PlaybackSnapshot _snapshot = const PlaybackSnapshot();
  Future<void> _queue = Future.value();
  Future<void>? _disposal;

  bool get _disposed => _disposal != null;

  @override
  PlaybackSnapshot get snapshot => _snapshot;

  @override
  Stream<PlaybackSnapshot> get snapshots => _snapshots.stream;

  @override
  Future<void> initialize() => _serialized(() async {
    if (_disposed) return;
    final controller = VideoPlayerController.asset(asset);
    _controller = controller;
    controller.addListener(_publish);
    await controller.initialize().timeout(_initTimeout);
    _publish();
  });

  @override
  Future<void> play() => _command((controller) => controller.play());

  @override
  Future<void> pause() => _command((controller) => controller.pause());

  @override
  Future<void> seekTo(Duration position) => _command((controller) => controller.seekTo(position));

  @override
  Future<void> setSpeed(double speed) => _command((controller) => controller.setPlaybackSpeed(speed));

  @override
  Future<void> dispose() => _disposal ??= _serialized(() async {
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_publish);
    await controller?.dispose();
    await _snapshots.close();
  });

  void _publish() {
    final controller = _controller;
    if (controller == null) return;
    final next = PlaybackSnapshot.fromValue(controller.value);
    if (next == _snapshot) return;
    _snapshot = next;
    if (!_snapshots.isClosed) _snapshots.add(next);
  }

  Future<void> _command(Future<void> Function(VideoPlayerController controller) action) => _serialized(() async {
    final controller = _controller;
    if (_disposed || controller == null || !controller.value.isInitialized) return;
    try {
      await action(controller).timeout(_commandTimeout);
    } on Object catch (error) {
      log('Playback command failed: $error', name: 'player');
    }
  });

  /// Chains [operation] after everything already queued. The queue itself never
  /// fails, so one failed command can't block the ones after it.
  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}

class PlaybackView extends StatelessWidget {
  const PlaybackView({required this.playback, super.key});

  final LessonPlayback playback;

  @override
  Widget build(BuildContext context) {
    final controller = switch (playback) {
      VideoLessonPlayback(_controller: final controller?) when controller.value.isInitialized => controller,
      _ => null,
    };
    if (controller == null) return const SizedBox.expand();
    return AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));
  }
}
