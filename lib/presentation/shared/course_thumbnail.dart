import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({required this.asset, this.borderRadius = BorderRadius.zero, super.key});

  final String asset;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: colors.muted,
          child: Center(child: Icon(FLucideIcons.graduationCap, size: 32, color: colors.mutedForeground)),
        ),
      ),
    );
  }
}
