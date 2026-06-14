import 'package:flutter/material.dart';
import 'package:wakeon/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/discovered_device.dart';
import 'device_form_screen.dart';
import 'devices_controller.dart';

/// Screen that scans the local network and lets users add discovered devices.
class NetworkScanScreen extends ConsumerStatefulWidget {
  const NetworkScanScreen({super.key});

  @override
  ConsumerState<NetworkScanScreen> createState() => _NetworkScanScreenState();
}

class _NetworkScanScreenState extends ConsumerState<NetworkScanScreen> {
  late Future<List<DiscoveredDevice>> _scanFuture;

  @override
  void initState() {
    super.initState();
    _scanFuture = _scan();
  }

  // Start a local network scan using the shared scan service.
  Future<List<DiscoveredDevice>> _scan() {
    return ref.read(networkScanServiceProvider).scanLocalNetwork();
  }

  // Recreate the scan future so FutureBuilder starts a new scan cycle.
  void _retry() {
    setState(() {
      _scanFuture = _scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanNetwork)),
      body: SafeArea(
        child: FutureBuilder<List<DiscoveredDevice>>(
          future: _scanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _ScanningView();
            }

            if (snapshot.hasError) {
              return _ScanErrorView(
                message: snapshot.error.toString(),
                onRetry: _retry,
              );
            }

            final devices = snapshot.data ?? [];

            if (devices.isEmpty) {
              return _NoDevicesFoundView(
                onRetry: _retry,
                onAddManually: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const DeviceFormScreen()),
                  );
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: devices.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ScanResultHeader(
                    count: devices.length,
                    onScanAgain: _retry,
                  );
                }

                final device = devices[index - 1];

                return _DiscoveredDeviceCard(
                  device: device,
                  onTap: () => _openAddDevice(context, device),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Pre-fill the device form with data collected during network discovery.
  void _openAddDevice(BuildContext context, DiscoveredDevice device) {
    final l10n = AppLocalizations.of(context)!;
    final scanService = ref.read(networkScanServiceProvider);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DeviceFormScreen(
          initialName: device.hostname ?? l10n.deviceWithIp(device.ipAddress),
          initialHostAddress: device.ipAddress,
          initialMacAddress: device.macAddress,
          initialBroadcastAddress: scanService.getBroadcastAddressFromIp(
            device.ipAddress,
          ),
        ),
      ),
    );
  }
}

/// Header shown above successful scan results.
class _ScanResultHeader extends StatelessWidget {
  final int count;
  final VoidCallback onScanAgain;

  const _ScanResultHeader({required this.count, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              child: const Icon(Icons.radar_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scanComplete,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.devicesFound(count),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.scanAgain,
              onPressed: onScanAgain,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card that presents a discovered host and its available network details.
class _DiscoveredDeviceCard extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onTap;

  const _DiscoveredDeviceCard({required this.device, required this.onTap});

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
                  child: const Icon(Icons.devices_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.hostname ?? l10n.deviceWithIp(device.ipAddress),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.hostname == null
                            ? l10n.hostnameNotAvailable
                            : l10n.hostnameDetected,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.ipAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ScanInfoRow(
              icon: Icons.memory_rounded,
              text: device.hasMacAddress
                  ? device.macAddress!
                  : l10n.macAddressRequiredManually,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addDevice),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact row used for secondary scan result metadata.
class _ScanInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ScanInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading state displayed while the local network scan is running.
class _ScanningView extends StatelessWidget {
  const _ScanningView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              l10n.scanningLocalNetwork,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.scanMayTakeSeconds,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when no reachable devices are found.
class _NoDevicesFoundView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onAddManually;

  const _NoDevicesFoundView({
    required this.onRetry,
    required this.onAddManually,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noDevicesFound,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noDevicesFoundDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.scanAgain),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onAddManually,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addManually),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state shown when network scanning fails.
class _ScanErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ScanErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.scanFailed,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
