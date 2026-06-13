import 'package:flutter/material.dart';
import 'package:wakeon/l10n/app_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/devices/presentation/devices_screen.dart';

/// Root application widget responsible for configuring themes,
/// localization, and the initial navigation entry point.
class WakeonApp extends StatelessWidget {
  const WakeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure global application settings and visual appearance.
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const DevicesScreen(),
    );
  }
}
