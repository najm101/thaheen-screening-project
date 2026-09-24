import 'models/course.dart';

abstract final class CourseSearch {
  static final _diacritics = RegExp('[ً-ٰٟـ]');
  static final _alef = RegExp('[آأإ]');

  static List<Course> filter(List<Course> courses, String query) {
    final needle = normalize(query);
    if (needle.isEmpty) return courses;
    return courses.where((course) {
      final haystack = [...course.title.values, ...course.instructor.values];
      return haystack.any((value) => normalize(value).contains(needle));
    }).toList();
  }

  /// Folds Arabic spelling variants (hamza forms, taa marbuta, alef maqsura, tashkeel)
  /// so "أساسيات" and "اساسيات" match.
  static String normalize(String input) => input
      .trim()
      .toLowerCase()
      .replaceAll(_diacritics, '')
      .replaceAll(_alef, 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
}
