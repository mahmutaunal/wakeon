import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeon/l10n/app_localizations.dart';

import 'devices_controller.dart';
import 'remote_wake_guide_screen.dart';

/// Displays app settings, backup actions, privacy information, and project links.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _githubUrl = 'github.com/mahmutaunal/wakeon';
  static const _appVersion = '1.0.0';
  static const _studioName = 'AlpWare Studio';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _AppHeaderCard(
              appVersion: _appVersion,
              studioName: _studioName,
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.general),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.public_rounded,
              title: l10n.remoteWakeGuide,
              subtitle: l10n.remoteWakeGuideDescription,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RemoteWakeGuideScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.dataBackup),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.upload_file_rounded,
              title: l10n.exportBackup,
              subtitle: l10n.exportBackupDescription,
              onTap: () => _exportBackup(context, ref),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.download_rounded,
              title: l10n.importBackup,
              subtitle: l10n.importBackupDescription,
              onTap: () => _importBackup(context, ref),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.trustPrivacy),
            const SizedBox(height: 8),
            const _PrivacyHighlightsCard(),
            const SizedBox(height: 12),
            const _InfoCard(),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.aboutWakeon),
            const SizedBox(height: 8),
            const _BrandCard(studioName: _studioName),
            const SizedBox(height: 12),
            const _VersionCard(appVersion: _appVersion),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.article_rounded,
              title: l10n.openSourceLicenses,
              subtitle: l10n.openSourceLicensesDescription,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: _appVersion,
                  applicationLegalese: '© 2026 $_studioName',
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.projectLinks),
            const SizedBox(height: 8),
            const _GithubCard(githubUrl: _githubUrl),
          ],
        ),
      ),
    );
  }

  /// Exports the current device list and reports the result to the user.
  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final exported = await ref
          .read(devicesControllerProvider.notifier)
          .exportBackup();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exported ? l10n.backupExported : l10n.exportCancelled),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      // Map known validation errors to localized user-friendly messages.
      final message =
          error is FormatException && error.message == 'no_devices_to_export'
          ? l10n.noDevicesToExport
          : l10n.couldNotExportBackup(error.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Imports devices from a backup file and reports the result to the user.
  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final importedCount = await ref
          .read(devicesControllerProvider.notifier)
          .importBackup();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            importedCount == 0
                ? l10n.importCancelled
                : l10n.devicesImported(importedCount),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotImportBackup(error.toString()))),
      );
    }
  }
}

/// Header card that presents the app identity and version metadata.
class _AppHeaderCard extends StatelessWidget {
  final String appVersion;
  final String studioName;

  const _AppHeaderCard({required this.appVersion, required this.studioName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.power_settings_new_rounded, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChipLabel(text: studioName),
                      _ChipLabel(text: l10n.versionLabel(appVersion)),
                    ],
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Reusable settings row with an icon, text content, and navigation action.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Highlights the app's local-first privacy guarantees.
class _PrivacyHighlightsCard extends StatelessWidget {
  const _PrivacyHighlightsCard();

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
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.privacySummaryTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacySummaryDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.phone_android_rounded,
              title: l10n.savedLocally,
              subtitle: l10n.savedLocallyDescription,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.visibility_off_rounded,
              title: l10n.noTracking,
              subtitle: l10n.noTrackingDescription,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.folder_copy_rounded,
              title: l10n.backupControl,
              subtitle: l10n.backupControlDescription,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows key trust signals for open-source and privacy-focused users.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.block_rounded,
              title: l10n.noAds,
              subtitle: l10n.noAdsDescription,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.person_off_rounded,
              title: l10n.noAccount,
              subtitle: l10n.noAccountDescription,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.storage_rounded,
              title: l10n.localOnly,
              subtitle: l10n.localOnlyDescription,
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.code_rounded,
              title: l10n.openSource,
              subtitle: l10n.openSourceDescription,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final String studioName;

  const _BrandCard({required this.studioName});

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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.apps_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studioName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.studioDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipLabel(text: l10n.brandNoAds),
                _ChipLabel(text: l10n.brandPrivacyFirst),
                _ChipLabel(text: l10n.brandOpenSource),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String appVersion;

  const _VersionCard({required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.info_outline_rounded,
              title: l10n.appVersion,
              subtitle: l10n.versionLabel(appVersion),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.security_rounded,
              title: l10n.privacyPolicy,
              subtitle: l10n.privacyPolicyDescription,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;

  const _ChipLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Displays the public repository reference for open-source contributors.
class _GithubCard extends StatelessWidget {
  final String githubUrl;

  const _GithubCard({required this.githubUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.hub_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.openSourceProject,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.openSourceProjectDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    githubUrl,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
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
