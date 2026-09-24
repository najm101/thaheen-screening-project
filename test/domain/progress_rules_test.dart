import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_lms/domain/models/course.dart';
import 'package:thaheen_lms/domain/models/lesson_progress.dart';
import 'package:thaheen_lms/domain/models/localized_text.dart';
import 'package:thaheen_lms/domain/progress_rules.dart';

void main() {
  group('isCompleted (90% rule)', () {
    const duration = Duration(seconds: 100);

    test('is not completed just below 90%', () {
      expect(ProgressRules.isCompleted(position: const Duration(milliseconds: 89999), duration: duration), isFalse);
    });

    test('is completed at exactly 90% and beyond', () {
      expect(ProgressRules.isCompleted(position: const Duration(seconds: 90), duration: duration), isTrue);
      expect(ProgressRules.isCompleted(position: duration, duration: duration), isTrue);
    });

    test('uses the real duration, including non-round clip lengths', () {
      const clip = Duration(milliseconds: 65440);
      expect(ProgressRules.isCompleted(position: const Duration(milliseconds: 58895), duration: clip), isFalse);
      expect(ProgressRules.isCompleted(position: const Duration(milliseconds: 58896), duration: clip), isTrue);
    });

    test('is never completed while the duration is unknown', () {
      expect(ProgressRules.isCompleted(position: const Duration(seconds: 5), duration: Duration.zero), isFalse);
    });
  });

  group('isUnlocked (sequential unlock)', () {
    final course = _course('anatomy', [
      _section('s1', ['l1', 'l2']),
      _section('s2', []),
      _section('s3', ['l3']),
    ]);

    test('the first lesson is always unlocked', () {
      expect(ProgressRules.isUnlocked(course, 'l1', const ProgressSnapshot.empty()), isTrue);
    });

    test('a lesson stays locked while the previous one is only in progress', () {
      final progress = ProgressSnapshot([_progress('anatomy', 'l1', position: const Duration(seconds: 80))]);
      expect(ProgressRules.isUnlocked(course, 'l2', progress), isFalse);
    });

    test('a lesson unlocks once the previous one is completed', () {
      final progress = ProgressSnapshot([_progress('anatomy', 'l1', completed: true)]);
      expect(ProgressRules.isUnlocked(course, 'l2', progress), isTrue);
    });

    test('the chain crosses sections and skips empty ones', () {
      final l2Done = ProgressSnapshot([
        _progress('anatomy', 'l1', completed: true),
        _progress('anatomy', 'l2', completed: true),
      ]);
      expect(ProgressRules.isUnlocked(course, 'l3', l2Done), isTrue);
      expect(
        ProgressRules.isUnlocked(course, 'l3', ProgressSnapshot([_progress('anatomy', 'l1', completed: true)])),
        isFalse,
      );
    });

    test('progress in another course with the same lesson id does not unlock', () {
      final progress = ProgressSnapshot([_progress('physiology', 'l1', completed: true)]);
      expect(ProgressRules.isUnlocked(course, 'l2', progress), isFalse);
    });

    test('an unknown lesson is never unlocked', () {
      expect(ProgressRules.isUnlocked(course, 'missing', const ProgressSnapshot.empty()), isFalse);
    });
  });

  group('courseProgress (progress %)', () {
    final course = _course('anatomy', [
      _section('s1', ['l1', 'l2']),
      _section('s2', ['l3', 'l4']),
    ]);

    test('is 0 with no progress', () {
      expect(ProgressRules.courseProgress(course, const ProgressSnapshot.empty()), 0);
    });

    test('counts completed lessons only, not in-progress ones', () {
      final progress = ProgressSnapshot([
        _progress('anatomy', 'l1', completed: true),
        _progress('anatomy', 'l2', position: const Duration(seconds: 50)),
      ]);
      expect(ProgressRules.courseProgress(course, progress), 0.25);
    });

    test('is 1 when every lesson is completed', () {
      final progress = ProgressSnapshot([
        for (final id in ['l1', 'l2', 'l3', 'l4']) _progress('anatomy', id, completed: true),
      ]);
      expect(ProgressRules.courseProgress(course, progress), 1);
    });

    test('ignores progress from other courses', () {
      final progress = ProgressSnapshot([_progress('physiology', 'l1', completed: true)]);
      expect(ProgressRules.courseProgress(course, progress), 0);
    });

    test('is 0 for a course with no lessons instead of dividing by zero', () {
      final empty = _course('empty', [_section('s1', [])]);
      expect(ProgressRules.courseProgress(empty, const ProgressSnapshot.empty()), 0);
    });
  });
}

LocalizedText _text(String value) => LocalizedText(ar: value, en: value);

Course _course(String id, List<CourseSection> sections) => Course(
  id: id,
  title: _text(id),
  instructor: _text('instructor'),
  thumbnail: 'assets/images/$id.jpg',
  sections: sections,
);

CourseSection _section(String id, List<String> lessonIds) => CourseSection(
  id: id,
  title: _text(id),
  lessons: [
    for (final lessonId in lessonIds)
      Lesson(
        id: lessonId,
        title: _text(lessonId),
        duration: const Duration(seconds: 100),
        video: 'assets/videos/$lessonId.mp4',
      ),
  ],
);

LessonProgress _progress(
  String courseId,
  String lessonId, {
  Duration position = Duration.zero,
  bool completed = false,
}) => LessonProgress(
  courseId: courseId,
  lessonId: lessonId,
  position: position,
  duration: const Duration(seconds: 100),
  completed: completed,
  updatedAt: DateTime(2026),
);
