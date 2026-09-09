import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_coordinator.dart';

/// A single, stable banner slot below the Navigator, shared by every route.
class AdBannerHost extends ConsumerWidget {
  const AdBannerHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(adCoordinatorProvider);
    if (!coordinator.shouldReserveBannerSpace) return const SizedBox.shrink();

    final ad = coordinator.bannerAd;
    final loaded =
        coordinator.bannerState == BannerLoadState.loaded && ad != null;
    final theme = Theme.of(context);

    return Material(
      key: const ValueKey('ad-banner-surface'),
      // Keep the fixed slot visually continuous with the app background. Only
      // the 320x50 ad creative should differ from the surrounding surface.
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 2),
        child: SizedBox(
          width: double.infinity,
          height: AdSize.banner.height.toDouble(),
          child: loaded
              ? Center(
                  child: SizedBox(
                    width: AdSize.banner.width.toDouble(),
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: ad),
                  ),
                )
              : _BannerLoading(state: coordinator.bannerState),
        ),
      ),
    );
  }
}

class _BannerLoading extends StatelessWidget {
  const _BannerLoading({required this.state});

  final BannerLoadState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Advertisement',
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Text(
            'AD',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          if (state != BannerLoadState.unavailable)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
        ],
      ),
    );
  }
}
