import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

final class AppPreferences extends Equatable {
  const AppPreferences({this.languageCode = 'ar', this.themeMode = AppThemeMode.system});

  final String languageCode;
  final AppThemeMode themeMode;

  AppPreferences copyWith({String? languageCode, AppThemeMode? themeMode}) =>
      AppPreferences(languageCode: languageCode ?? this.languageCode, themeMode: themeMode ?? this.themeMode);

  @override
  List<Object> get props => [languageCode, themeMode];
}
