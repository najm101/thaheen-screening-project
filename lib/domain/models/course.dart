import 'package:equatable/equatable.dart';

import 'localized_text.dart';

final class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText instructor;
  final String thumbnail;
  final List<CourseSection> sections;

  List<Lesson> get lessons => [for (final section in sections) ...section.lessons];

  Lesson? lessonById(String lessonId) {
    for (final lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }

  @override
  List<Object> get props => [id, title, instructor, thumbnail, sections];
}

final class CourseSection extends Equatable {
  const CourseSection({required this.id, required this.title, required this.lessons});

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;

  @override
  List<Object> get props => [id, title, lessons];
}

final class Lesson extends Equatable {
  const Lesson({required this.id, required this.title, required this.duration, required this.video});

  final String id;
  final LocalizedText title;
  final Duration duration;
  final String video;

  @override
  List<Object> get props => [id, title, duration, video];
}
