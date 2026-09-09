import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeon/src/core/ads/ad_banner_host.dart';
import 'package:wakeon/src/core/ads/ad_coordinator.dart';

class _LoadingAdCoordinator extends AdCoordinator {
  _LoadingAdCoordinator({required super.preferences});

  @override
  bool get shouldReserveBannerSpace => true;

  @override
  BannerLoadState get bannerState => BannerLoadState.loading;
}

void main() {
  testWidgets(
    'loading banner and progress indicator fill the available width',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adCoordinatorProvider.overrideWith(
              (ref) => _LoadingAdCoordinator(preferences: preferences),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(width: 400, child: AdBannerHost()),
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(LinearProgressIndicator)).width, 400);
    },
  );

  testWidgets('banner surroundings use the app surface color', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adCoordinatorProvider.overrideWith(
            (ref) => _LoadingAdCoordinator(preferences: preferences),
          ),
        ],
        child: MaterialApp(theme: theme, home: const AdBannerHost()),
      ),
    );

    final bannerSurface = tester.widget<Material>(
      find.byKey(const ValueKey('ad-banner-surface')),
    );
    expect(bannerSurface.color, theme.colorScheme.surface);
  });

  testWidgets('Premium never reserves or renders banner space', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adCoordinatorProvider.overrideWith(
            (ref) => AdCoordinator(preferences: preferences, isPremium: true),
          ),
        ],
        child: const MaterialApp(home: AdBannerHost()),
      ),
    );

    expect(find.byKey(const ValueKey('ad-banner-surface')), findsNothing);
  });
}
