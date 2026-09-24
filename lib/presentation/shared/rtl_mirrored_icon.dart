import 'package:flutter/widgets.dart';

/// The Arabic timeline runs right to left, so the play triangle points left to match it.
class RtlMirroredIcon extends StatelessWidget {
  const RtlMirroredIcon(this.icon, {this.size, this.color, super.key});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: Directionality.of(context) == TextDirection.rtl,
    child: Icon(icon, size: size, color: color),
  );
}
