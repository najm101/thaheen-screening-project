abstract final class AppRoutes {
  static const courses = '/';

  static String course(String courseId) => '/courses/${Uri.encodeComponent(courseId)}';

  static String lesson(String courseId, String lessonId) =>
      '${course(courseId)}/lessons/${Uri.encodeComponent(lessonId)}';
}
