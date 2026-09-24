import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../../../core/context_extensions.dart';
import '../../../domain/models/app_preferences.dart';
import '../cubit/settings_cubit.dart';

class LanguageAction extends StatelessWidget {
  const LanguageAction({super.key});

  @override
  Widget build(BuildContext context) => FHeaderAction(
    icon: const Icon(FLucideIcons.languages),
    semanticsLabel: context.l10n.switchLanguage,
    onPress: context.read<SettingsCubit>().toggleLanguage,
  );
}

class ThemeModeAction extends StatelessWidget {
  const ThemeModeAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.watch<SettingsCubit>();
    final options = [
      (AppThemeMode.system, FLucideIcons.sunMoon, l10n.themeSystem),
      (AppThemeMode.light, FLucideIcons.sun, l10n.themeLight),
      (AppThemeMode.dark, FLucideIcons.moon, l10n.themeDark),
    ];

    return FPopoverMenu(
      menuAnchor: AlignmentDirectional.topEnd,
      childAnchor: AlignmentDirectional.bottomEnd,
      menuBuilder: (context, controller, _) => [
        .group(
          children: [
            for (final (mode, icon, label) in options)
              .item(
                prefix: Icon(icon),
                title: Text(label),
                suffix: cubit.state.themeMode == mode ? const Icon(FLucideIcons.check) : null,
                onPress: () {
                  controller.hide();
                  cubit.setThemeMode(mode);
                },
              ),
          ],
        ),
      ],
      builder: (context, controller, _) => FHeaderAction(
        icon: const Icon(FLucideIcons.sunMoon),
        semanticsLabel: l10n.appearance,
        onPress: controller.toggle,
      ),
    );
  }
}
