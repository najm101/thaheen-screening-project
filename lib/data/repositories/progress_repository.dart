import 'package:drift/drift.dart';

import '../../domain/models/lesson_progress.dart';
import '../db/app_database.dart';

final class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  Stream<ProgressSnapshot> watchAll() =>
      _db.select(_db.lessonProgressEntries).watch().map((rows) => ProgressSnapshot(rows.map(_toDomain)));

  Future<ProgressSnapshot> snapshot() async =>
      ProgressSnapshot((await _db.select(_db.lessonProgressEntries).get()).map(_toDomain));

  Future<LessonProgress?> find(String courseId, String lessonId) async {
    final row = await (_db.select(
      _db.lessonProgressEntries,
    )..where((t) => t.courseId.equals(courseId) & t.lessonId.equals(lessonId))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Completion is sticky: once a lesson is completed, later saves can't undo it.
  Future<LessonProgress> save({
    required String courseId,
    required String lessonId,
    required Duration position,
    required Duration? duration,
    bool completed = false,
  }) => _db.transaction(() async {
    final existing = await find(courseId, lessonId);
    final progress = LessonProgress(
      courseId: courseId,
      lessonId: lessonId,
      position: position,
      duration: duration ?? existing?.duration,
      completed: completed || (existing?.completed ?? false),
      updatedAt: DateTime.now(),
    );
    await _db
        .into(_db.lessonProgressEntries)
        .insertOnConflictUpdate(
          LessonProgressEntriesCompanion.insert(
            courseId: courseId,
            lessonId: lessonId,
            positionMs: Value(progress.position.inMilliseconds),
            durationMs: Value(progress.duration?.inMilliseconds),
            completed: Value(progress.completed),
            updatedAt: progress.updatedAt,
          ),
        );
    return progress;
  });

  static LessonProgress _toDomain(LessonProgressRow row) => LessonProgress(
    courseId: row.courseId,
    lessonId: row.lessonId,
    position: Duration(milliseconds: row.positionMs),
    duration: row.durationMs == null ? null : Duration(milliseconds: row.durationMs!),
    completed: row.completed,
    updatedAt: row.updatedAt,
  );
}
