import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeon/src/core/settings/app_settings.dart';

void main() {
  test('loads and persists language and theme choices', () async {
    SharedPreferences.setMockInitialValues({
      'settings_theme_mode': 'dark',
      'settings_language': 'turkish',
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    expect(container.read(appSettingsProvider).themeMode, ThemeMode.dark);
    expect(container.read(appSettingsProvider).locale, const Locale('tr'));

    await container
        .read(appSettingsProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await container
        .read(appSettingsProvider.notifier)
        .setLanguage(AppLanguage.english);

    expect(preferences.getString('settings_theme_mode'), 'light');
    expect(preferences.getString('settings_language'), 'english');
  });
}
