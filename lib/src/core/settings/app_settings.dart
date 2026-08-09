import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { system, english, turkish }

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.system,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  Locale? get locale => switch (language) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.turkish => const Locale('tr'),
  };

  AppSettings copyWith({ThemeMode? themeMode, AppLanguage? language}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw StateError('SharedPreferences must be overridden at app startup.');
});

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  static const _themeModeKey = 'settings_theme_mode';
  static const _languageKey = 'settings_language';

  late final SharedPreferences _preferences;

  @override
  AppSettings build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      themeMode: _enumByName(
        ThemeMode.values,
        _preferences.getString(_themeModeKey),
        ThemeMode.system,
      ),
      language: _enumByName(
        AppLanguage.values,
        _preferences.getString(_languageKey),
        AppLanguage.system,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _preferences.setString(_themeModeKey, mode.name);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await _preferences.setString(_languageKey, language.name);
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
