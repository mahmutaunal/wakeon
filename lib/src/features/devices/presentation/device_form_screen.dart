import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakeon/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/wake_device.dart';
import '../domain/wake_device_type.dart';
import 'devices_controller.dart';
import 'network_scan_screen.dart';
import 'mac_address_input_formatter.dart';

/// Form screen used to add a new Wake-on-LAN device or edit an existing one.
class DeviceFormScreen extends ConsumerStatefulWidget {
  final WakeDevice? device;
  final String? initialName;
  final String? initialBroadcastAddress;
  final String? initialMacAddress;
  final String? initialHostAddress;

  const DeviceFormScreen({
    super.key,
    this.device,
    this.initialName,
    this.initialBroadcastAddress,
    this.initialMacAddress,
    this.initialHostAddress,
  });

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _macController;
  late final TextEditingController _broadcastController;
  late final TextEditingController _portController;
  late final TextEditingController _hostController;

  WakeDeviceType _selectedType = WakeDeviceType.desktop;

  // Determines whether the form should update an existing device.
  bool get _isEditing => widget.device != null;

  @override
  void initState() {
    super.initState();

    final device = widget.device;

    _nameController = TextEditingController(
      text: device?.name ?? widget.initialName ?? '',
    );

    _macController = TextEditingController(
      text: device?.macAddress ?? widget.initialMacAddress ?? '',
    );

    _broadcastController = TextEditingController(
      text:
          device?.broadcastAddress ??
          widget.initialBroadcastAddress ??
          '192.168.1.255',
    );

    _portController = TextEditingController(text: '${device?.port ?? 9}');

    _selectedType = widget.device?.type ?? WakeDeviceType.desktop;

    _hostController = TextEditingController(
      text: device?.hostAddress ?? widget.initialHostAddress ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _macController.dispose();
    _broadcastController.dispose();
    _portController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _isEditing ? l10n.editDevice : l10n.addDevice;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: _BottomSaveBar(
        label: _isEditing ? l10n.saveChanges : l10n.saveDevice,
        onPressed: _save,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HeaderCard(isEditing: _isEditing),
              const SizedBox(height: 24),
              if (!_isEditing) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const NetworkScanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.radar_rounded),
                  label: Text(l10n.scanNetwork),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.deviceName,
                  hintText: l10n.deviceNameHint,
                  prefixIcon: const Icon(Icons.computer_rounded),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WakeDeviceType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.deviceType,
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
                items: WakeDeviceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_deviceTypeLabel(context, type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _macController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: const [MacAddressInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.macAddress,
                  hintText: l10n.macAddressHint,
                  prefixIcon: const Icon(Icons.memory_rounded),
                ),
                validator: _macValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hostController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.hostAddress,
                  hintText: l10n.hostAddressHint,
                  prefixIcon: const Icon(Icons.lan_rounded),
                  suffixIcon: _DotInsertButton(controller: _hostController),
                ),
                validator: _optionalIpValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _broadcastController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.broadcastAddress,
                  hintText: l10n.broadcastAddressHint,
                  prefixIcon: const Icon(Icons.router_rounded),
                  suffixIcon: _DotInsertButton(
                    controller: _broadcastController,
                  ),
                ),
                validator: _ipValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.port,
                  hintText: l10n.portHint,
                  prefixIcon: const Icon(Icons.settings_ethernet_rounded),
                ),
                validator: _portValidator,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              const _NetworkAddressHelpCard(),
              const SizedBox(height: 16),
              const _HelpCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Validates required text fields with localized error messages.
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.requiredFieldError;
    }

    return null;
  }

  // Validates IPv4 broadcast addresses before saving the device.
  String? _ipValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return AppLocalizations.of(context)!.broadcastAddressRequired;
    }

    final parts = text.split('.');

    if (parts.length != 4) {
      return AppLocalizations.of(context)!.invalidIpv4Address;
    }

    for (final part in parts) {
      final number = int.tryParse(part);

      if (number == null || number < 0 || number > 255) {
        return AppLocalizations.of(context)!.invalidIpv4Address;
      }
    }

    return null;
  }

  String? _optionalIpValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    final parts = text.split('.');

    if (parts.length != 4) {
      return AppLocalizations.of(context)!.invalidIpv4Address;
    }

    for (final part in parts) {
      final number = int.tryParse(part);

      if (number == null || number < 0 || number > 255) {
        return AppLocalizations.of(context)!.invalidIpv4Address;
      }
    }

    return null;
  }

  // Validates MAC addresses after removing visual separators.
  String? _macValidator(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return AppLocalizations.of(context)!.macAddressRequired;
    }

    final cleanValue = text.replaceAll(RegExp(r'[^A-Fa-f0-9]'), '');

    if (cleanValue.length != 12) {
      return AppLocalizations.of(context)!.invalidMacAddress;
    }

    return null;
  }

  // Ensures the WOL port is within the valid TCP/UDP port range.
  String? _portValidator(String? value) {
    final port = int.tryParse(value?.trim() ?? '');

    if (port == null) {
      return AppLocalizations.of(context)!.invalidPort;
    }

    if (port < 1 || port > 65535) {
      return AppLocalizations.of(context)!.portRangeError;
    }

    return null;
  }

  // Builds the device model and persists it through the devices controller.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final existingDevice = widget.device;

    final device = WakeDevice(
      type: _selectedType,
      id: existingDevice?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      macAddress: _macController.text.trim().toUpperCase(),
      broadcastAddress: _broadcastController.text.trim(),
      port: int.parse(_portController.text.trim()),
      createdAt: existingDevice?.createdAt ?? now,
      lastWakeAt: existingDevice?.lastWakeAt,
      isFavorite: existingDevice?.isFavorite ?? false,
      hostAddress: _hostController.text.trim().isEmpty
          ? null
          : _hostController.text.trim(),
    );

    final controller = ref.read(devicesControllerProvider.notifier);

    if (_isEditing) {
      await controller.updateDevice(device);
    } else {
      await controller.addDevice(device);
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }
}

