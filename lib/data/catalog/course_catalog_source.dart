import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../../domain/models/course.dart';
import '../../domain/models/localized_text.dart';

final class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;

  @override
  String toString() => 'CatalogException: $message';
}

final class CourseCatalogSource {
  CourseCatalogSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/courses.json';

  final AssetBundle _bundle;

  Future<List<Course>> load() async {
    final String raw;
    try {
      raw = await _bundle.loadString(assetPath, cache: false);
    } on Object catch (error) {
      throw CatalogException('Unable to read $assetPath: $error');
    }
    return parse(raw);
  }

  /// A malformed file fails as a whole; a single malformed course is skipped
  /// so one bad entry can't take the whole catalog down.
  static List<Course> parse(String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException catch (error) {
      throw CatalogException('Invalid JSON: ${error.message}');
    }
    if (json case {'courses': final List<Object?> items}) {
      final courses = <Course>[];
      final seenIds = <String>{};
      for (final item in items) {
        try {
          final course = _course(item);
          if (!seenIds.add(course.id)) throw FormatException('Duplicate course id "${course.id}"');
          courses.add(course);
        } on FormatException catch (error) {
          log('Skipping course: ${error.message}', name: 'catalog');
        }
      }
      return courses;
    }
    throw const CatalogException('Expected an object with a "courses" list');
  }

  static Course _course(Object? json) {
    if (json case {
      'id': final String id,
      'title': final Object? title,
      'instructor': final Object? instructor,
      'thumbnail': final String thumbnail,
      'sections': final List<Object?> sections,
    }) {
      final course = Course(
        id: id,
        title: _text(title),
        instructor: _text(instructor),
        thumbnail: thumbnail,
        sections: [for (final section in sections) _section(section)],
      );
      final lessonIds = course.lessons.map((lesson) => lesson.id);
      if (lessonIds.toSet().length != lessonIds.length) {
        throw FormatException('Duplicate lesson ids in course "$id"');
      }
      return course;
    }
    throw FormatException('Malformed course: $json');
  }

  static CourseSection _section(Object? json) {
    if (json case {'id': final String id, 'title': final Object? title, 'lessons': final List<Object?> lessons}) {
      return CourseSection(id: id, title: _text(title), lessons: [for (final lesson in lessons) _lesson(lesson)]);
    }
    throw FormatException('Malformed section: $json');
  }

  static Lesson _lesson(Object? json) {
    if (json
        case {
          'id': final String id,
          'title': final Object? title,
          'durationSec': final int seconds,
          'video': final String video,
        }
        when seconds >= 0) {
      return Lesson(
        id: id,
        title: _text(title),
        duration: Duration(seconds: seconds),
        video: video,
      );
    }
    throw FormatException('Malformed lesson: $json');
  }

  static LocalizedText _text(Object? json) => switch (json) {
    {'ar': final String ar, 'en': final String en} => LocalizedText(ar: ar, en: en),
    final String value => LocalizedText(ar: value, en: value),
    _ => throw FormatException('Malformed text: $json'),
  };
}
