import 'package:flutter/material.dart';

/// Explains the available approaches for waking devices outside the local network.
import 'package:wakeon/l10n/app_localizations.dart';

class RemoteWakeGuideScreen extends StatelessWidget {
  const RemoteWakeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remoteWakeGuide)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _IntroCard(),
            SizedBox(height: 12),
            _GuideCard(
              icon: Icons.wifi_rounded,
              title: l10n.localNetwork,
              badge: l10n.recommended,
              description: l10n.localNetworkDescription,
            ),
            SizedBox(height: 12),
            _GuideCard(
              icon: Icons.vpn_key_rounded,
              title: l10n.vpnMode,
              badge: l10n.bestForRemoteWake,
              description: l10n.vpnModeDescription,
            ),
            SizedBox(height: 12),
            _GuideCard(
              icon: Icons.router_rounded,
              title: l10n.routerWakeMode,
              badge: l10n.routerDependent,
              description: l10n.routerWakeModeDescription,
            ),
            SizedBox(height: 12),
            _GuideCard(
              icon: Icons.settings_ethernet_rounded,
              title: l10n.advancedWanMode,
              badge: l10n.notRecommended,
              description: l10n.advancedWanModeDescription,
            ),
            SizedBox(height: 12),
            _WarningCard(),
          ],
        ),
      ),
    );
  }
}

/// Introductory section that summarizes remote Wake-on-LAN concepts.
class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.public_rounded,
              size: 36,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.wakeFromAnotherNetwork,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.remoteWakeIntroDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable card used to describe a remote wake strategy.
class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final String description;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _Badge(text: badge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small status badge used to highlight recommendations and limitations.
class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Displays security considerations for remote Wake-on-LAN setups.
class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.security_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.remoteWakeSecurityWarning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
