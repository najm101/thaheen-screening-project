import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/course_search.dart';
import '../../../domain/models/course.dart';
import '../../../domain/models/lesson_progress.dart';
import '../../../domain/progress_rules.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._courses, this._progress) : super(const CoursesLoading());

  final CourseRepository _courses;
  final ProgressRepository _progress;
  StreamSubscription<ProgressSnapshot>? _subscription;

  Future<void> load() async {
    await _subscription?.cancel();
    emit(const CoursesLoading());

    final List<Course> courses;
    try {
      courses = await _courses.courses();
    } on Object {
      if (!isClosed) emit(const CoursesFailure());
      return;
    }
    if (isClosed) return;
    if (courses.isEmpty) return emit(const CoursesEmpty());

    _subscription = _progress.watchAll().listen(
      (progress) => emit(switch (state) {
        final CoursesLoaded loaded => loaded.copyWith(progress: progress),
        _ => CoursesLoaded(courses: courses, progress: progress),
      }),
      onError: (Object _) => emit(const CoursesFailure()),
    );
  }

  void search(String query) {
    if (state case final CoursesLoaded loaded) emit(loaded.copyWith(query: query));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
