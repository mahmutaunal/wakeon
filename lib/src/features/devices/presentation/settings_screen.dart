import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakeon/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../core/play/play_providers.dart';
import '../../../core/play/play_update_service.dart';
import '../../../core/settings/app_settings.dart';

import 'device_form_screen.dart';
import 'devices_controller.dart';
import 'remote_wake_guide_screen.dart';

/// Displays app settings, backup actions, privacy information, and project links.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _githubUrl = 'github.com/mahmutaunal/wakeon';
  static const _studioName = 'AlpWare Studio';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final appVersion = ref.watch(appVersionProvider).valueOrNull ?? '—';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _AppHeaderCard(appVersion: appVersion, studioName: _studioName),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.general),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: l10n.appLanguage,
              subtitle: _languageLabel(l10n, settings.language),
              onTap: () => _selectLanguage(context, ref, settings.language),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.palette_rounded,
              title: l10n.appTheme,
              subtitle: _themeLabel(l10n, settings.themeMode),
              onTap: () => _selectTheme(context, ref, settings.themeMode),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.lock_open_rounded,
              title: l10n.importSharedDevice,
              subtitle: l10n.importSharedDeviceDescription,
              onTap: () => _importSharedDevice(context, ref),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.supportAndUpdates),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.star_rate_rounded,
              title: l10n.rateWakeon,
              subtitle: l10n.rateWakeonDescription,
              onTap: () => _requestReview(context, ref),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.system_update_rounded,
              title: l10n.checkForUpdates,
              subtitle: l10n.checkForUpdatesDescription,
              onTap: () => _checkForUpdates(context, ref),
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
            _VersionCard(appVersion: appVersion),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.article_rounded,
              title: l10n.openSourceLicenses,
              subtitle: l10n.openSourceLicensesDescription,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: appVersion,
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

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.systemDefault,
      AppLanguage.english => l10n.english,
      AppLanguage.turkish => l10n.turkish,
    };
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => l10n.systemDefault,
      ThemeMode.light => l10n.lightTheme,
      ThemeMode.dark => l10n.darkTheme,
    };
  }

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.appLanguage)),
              for (final language in AppLanguage.values)
                ListTile(
                  leading: Icon(
                    language == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                  title: Text(_languageLabel(l10n, language)),
                  onTap: () => Navigator.of(context).pop(language),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setLanguage(selected);
    }
  }

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.appTheme)),
              for (final mode in ThemeMode.values)
                ListTile(
                  leading: Icon(
                    mode == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                  title: Text(_themeLabel(l10n, mode)),
                  onTap: () => Navigator.of(context).pop(mode),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(appSettingsProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _requestReview(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final available = await ref
        .read(playReviewServiceProvider)
        .requestManually();
    if (!context.mounted || available) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.reviewUnavailable)),
    );
  }

  Future<void> _checkForUpdates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(playUpdateServiceProvider)
        .checkForUpdate(userInitiated: true);
    if (!context.mounted) return;

    final message = switch (result) {
      PlayUpdateResult.upToDate => l10n.appIsUpToDate,
      PlayUpdateResult.updateStarted => l10n.updateStarted,
      PlayUpdateResult.updateDownloaded => l10n.updateDownloaded,
      PlayUpdateResult.unavailable => l10n.updateUnavailable,
      PlayUpdateResult.failed => l10n.updateCheckFailed,
    };
    messenger.showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _importSharedDevice(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final shareCode = await _askShareCode(context);

    if (shareCode == null || shareCode.trim().isEmpty) {
      return;
    }

    try {
      final payload = await ref
          .read(deviceShareManagerProvider)
          .pickAndDecryptSharedDevice(shareCode: shareCode.trim());

      if (!context.mounted || payload == null) return;

      final existingDevices =
          ref.read(devicesControllerProvider).valueOrNull?.devices ?? [];

      final normalizedImportedMac = payload.macAddress
          .replaceAll(RegExp(r'[^A-Fa-f0-9]'), '')
          .toUpperCase();

      final alreadyExists = existingDevices.any((device) {
        final normalizedDeviceMac = device.macAddress
            .replaceAll(RegExp(r'[^A-Fa-f0-9]'), '')
            .toUpperCase();

        return normalizedDeviceMac == normalizedImportedMac;
      });

      if (alreadyExists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sharedDeviceAlreadyExists)));
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeviceFormScreen(sharedPayload: payload),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyShareImportError(context, error))),
      );
    }
  }

  Future<String?> _askShareCode(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const _ShareCodeDialog(),
    );
  }

  String _friendlyShareImportError(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;

    if (error is FormatException) {
      switch (error.message) {
        case 'share_expired':
          return l10n.shareExpired;
        case 'invalid_share_file':
          return l10n.invalidShareFile;
        case 'invalid_share_code':
          return l10n.invalidShareCode;
      }
    }

    return l10n.couldNotImportSharedDevice(error.toString());
  }
}

class _ShareCodeDialog extends StatefulWidget {
  const _ShareCodeDialog();

  @override
  State<_ShareCodeDialog> createState() => _ShareCodeDialogState();
}

class _ShareCodeDialogState extends State<_ShareCodeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.enterShareCode),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 6,
        decoration: InputDecoration(
          labelText: l10n.shareCode,
          hintText: '123456',
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pop(_controller.text.trim());
            },
            child: Text(l10n.continueText),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );
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
