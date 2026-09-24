import 'models/course.dart';
import 'models/lesson_progress.dart';
import 'models/lesson_status.dart';

typedef ContinueWatching = ({Course course, Lesson lesson, LessonProgress progress});

abstract final class ProgressRules {
  static const completionThreshold = 0.9;
  static const restartWindow = Duration(seconds: 3);

  static bool isCompleted({required Duration position, required Duration duration}) {
    if (duration <= Duration.zero) return false;
    return position.inMilliseconds >= duration.inMilliseconds * completionThreshold;
  }

  static bool isUnlocked(Course course, String lessonId, ProgressSnapshot progress) {
    final lessons = course.lessons;
    final index = lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index < 0) return false;
    if (index == 0) return true;
    return progress.isCompleted(course.id, lessons[index - 1].id);
  }

  static LessonStatus statusOf(Course course, String lessonId, ProgressSnapshot progress) {
    final entry = progress.of(course.id, lessonId);
    if (entry?.completed ?? false) return LessonStatus.completed;
    if (!isUnlocked(course, lessonId, progress)) return LessonStatus.locked;
    if (entry?.isInProgress ?? false) return LessonStatus.inProgress;
    return LessonStatus.notStarted;
  }

  static double courseProgress(Course course, ProgressSnapshot progress) {
    final lessons = course.lessons;
    if (lessons.isEmpty) return 0;
    final completed = lessons.where((lesson) => progress.isCompleted(course.id, lesson.id)).length;
    return completed / lessons.length;
  }

  static Lesson? nextLesson(Course course, String lessonId) {
    final lessons = course.lessons;
    final index = lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index < 0 || index + 1 >= lessons.length) return null;
    return lessons[index + 1];
  }

  static ContinueWatching? continueWatching(List<Course> courses, ProgressSnapshot progress) {
    final coursesById = {for (final course in courses) course.id: course};
    final candidates = progress.entries.where((entry) => entry.isInProgress).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    for (final entry in candidates) {
      final course = coursesById[entry.courseId];
      final lesson = course?.lessonById(entry.lessonId);
      if (course != null && lesson != null) return (course: course, lesson: lesson, progress: entry);
    }
    return null;
  }

  static Duration resumePosition(Duration position, Duration duration) {
    if (position <= Duration.zero || duration <= Duration.zero) return Duration.zero;
    if (duration - position <= restartWindow) return Duration.zero;
    return position;
  }
}
