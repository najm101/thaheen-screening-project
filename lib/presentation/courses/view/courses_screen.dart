import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/context_extensions.dart';
import '../../settings/widgets/settings_actions.dart';
import '../../shared/status_view.dart';
import '../cubit/courses_cubit.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FScaffold(
      header: FHeader(title: Text(l10n.coursesTitle), suffixes: const [LanguageAction(), ThemeModeAction()]),
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => switch (state) {
          CoursesLoading() => const LoadingView(),
          CoursesFailure() => StatusView(
            icon: FLucideIcons.circleAlert,
            title: l10n.loadErrorTitle,
            message: l10n.loadErrorBody,
            actionLabel: l10n.retry,
            onAction: context.read<CoursesCubit>().load,
            destructive: true,
          ),
          CoursesEmpty() => StatusView(
            icon: FLucideIcons.inbox,
            title: l10n.noCoursesTitle,
            message: l10n.noCoursesBody,
          ),
          final CoursesLoaded loaded => _CoursesList(state: loaded),
        },
      ),
    );
  }
}

class _CoursesList extends StatelessWidget {
  const _CoursesList({required this.state});

  final CoursesLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = state.visibleCourses;
    final continueWatching = state.query.isEmpty ? state.continueWatching : null;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          sliver: SliverToBoxAdapter(
            child: FTextField(
              hint: l10n.searchHint,
              textInputAction: TextInputAction.search,
              control: .managed(
                initial: TextEditingValue(text: state.query),
                onChange: (value) => context.read<CoursesCubit>().search(value.text),
              ),
              prefixBuilder: (context, style, _) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Icon(FLucideIcons.search, size: 18, color: context.theme.colors.mutedForeground),
              ),
            ),
          ),
        ),
        if (continueWatching case final item?)
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ContinueWatchingCard(
                item: item,
                onPress: () => context.go(AppRoutes.lesson(item.course.id, item.lesson.id)),
              ),
            ),
          ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: StatusView(
              icon: FLucideIcons.searchX,
              title: l10n.noResultsTitle,
              message: l10n.noResultsBody(state.query.trim()),
            ),
          )
        else
          SliverList.separated(
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final course = visible[index];
              return CourseCard(
                course: course,
                progress: state.progressOf(course),
                onPress: () => context.go(AppRoutes.course(course.id)),
              );
            },
          ),
        SliverToBoxAdapter(child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom)),
      ],
    );
  }
}
