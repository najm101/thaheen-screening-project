import '../../domain/models/app_preferences.dart';
import '../db/app_database.dart';

final class SettingsRepository {
  SettingsRepository(this._db);

  static const _languageKey = 'language';
  static const _themeKey = 'theme_mode';
  static const _speedKey = 'playback_speed';

  final AppDatabase _db;

  Future<AppPreferences> loadPreferences() async {
    final values = await _all();
    return AppPreferences(
      languageCode: switch (values[_languageKey]) {
        'en' => 'en',
        _ => 'ar',
      },
      themeMode: AppThemeMode.values.asNameMap()[values[_themeKey]] ?? AppThemeMode.system,
    );
  }

  Future<void> saveLanguage(String languageCode) => _put(_languageKey, languageCode);

  Future<void> saveThemeMode(AppThemeMode mode) => _put(_themeKey, mode.name);

  Future<double?> playbackSpeed() async => double.tryParse((await _all())[_speedKey] ?? '');

  Future<void> savePlaybackSpeed(double speed) => _put(_speedKey, speed.toString());

  Future<Map<String, String>> _all() async => {
    for (final row in await _db.select(_db.settings).get()) row.key: row.value,
  };

  Future<void> _put(String key, String value) =>
      _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}
