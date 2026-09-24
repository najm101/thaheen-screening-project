import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../core/context_extensions.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../domain/progress_rules.dart';
import '../presentation/course_details/course_details.dart';
import '../presentation/courses/courses.dart';
import '../presentation/player/player.dart';
import '../presentation/shared/status_view.dart';
import 'routes.dart';

GoRouter createRouter({required CourseRepository courses, required ProgressRepository progress}) {
  Future<String?> guardLesson(BuildContext _, GoRouterState state) async {
    final courseId = state.pathParameters['courseId']!;
    final lessonId = state.pathParameters['lessonId']!;
    try {
      final course = await courses.courseById(courseId);
      if (course == null || course.lessonById(lessonId) == null) return null;
      final snapshot = await progress.snapshot();
      return ProgressRules.isUnlocked(course, lessonId, snapshot) ? null : AppRoutes.course(courseId);
    } on Object {
      return null;
    }
  }

  return GoRouter(
    initialLocation: AppRoutes.courses,
    errorPageBuilder: (context, state) => _page(state, const _NotFoundScreen()),
    routes: [
      GoRoute(
        path: AppRoutes.courses,
        pageBuilder: (context, state) => _page(
          state,
          BlocProvider(
            create: (context) => CoursesCubit(context.read(), context.read())..load(),
            child: const CoursesScreen(),
          ),
        ),
        routes: [
          GoRoute(
            path: 'courses/:courseId',
            pageBuilder: (context, state) => _page(
              state,
              BlocProvider(
                create: (context) =>
                    CourseDetailsCubit(context.read(), context.read(), courseId: state.pathParameters['courseId']!)
                      ..load(),
                child: const CourseDetailsScreen(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'lessons/:lessonId',
                redirect: guardLesson,
                pageBuilder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  final lessonId = state.pathParameters['lessonId']!;
                  return _page(
                    state,
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => PlayerCubit(
                            courses: context.read(),
                            progress: context.read(),
                            settings: context.read(),
                            courseId: courseId,
                            lessonId: lessonId,
                          )..load(),
                        ),
                        BlocProvider(
                          create: (context) =>
                              NotesCubit(context.read(), courseId: courseId, lessonId: lessonId)..load(),
                        ),
                      ],
                      child: const PlayerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// go_router's default page key is the route pattern, so moving between two
/// lessons would reuse one page and its cubits. Keying by the concrete location
/// gives every lesson its own page, cubits and video player.
Page<void> _page(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: ValueKey<String>(state.matchedLocation),
  child: child,
  transitionDuration: const Duration(milliseconds: 250),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  transitionsBuilder: (context, animation, _, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final direction = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: Offset(0.08 * direction, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  },
);

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) => FScaffold(
    child: StatusView(
      icon: FLucideIcons.searchX,
      title: context.l10n.pageNotFoundTitle,
      actionLabel: context.l10n.goHome,
      onAction: () => context.go(AppRoutes.courses),
    ),
  );
}
