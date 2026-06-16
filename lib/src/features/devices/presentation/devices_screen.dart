import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wakeon/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/wake_device_type.dart';
import '../domain/wake_device.dart';
import '../domain/device_sort_type.dart';
import '../domain/device_connection_status.dart';
import 'devices_controller.dart';
import 'device_form_screen.dart';
import 'network_scan_screen.dart';
import 'remote_wake_guide_screen.dart';
import 'settings_screen.dart';

/// Main device list screen for managing and waking saved devices.
class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';

  // Apply a local search filter across device name, MAC address, address, and type.
  List<WakeDevice> _filterDevices(List<WakeDevice> devices) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return devices;
    }

    return devices.where((device) {
      final typeName = device.type.name.toLowerCase();

      return device.name.toLowerCase().contains(query) ||
          device.macAddress.toLowerCase().contains(query) ||
          device.broadcastAddress.toLowerCase().contains(query) ||
          (device.hostAddress?.toLowerCase().contains(query) ?? false) ||
          typeName.contains(query);
    }).toList();
  }

  // Convert technical validation errors into localized messages for users.
  String _friendlyTestError(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;

    if (error is FormatException) {
      switch (error.message) {
        case 'invalid_broadcast_address':
          return l10n.invalidBroadcastAddress;
        case 'invalid_port':
          return l10n.invalidPort;
      }
    }

    if (error is SocketException && error.message == 'udp_socket_failed') {
      return l10n.udpSocketFailed;
    }

    return error.toString();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(devicesControllerProvider.notifier).refreshDeviceStatuses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentSortType =
        devicesState.valueOrNull?.sortType ?? DeviceSortType.favoritesFirst;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.scanNetwork,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NetworkScanScreen()),
              );
            },
            icon: const Icon(Icons.radar_rounded),
          ),
          IconButton(
            tooltip: l10n.remoteWakeGuide,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RemoteWakeGuideScreen(),
                ),
              );
            },
            icon: const Icon(Icons.public_rounded),
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addDevice,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const DeviceFormScreen()));
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: devicesState.when(
          data: (state) {
            final devices = state.devices;
            final sortType = state.sortType;

            if (devices.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshDevices,
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(height: 600, child: _EmptyDevicesView()),
                ),
              );
            }

            final filteredDevices = _filterDevices(devices);
            final hasSearchResults = filteredDevices.isNotEmpty;

            return RefreshIndicator(
              onRefresh: _refreshDevices,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: hasSearchResults
                    ? filteredDevices.length +
                          (_searchQuery.trim().isEmpty ? 2 : 3)
                    : 2,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Row(
                      children: [
                        Expanded(
                          child: _SearchField(
                            controller: _searchController,
                            hintText: l10n.searchDevices,
                            hasText: _searchQuery.trim().isNotEmpty,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                _showSortSheet(context, ref, currentSortType),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.sort_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (index == 1) {
                    return _SortSummary(sortType: sortType);
                  }

                  if (!hasSearchResults) {
                    return _NoSearchResultsView(query: _searchQuery);
                  }

                  if (hasSearchResults &&
                      _searchQuery.trim().isNotEmpty &&
                      index == 2) {
                    return _SearchResultSummary(count: filteredDevices.length);
                  }

                  final deviceIndex = _searchQuery.trim().isEmpty
                      ? index - 2
                      : index - 3;
                  final device = filteredDevices[deviceIndex];

                  return _DeviceCard(
                    device: device,
                    onWake: () => _wakeDevice(context, ref, device),
                    onTest: () => _testDevice(context, ref, device),
                    onToggleFavorite: () {
                      ref
                          .read(devicesControllerProvider.notifier)
                          .toggleFavorite(device.id);
                    },
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeviceFormScreen(device: device),
                        ),
                      );
                    },
                    onDelete: () => _deleteDevice(context, ref, device),
                  );
                },
              ),
            );
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, _) {
            return _ErrorView(message: error.toString());
          },
        ),
      ),
    );
  }

  Future<void> _refreshDevices() async {
    await ref.read(devicesControllerProvider.notifier).refreshDeviceStatuses();
  }

  // Send the wake packet and show immediate feedback for the selected device.
  Future<void> _wakeDevice(
    BuildContext context,
    WidgetRef ref,
    WakeDevice device,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(devicesControllerProvider.notifier).wakeDevice(device);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wakePacketSent(device.name))));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotWakeDevice(device.name, error.toString())),
        ),
      );
    }
  }

  // Confirm deletion before removing a saved device from local storage.
  Future<void> _deleteDevice(
    BuildContext context,
    WidgetRef ref,
    WakeDevice device,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.deleteDeviceQuestion,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deviceWillBeRemoved(device.name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(devicesControllerProvider.notifier).deleteDevice(device.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.deviceDeleted(device.name))));
  }

  // Validate the selected device configuration without sending a wake packet.
  Future<void> _testDevice(
    BuildContext context,
    WidgetRef ref,
    WakeDevice device,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await ref
          .read(devicesControllerProvider.notifier)
          .testDeviceConfiguration(device);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deviceConfigurationLooksGood(device.name))),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.deviceConfigurationFailed(
              device.name,
              _friendlyTestError(context, error),
            ),
          ),
        ),
      );
    }
  }

  // Show available sort options and persist the user's selection.
  Future<void> _showSortSheet(
    BuildContext context,
    WidgetRef ref,
    DeviceSortType currentSortType,
  ) async {
    final selectedSortType = await showModalBottomSheet<DeviceSortType>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                l10n.sortDevices,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final sortType in DeviceSortType.values)
                RadioListTile<DeviceSortType>(
                  value: sortType,
                  groupValue: currentSortType,
                  onChanged: (value) {
                    Navigator.of(context).pop(value);
                  },
                  title: Text(_sortTypeLabel(context, sortType)),
                ),
            ],
          ),
        );
      },
    );

    if (selectedSortType == null) return;

    await ref
        .read(devicesControllerProvider.notifier)
        .changeSortType(selectedSortType);
  }
}

