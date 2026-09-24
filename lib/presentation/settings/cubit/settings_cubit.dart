import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../domain/models/app_preferences.dart';

class SettingsCubit extends Cubit<AppPreferences> {
  SettingsCubit(this._repository, AppPreferences initial) : super(initial);

  final SettingsRepository _repository;

  Future<void> toggleLanguage() async {
    final languageCode = state.languageCode == 'ar' ? 'en' : 'ar';
    emit(state.copyWith(languageCode: languageCode));
    await _repository.saveLanguage(languageCode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _repository.saveThemeMode(mode);
  }
}