/// Sticky bottom action bar used to keep the save action always reachable.
class _BottomSaveBar extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BottomSaveBar({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.save_rounded),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}

class _DotInsertButton extends StatelessWidget {
  final TextEditingController controller;

  const _DotInsertButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.insertDot,
      onPressed: () {
        final selection = controller.selection;
        final text = controller.text;
        final cursorIndex = selection.isValid ? selection.start : text.length;
        final safeIndex = cursorIndex.clamp(0, text.length);
        final updatedText = text.replaceRange(safeIndex, safeIndex, '.');

        controller.value = TextEditingValue(
          text: updatedText,
          selection: TextSelection.collapsed(offset: safeIndex + 1),
        );
      },
      icon: const Text(
        '.',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _NetworkAddressHelpCard extends StatelessWidget {
  const _NetworkAddressHelpCard();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.networkAddressHelpTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AddressHelpRow(
              title: l10n.hostAddress,
              description: l10n.hostAddressHelpDescription,
            ),
            const SizedBox(height: 10),
            _AddressHelpRow(
              title: l10n.broadcastAddress,
              description: l10n.broadcastAddressHelpDescription,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.networkScanAutoFillDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressHelpRow extends StatelessWidget {
  final String title;
  final String description;

  const _AddressHelpRow({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle_rounded, size: 8, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Context card that explains whether the user is adding or editing a device.
class _HeaderCard extends StatelessWidget {
  final bool isEditing;

  const _HeaderCard({required this.isEditing});

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
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Icon(isEditing ? Icons.edit_rounded : Icons.add_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isEditing
                    ? l10n.updateDeviceProfileDescription
                    : l10n.addDeviceProfileDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Help section that guides users to find their device MAC address.
class _HelpCard extends StatelessWidget {
  const _HelpCard();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.howToFindMacAddress,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.windowsCommandPromptInstruction,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _CommandBlock(
              title: l10n.macHelpWindowsTitle,
              command: l10n.macHelpWindowsCommand,
            ),
            const SizedBox(height: 10),
            _CommandBlock(
              title: l10n.macHelpMacosTitle,
              command: l10n.macHelpMacosCommand,
            ),
            const SizedBox(height: 10),
            _CommandBlock(
              title: l10n.macHelpLinuxTitle,
              command: l10n.macHelpLinuxCommand,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.usePhysicalAddressInstruction,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays platform-specific commands in a readable monospace block.
class _CommandBlock extends StatelessWidget {
  final String title;
  final String command;

  const _CommandBlock({required this.title, required this.command});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            command,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Resolves localized labels for each supported device type.
String _deviceTypeLabel(BuildContext context, WakeDeviceType type) {
  final l10n = AppLocalizations.of(context)!;

  switch (type) {
    case WakeDeviceType.desktop:
      return l10n.deviceTypeDesktop;
    case WakeDeviceType.laptop:
      return l10n.deviceTypeLaptop;
    case WakeDeviceType.server:
      return l10n.deviceTypeServer;
    case WakeDeviceType.nas:
      return l10n.deviceTypeNas;
    case WakeDeviceType.router:
      return l10n.deviceTypeRouter;
    case WakeDeviceType.other:
      return l10n.deviceTypeOther;
  }
}