/// Card that displays a saved device and its primary actions.
class _DeviceCard extends StatelessWidget {
  final WakeDevice device;
  final VoidCallback onWake;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.onWake,
    required this.onToggleFavorite,
    required this.onTest,
    required this.onEdit,
    required this.onDelete,
  });

  // Map device types to Material icons used in the device list.
  IconData _deviceTypeIcon(WakeDeviceType type) {
    switch (type) {
      case WakeDeviceType.desktop:
        return Icons.desktop_windows_rounded;
      case WakeDeviceType.laptop:
        return Icons.laptop_mac_rounded;
      case WakeDeviceType.server:
        return Icons.dns_rounded;
      case WakeDeviceType.nas:
        return Icons.storage_rounded;
      case WakeDeviceType.router:
        return Icons.router_rounded;
      case WakeDeviceType.other:
        return Icons.devices_other_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final lastWakeText = device.lastWakeAt == null
        ? l10n.neverWoken
        : l10n.lastWake(
            DateFormat('MMM d, HH:mm', localeName).format(device.lastWakeAt!),
          );

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
                  child: Icon(_deviceTypeIcon(device.type)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    device.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: device.isFavorite
                      ? l10n.removeFromFavorites
                      : l10n.addToFavorites,
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    device.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'test':
                        onTest();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(value: 'test', child: Text(l10n.testSetup)),
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(device.macAddress, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              l10n.deviceNetworkAddress(device.broadcastAddress, device.port),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _DeviceStatusRow(device: device),
            const SizedBox(height: 10),
            Text(
              lastWakeText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onWake,
              icon: const Icon(Icons.power_settings_new_rounded),
              label: Text(l10n.wake),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown before the user adds any devices.
class _EmptyDevicesView extends StatelessWidget {
  const _EmptyDevicesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noDevicesYet,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noDevicesDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple error state used when device data cannot be loaded.
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Search input that keeps filtering controls visible for all list states.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool hasText;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: !hasText
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

/// Empty search state shown while preserving the active search field.
class _NoSearchResultsView extends StatelessWidget {
  final String query;

  const _NoSearchResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Center(
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
                l10n.noSearchResults,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noSearchResultsDescription(query),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact summary that displays the number of matching devices.
class _SearchResultSummary extends StatelessWidget {
  final int count;

  const _SearchResultSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        l10n.devicesFound(count),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Resolves localized labels for each supported device sort option.
String _sortTypeLabel(BuildContext context, DeviceSortType sortType) {
  final l10n = AppLocalizations.of(context)!;

  switch (sortType) {
    case DeviceSortType.favoritesFirst:
      return l10n.sortFavoritesFirst;
    case DeviceSortType.nameAsc:
      return l10n.sortNameAsc;
    case DeviceSortType.nameDesc:
      return l10n.sortNameDesc;
    case DeviceSortType.recentlyAdded:
      return l10n.sortRecentlyAdded;
    case DeviceSortType.recentlyWoken:
      return l10n.sortRecentlyWoken;
    case DeviceSortType.deviceType:
      return l10n.sortDeviceType;
  }
}

/// Shows the currently selected device sorting option.
class _SortSummary extends StatelessWidget {
  final DeviceSortType sortType;

  const _SortSummary({required this.sortType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        l10n.sortedBy(_sortTypeLabel(context, sortType)),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DeviceStatusRow extends StatelessWidget {
  final WakeDevice device;

  const _DeviceStatusRow({required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final statusText = _statusText(context, device.connectionStatus);
    final statusColor = _statusColor(theme, device.connectionStatus);
    final lastSeenText = device.lastSeenAt == null
        ? l10n.lastSeenNever
        : l10n.lastSeenAt(
            DateFormat(
              'MMM d, HH:mm',
              Localizations.localeOf(context).toLanguageTag(),
            ).format(device.lastSeenAt!),
          );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _StatusChip(color: statusColor, text: statusText),
        Text(
          lastSeenText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _statusText(BuildContext context, DeviceConnectionStatus status) {
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case DeviceConnectionStatus.online:
        return l10n.online;
      case DeviceConnectionStatus.offline:
        return l10n.offline;
      case DeviceConnectionStatus.unknown:
        return l10n.unknown;
    }
  }

  Color _statusColor(ThemeData theme, DeviceConnectionStatus status) {
    switch (status) {
      case DeviceConnectionStatus.online:
        return Colors.green;
      case DeviceConnectionStatus.offline:
        return theme.colorScheme.error;
      case DeviceConnectionStatus.unknown:
        return theme.colorScheme.outline;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusChip({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox(width: 7, height: 7),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
