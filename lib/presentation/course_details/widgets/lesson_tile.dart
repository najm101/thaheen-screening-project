import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../core/formatting.dart';
import '../../../domain/models/course.dart';
import '../../../domain/models/lesson_status.dart';
import '../../shared/rtl_mirrored_icon.dart';

class LessonTile extends StatelessWidget with FTileMixin {
  const LessonTile({
    required this.lesson,
    required this.status,
    required this.watchedFraction,
    required this.onPress,
    super.key,
  });

  final Lesson lesson;
  final LessonStatus status;
  final double watchedFraction;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = context.l10n;
    final locked = status == LessonStatus.locked;

    final (IconData icon, Color color, String label) = switch (status) {
      LessonStatus.locked => (FLucideIcons.lock, colors.mutedForeground, l10n.statusLocked),
      LessonStatus.notStarted => (FLucideIcons.circlePlay, colors.foreground, l10n.statusNotStarted),
      LessonStatus.inProgress => (FLucideIcons.circleDashed, colors.primary, l10n.statusInProgress),
      LessonStatus.completed => (FLucideIcons.circleCheck, colors.primary, l10n.statusCompleted),
    };

    return FTile(
      prefix: status == LessonStatus.notStarted ? RtlMirroredIcon(icon, color: color) : Icon(icon, color: color),
      title: Text(context.localized(lesson.title), style: locked ? TextStyle(color: colors.mutedForeground) : null),
      subtitle: Text(
        status == LessonStatus.inProgress ? l10n.lessonInProgress((watchedFraction * 100).round()) : label,
      ),
      details: Text(formatDuration(lesson.duration, context.localeName)),
      suffix: locked ? null : const Icon(FLucideIcons.chevronRight, size: 16),
      onPress: onPress,
    );
  }
}
