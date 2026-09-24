import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/device_shell/device_shell.dart';
import 'data/db/app_database.dart';
import 'data/repositories/settings_repository.dart';
import 'domain/models/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceShell = DeviceShell();
  await deviceShell.lockPortrait();

  final database = AppDatabase();
  AppPreferences preferences;
  try {
    preferences = await SettingsRepository(database).loadPreferences();
  } on Object {
    preferences = const AppPreferences();
  }

  runApp(ThaheenApp(database: database, deviceShell: deviceShell, preferences: preferences));
}
