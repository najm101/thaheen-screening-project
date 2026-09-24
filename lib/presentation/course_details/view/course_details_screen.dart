import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/context_extensions.dart';
import '../../../domain/models/course.dart';
import '../../../domain/models/lesson_status.dart';
import '../../shared/course_thumbnail.dart';
import '../../shared/status_view.dart';
import '../../shared/toasts.dart';
import '../cubit/course_details_cubit.dart';
import '../widgets/lesson_tile.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) => FScaffold(
        header: FHeader.nested(
          title: Text(
            switch (state) {
              CourseDetailsLoaded(:final course) => context.localized(course.title),
              _ => '',
            },
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          prefixes: [FHeaderAction.back(onPress: () => _back(context))],
        ),
        child: switch (state) {
          CourseDetailsLoading() => const LoadingView(),
          CourseDetailsFailure() => StatusView(
            icon: FLucideIcons.circleAlert,
            title: l10n.loadErrorTitle,
            message: l10n.loadErrorBody,
            actionLabel: l10n.retry,
            onAction: context.read<CourseDetailsCubit>().load,
            destructive: true,
          ),
          CourseDetailsNotFound() => StatusView(
            icon: FLucideIcons.fileX,
            title: l10n.courseNotFoundTitle,
            message: l10n.courseNotFoundBody,
            actionLabel: l10n.goHome,
            onAction: () => context.go(AppRoutes.courses),
          ),
          final CourseDetailsLoaded loaded => _CourseContent(state: loaded),
        },
      ),
    );
  }

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(AppRoutes.courses);
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.state});

  final CourseDetailsLoaded state;

  @override
  Widget build(BuildContext context) {
    final course = state.course;
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
      children: [
        _CourseHeader(course: course, progress: state.courseProgress),
        const SizedBox(height: 16),
        if (course.lessons.isEmpty)
          StatusView(icon: FLucideIcons.inbox, title: l10n.emptyCourseTitle, message: l10n.emptyCourseBody)
        else
          FAccordion(
            children: [
              for (final section in course.sections)
                FAccordionItem(
                  initiallyExpanded: true,
                  title: Text('${context.localized(section.title)} · ${l10n.lessonCount(section.lessons.length)}'),
                  child: section.lessons.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(l10n.emptySection, style: TextStyle(color: context.theme.colors.mutedForeground)),
                        )
                      : FTileGroup(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final lesson in section.lessons)
                              LessonTile(
                                lesson: lesson,
                                status: state.statusOf(lesson),
                                watchedFraction: state.watchedFraction(lesson),
                                onPress: () => _openLesson(context, course, lesson),
                              ),
                          ],
                        ),
                ),
            ],
          ),
      ],
    );
  }

  void _openLesson(BuildContext context, Course course, Lesson lesson) {
    if (state.statusOf(lesson) == LessonStatus.locked) return showLockedLessonToast(context);
    context.go(AppRoutes.lesson(course.id, lesson.id));
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course, required this.progress});

  final Course course;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography.body;
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CourseThumbnail(asset: course.thumbnail, borderRadius: theme.style.borderRadius.lg),
        ),
        const SizedBox(height: 16),
        Text(
          context.localized(course.title),
          style: typography.xl.copyWith(color: colors.foreground, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(context.localized(course.instructor), style: typography.sm.copyWith(color: colors.mutedForeground)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              context.l10n.lessonCount(course.lessons.length),
              style: typography.sm.copyWith(color: colors.mutedForeground),
            ),
            const Spacer(),
            Text(
              context.l10n.percentComplete(percent),
              style: typography.sm.copyWith(color: colors.foreground, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FDeterminateProgress(value: progress),
      ],
    );
  }
}
