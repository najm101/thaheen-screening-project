import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/models/course.dart';
import '../../../domain/models/lesson_progress.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../domain/progress_rules.dart';

part 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit(this._courses, this._progress, {required this.courseId}) : super(const CourseDetailsLoading());

  final String courseId;
  final CourseRepository _courses;
  final ProgressRepository _progress;
  StreamSubscription<ProgressSnapshot>? _subscription;

  Future<void> load() async {
    await _subscription?.cancel();
    emit(const CourseDetailsLoading());

    final Course? course;
    try {
      course = await _courses.courseById(courseId);
    } on Object {
      if (!isClosed) emit(const CourseDetailsFailure());
      return;
    }
    if (isClosed) return;
    if (course == null) return emit(const CourseDetailsNotFound());
    _watchProgress(course);
  }

  void _watchProgress(Course course) {
    _subscription = _progress.watchAll().listen(
      (progress) => emit(CourseDetailsLoaded(course: course, progress: progress)),
      onError: (Object _) => emit(const CourseDetailsFailure()),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
