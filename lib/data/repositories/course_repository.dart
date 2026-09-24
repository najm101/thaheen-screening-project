import '../../domain/models/course.dart';
import '../catalog/course_catalog_source.dart';

final class CourseRepository {
  CourseRepository(this._source);

  final CourseCatalogSource _source;
  Future<List<Course>>? _courses;

  Future<List<Course>> courses() => _courses ??= _load();

  Future<Course?> courseById(String id) async {
    for (final course in await courses()) {
      if (course.id == id) return course;
    }
    return null;
  }

  Future<List<Course>> _load() async {
    try {
      return await _source.load();
    } on Object {
      _courses = null;
      rethrow;
    }
  }
}
