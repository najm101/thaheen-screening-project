import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: FCircularProgress());
}

class StatusView extends StatelessWidget {
  const StatusView({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final accent = destructive ? colors.destructive : colors.mutedForeground;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: colors.muted, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(icon, size: 32, color: accent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.typography.body.lg.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
              ),
              if (message case final message?) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(color: colors.mutedForeground),
                ),
              ],
              if ((actionLabel, onAction) case (final label?, final onPress?)) ...[
                const SizedBox(height: 20),
                FButton(onPress: onPress, mainAxisSize: MainAxisSize.min, child: Text(label)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
