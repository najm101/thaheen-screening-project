part of 'course_details_cubit.dart';

sealed class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

final class CourseDetailsFailure extends CourseDetailsState {
  const CourseDetailsFailure();
}

final class CourseDetailsNotFound extends CourseDetailsState {
  const CourseDetailsNotFound();
}

final class CourseDetailsLoaded extends CourseDetailsState {
  const CourseDetailsLoaded({required this.course, required this.progress});

  final Course course;
  final ProgressSnapshot progress;

  double get courseProgress => ProgressRules.courseProgress(course, progress);

  LessonStatus statusOf(Lesson lesson) => ProgressRules.statusOf(course, lesson.id, progress);

  double watchedFraction(Lesson lesson) => progress.of(course.id, lesson.id)?.watchedFraction ?? 0;

  @override
  List<Object?> get props => [course, progress];
}
