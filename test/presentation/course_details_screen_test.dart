import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:thaheen_lms/core/app_theme.dart';
import 'package:thaheen_lms/domain/models/course.dart';
import 'package:thaheen_lms/domain/models/lesson_progress.dart';
import 'package:thaheen_lms/domain/models/localized_text.dart';
import 'package:thaheen_lms/l10n/app_localizations.dart';
import 'package:thaheen_lms/presentation/course_details/course_details.dart';

class _MockCourseDetailsCubit extends MockCubit<CourseDetailsState> implements CourseDetailsCubit {}

void main() {
  final l10n = lookupAppLocalizations(const Locale('ar', 'EG'));

  const bones = LocalizedText(ar: 'العظام', en: 'Bones');
  const joints = LocalizedText(ar: 'المفاصل', en: 'Joints');

  const course = Course(
    id: 'anatomy',
    title: LocalizedText(ar: 'مقدمة في التشريح', en: 'Introduction to Anatomy'),
    instructor: LocalizedText(ar: 'د. سارة', en: 'Dr. Sarah'),
    thumbnail: 'assets/images/missing.jpg',
    sections: [
      CourseSection(
        id: 's1',
        title: LocalizedText(ar: 'الجهاز الهيكلي', en: 'The Skeletal System'),
        lessons: [
          Lesson(id: 'l1', title: bones, duration: Duration(seconds: 100), video: 'assets/videos/lesson1.mp4'),
          Lesson(id: 'l2', title: joints, duration: Duration(seconds: 100), video: 'assets/videos/lesson2.mp4'),
        ],
      ),
    ],
  );

  final firstLessonInProgress = CourseDetailsLoaded(
    course: course,
    progress: ProgressSnapshot([
      LessonProgress(
        courseId: 'anatomy',
        lessonId: 'l1',
        position: const Duration(seconds: 40),
        duration: const Duration(seconds: 100),
        completed: false,
        updatedAt: DateTime(2026),
      ),
    ]),
  );

  Future<GoRouter> pumpCourseDetails(WidgetTester tester, CourseDetailsState state) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = _MockCourseDetailsCubit();
    whenListen(cubit, const Stream<CourseDetailsState>.empty(), initialState: state);

    final router = GoRouter(
      initialLocation: '/courses/anatomy',
      routes: [
        GoRoute(
          path: '/courses/:courseId',
          builder: (_, _) => BlocProvider<CourseDetailsCubit>.value(value: cubit, child: const CourseDetailsScreen()),
          routes: [
            GoRoute(
              path: 'lessons/:lessonId',
              builder: (_, state) => Text('lesson ${state.pathParameters['lessonId']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      WidgetsApp.router(
        routerConfig: router,
        color: const Color(0xFF000000),
        locale: const Locale('ar', 'EG'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [...AppLocalizations.localizationsDelegates, FLocalizations.delegate],
        builder: (_, child) => FTheme(
          data: AppTheme.light,
          child: FToaster(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('tapping a locked lesson shows the lock message and stays on the course', (tester) async {
    final router = await pumpCourseDetails(tester, firstLessonInProgress);

    expect(find.text('قيد المشاهدة · ٤٠٪'), findsOneWidget);
    expect(find.text(l10n.statusLocked), findsOneWidget);

    await tester.ensureVisible(find.text(joints.ar));
    await tester.tap(find.text(joints.ar));
    await tester.pumpAndSettle();

    expect(find.text(l10n.lockedLessonTitle), findsOneWidget);
    expect(find.text(l10n.lockedLessonBody), findsOneWidget);
    expect(router.state.matchedLocation, '/courses/anatomy');

    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('tapping an unlocked lesson opens it', (tester) async {
    final router = await pumpCourseDetails(tester, firstLessonInProgress);

    await tester.ensureVisible(find.text(bones.ar));
    await tester.tap(find.text(bones.ar));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/courses/anatomy/lessons/l1');
    expect(find.text('lesson l1'), findsOneWidget);
    expect(find.text(l10n.lockedLessonTitle), findsNothing);
  });
}
