import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../core/device_shell/device_shell.dart';
import '../data/catalog/course_catalog_source.dart';
import '../data/db/app_database.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/notes_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/app_preferences.dart';
import '../l10n/app_localizations.dart';
import '../presentation/settings/settings.dart';
import 'router.dart';

class ThaheenApp extends StatefulWidget {
  const ThaheenApp({required this.database, required this.deviceShell, required this.preferences, super.key});

  final AppDatabase database;
  final DeviceShell deviceShell;
  final AppPreferences preferences;

  @override
  State<ThaheenApp> createState() => _ThaheenAppState();
}

class _ThaheenAppState extends State<ThaheenApp> {
  late final _courses = CourseRepository(CourseCatalogSource());
  late final _progress = ProgressRepository(widget.database);
  late final _notes = NotesRepository(widget.database);
  late final _settings = SettingsRepository(widget.database);
  late final GoRouter _router = createRouter(courses: _courses, progress: _progress);

  @override
  void dispose() {
    _router.dispose();
    widget.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: _courses),
      RepositoryProvider.value(value: _progress),
      RepositoryProvider.value(value: _notes),
      RepositoryProvider.value(value: _settings),
      RepositoryProvider.value(value: widget.deviceShell),
    ],
    child: BlocProvider(
      create: (_) => SettingsCubit(_settings, widget.preferences),
      child: BlocBuilder<SettingsCubit, AppPreferences>(
        builder: (context, preferences) => WidgetsApp.router(
          routerConfig: _router,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          color: AppTheme.light.colors.primary,
          locale: preferences.languageCode == 'ar' ? const Locale('ar', 'EG') : const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [...AppLocalizations.localizationsDelegates, FLocalizations.delegate],
          builder: (context, child) {
            final brightness = switch (preferences.themeMode) {
              AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
              AppThemeMode.light => Brightness.light,
              AppThemeMode.dark => Brightness.dark,
            };
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              child: _ShellBrightness(
                shell: widget.deviceShell,
                brightness: brightness,
                child: FTheme(
                  data: AppTheme.of(brightness),
                  child: FToaster(child: FTooltipGroup(child: child!)),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _ShellBrightness extends StatefulWidget {
  const _ShellBrightness({required this.shell, required this.brightness, required this.child});

  final DeviceShell shell;
  final Brightness brightness;
  final Widget child;

  @override
  State<_ShellBrightness> createState() => _ShellBrightnessState();
}

class _ShellBrightnessState extends State<_ShellBrightness> {
  @override
  void initState() {
    super.initState();
    widget.shell.setBrightness(widget.brightness);
  }

  @override
  void didUpdateWidget(_ShellBrightness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness != widget.brightness) widget.shell.setBrightness(widget.brightness);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
