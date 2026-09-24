import 'package:equatable/equatable.dart';

final class LessonProgress extends Equatable {
  const LessonProgress({
    required this.courseId,
    required this.lessonId,
    required this.position,
    required this.completed,
    required this.updatedAt,
    this.duration,
  });

  final String courseId;
  final String lessonId;
  final Duration position;
  final Duration? duration;
  final bool completed;
  final DateTime updatedAt;

  bool get isInProgress => !completed && position > Duration.zero;

  double get watchedFraction {
    final total = duration;
    if (completed) return 1;
    if (total == null || total <= Duration.zero) return 0;
    return (position.inMilliseconds / total.inMilliseconds).clamp(0, 1);
  }

  @override
  List<Object?> get props => [courseId, lessonId, position, duration, completed, updatedAt];
}

final class ProgressSnapshot extends Equatable {
  ProgressSnapshot(Iterable<LessonProgress> entries)
    : _entries = {for (final entry in entries) (entry.courseId, entry.lessonId): entry};

  const ProgressSnapshot.empty() : _entries = const {};

  final Map<(String, String), LessonProgress> _entries;

  Iterable<LessonProgress> get entries => _entries.values;

  LessonProgress? of(String courseId, String lessonId) => _entries[(courseId, lessonId)];

  bool isCompleted(String courseId, String lessonId) => of(courseId, lessonId)?.completed ?? false;

  @override
  List<Object> get props => [_entries];
}
