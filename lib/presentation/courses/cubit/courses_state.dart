part of 'courses_cubit.dart';

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

final class CoursesFailure extends CoursesState {
  const CoursesFailure();
}

final class CoursesEmpty extends CoursesState {
  const CoursesEmpty();
}

final class CoursesLoaded extends CoursesState {
  const CoursesLoaded({required this.courses, required this.progress, this.query = ''});

  final List<Course> courses;
  final ProgressSnapshot progress;
  final String query;

  List<Course> get visibleCourses => CourseSearch.filter(courses, query);

  ContinueWatching? get continueWatching => ProgressRules.continueWatching(courses, progress);

  double progressOf(Course course) => ProgressRules.courseProgress(course, progress);

  CoursesLoaded copyWith({ProgressSnapshot? progress, String? query}) =>
      CoursesLoaded(courses: courses, progress: progress ?? this.progress, query: query ?? this.query);

  @override
  List<Object?> get props => [courses, progress, query];
}
