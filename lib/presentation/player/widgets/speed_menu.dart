import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../core/formatting.dart';
import '../cubit/player_cubit.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({required this.speed, required this.onChanged, super.key});

  final double speed;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => FPopoverMenu(
    menuAnchor: AlignmentDirectional.bottomEnd,
    childAnchor: AlignmentDirectional.topEnd,
    menuBuilder: (context, controller, _) => [
      .group(
        children: [
          for (final option in PlayerCubit.speeds)
            .item(
              title: Text(formatSpeed(option, context.localeName), textDirection: TextDirection.ltr),
              suffix: option == speed ? const Icon(FLucideIcons.check) : null,
              onPress: () {
                controller.hide();
                onChanged(option);
              },
            ),
        ],
      ),
    ],
    builder: (context, controller, _) => FButton(
      variant: .outline,
      size: .sm,
      mainAxisSize: MainAxisSize.min,
      semanticsLabel: context.l10n.playbackSpeed,
      onPress: controller.toggle,
      prefix: const Icon(FLucideIcons.gauge),
      child: Text(formatSpeed(speed, context.localeName), textDirection: TextDirection.ltr),
    ),
  );
}
