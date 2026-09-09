import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app/wakeon_app.dart';
import 'src/core/premium/premium_controller.dart';
import 'src/core/premium/purchase_gateway.dart';
import 'src/core/settings/app_settings.dart';

/// Application entry point.
Future<void> main() async {
  // Ensure Flutter bindings are available before app initialization.
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  // Subscribe to store updates before rendering the app so pending/restored
  // transactions emitted at launch cannot be missed.
  final premiumController = PremiumController(
    preferences: preferences,
    gateway: StorePurchaseGateway(),
  );
  await premiumController.initialize();

  // Load persisted appearance choices before the first frame to avoid flicker.
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        premiumControllerProvider.overrideWith((_) => premiumController),
      ],
      child: const WakeonApp(),
    ),
  );
}
