import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../core/formatting.dart';
import '../../../domain/progress_rules.dart';
import '../../shared/course_thumbnail.dart';
import '../../shared/rtl_mirrored_icon.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({required this.item, required this.onPress, super.key});

  final ContinueWatching item;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final typography = theme.typography.body;
    final progress = item.progress;

    return FTappable(
      onPress: onPress,
      semanticsLabel: '${context.l10n.continueWatching}: ${context.localized(item.lesson.title)}',
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CourseThumbnail(asset: item.course.thumbnail, borderRadius: theme.style.borderRadius.md),
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: RtlMirroredIcon(FLucideIcons.play, size: 16, color: colors.primaryForeground),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.continueWatching, style: typography.xs.copyWith(color: colors.mutedForeground)),
                    const SizedBox(height: 4),
                    Text(
                      context.localized(item.lesson.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.md.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.localized(item.course.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.sm.copyWith(color: colors.mutedForeground),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: FDeterminateProgress(value: progress.watchedFraction)),
                        const SizedBox(width: 8),
                        Text(
                          formatDuration(progress.position, context.localeName),
                          style: typography.xs.copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
