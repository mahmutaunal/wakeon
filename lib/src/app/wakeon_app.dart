import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeon/l10n/app_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/ads/ad_banner_host.dart';
import '../core/ads/ad_coordinator.dart';
import '../core/play/play_providers.dart';
import '../core/premium/premium_controller.dart';
import '../core/settings/app_settings.dart';
import '../features/devices/presentation/devices_screen.dart';

/// Root application widget responsible for configuring themes,
/// localization, and the initial navigation entry point.
class WakeonApp extends ConsumerStatefulWidget {
  const WakeonApp({super.key});

  @override
  ConsumerState<WakeonApp> createState() => _WakeonAppState();
}

class _WakeonAppState extends ConsumerState<WakeonApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(premiumControllerProvider).initialize();
      await ref.read(adCoordinatorProvider).initialize();
      await ref.read(playReviewServiceProvider).recordSession();
      await ref.read(playUpdateServiceProvider).checkForUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    // Configure global application settings and visual appearance.
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: const DevicesScreen(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            const AdBannerHost(),
          ],
        );
      },
    );
  }
}
