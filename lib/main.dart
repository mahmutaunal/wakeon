import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app/wakeon_app.dart';
import 'src/core/settings/app_settings.dart';

/// Application entry point.
Future<void> main() async {
  // Ensure Flutter bindings are available before app initialization.
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  // Load persisted appearance choices before the first frame to avoid flicker.
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const WakeonApp(),
    ),
  );
}
