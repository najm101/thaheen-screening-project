import 'package:drift/drift.dart';

import '../db/app_database.dart';

final class NotesRepository {
  NotesRepository(this._db);

  final AppDatabase _db;

  Future<String> load(String courseId, String lessonId) async {
    final row = await (_db.select(
      _db.lessonNotes,
    )..where((t) => t.courseId.equals(courseId) & t.lessonId.equals(lessonId))).getSingleOrNull();
    return row?.body ?? '';
  }

  Future<void> save(String courseId, String lessonId, String body) async {
    if (body.trim().isEmpty) {
      await (_db.delete(_db.lessonNotes)..where((t) => t.courseId.equals(courseId) & t.lessonId.equals(lessonId))).go();
      return;
    }
    await _db
        .into(_db.lessonNotes)
        .insertOnConflictUpdate(
          LessonNotesCompanion.insert(courseId: courseId, lessonId: lessonId, body: body, updatedAt: DateTime.now()),
        );
  }
}
