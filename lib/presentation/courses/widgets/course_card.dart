import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../domain/models/course.dart';
import '../../shared/course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({required this.course, required this.progress, required this.onPress, super.key});

  final Course course;
  final double progress;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography.body;
    final radius = theme.style.borderRadius.lg;
    final percent = (progress * 100).round();

    return FTappable(
      onPress: onPress,
      semanticsLabel: context.localized(course.title),
      child: FCard(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CourseThumbnail(
                asset: course.thumbnail,
                borderRadius: BorderRadius.vertical(top: radius.topLeft),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localized(course.title),
                    style: typography.lg.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.localized(course.instructor),
                    style: typography.sm.copyWith(color: colors.mutedForeground),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(FLucideIcons.bookOpen, size: 16, color: colors.mutedForeground),
                      const SizedBox(width: 6),
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
                  FDeterminateProgress(value: progress, semanticsLabel: context.l10n.percentComplete(percent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
