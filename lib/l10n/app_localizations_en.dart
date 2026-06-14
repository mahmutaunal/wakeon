// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wakeon';

  @override
  String get deviceName => 'Device name';

  @override
  String get deviceNameHint => 'Desktop PC';

  @override
  String get macAddress => 'MAC address';

  @override
  String get macAddressHint => 'AA:BB:CC:DD:EE:FF';

  @override
  String get broadcastAddress => 'Broadcast address';

  @override
  String get broadcastAddressHint => '192.168.1.255';

  @override
  String get port => 'Port';

  @override
  String get portHint => '9';

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String get broadcastAddressRequired => 'Broadcast address is required.';

  @override
  String get invalidIpv4Address => 'Enter a valid IPv4 address.';

  @override
  String get macAddressRequired => 'MAC address is required.';

  @override
  String get invalidMacAddress => 'Enter a valid MAC address.';

  @override
  String get invalidPort => 'Invalid port.';

  @override
  String get portRangeError => 'Port must be between 1 and 65535.';

  @override
  String get updateDeviceProfileDescription =>
      'Update this Wake-on-LAN device profile.';

  @override
  String get addDeviceProfileDescription =>
      'Add a device you want to wake from this device.';

  @override
  String get howToFindMacAddress => 'How to find your MAC address';

  @override
  String get windowsCommandPromptInstruction =>
      'Find the MAC address of the device you want to wake. Open Command Prompt and run:';

  @override
  String get usePhysicalAddressInstruction =>
      'Use the MAC address (Physical Address) of your Ethernet adapter. On macOS use \'ifconfig\', and on Linux use \'ip link\' to find it.';

  @override
  String get edit => 'Edit';

  @override
  String wakePacketSent(Object deviceName) {
    return 'Wake packet sent to $deviceName.';
  }

  @override
  String couldNotWakeDevice(Object deviceName, Object error) {
    return 'Could not wake $deviceName: $error';
  }

  @override
  String get deleteDeviceQuestion => 'Delete device?';

  @override
  String deviceWillBeRemoved(Object deviceName) {
    return '$deviceName will be removed from Wakeon.';
  }

  @override
  String deviceDeleted(Object deviceName) {
    return '$deviceName deleted.';
  }

  @override
  String get neverWoken => 'Never woken';

  @override
  String lastWake(Object date) {
    return 'Last wake: $date';
  }

  @override
  String deviceNetworkAddress(Object address, Object port) {
    return '$address · Port $port';
  }

  @override
  String deviceWithIp(Object ip) {
    return 'Device $ip';
  }

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String get scanningLocalNetwork => 'Scanning your local network...';

  @override
  String get scanMayTakeSeconds => 'This may take a few seconds.';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get noDevicesFoundDescription =>
      'Some devices may block discovery. You can still add your computer manually.';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanFailed => 'Scan failed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get localNetwork => 'Local network';

  @override
  String get recommended => 'Recommended';

  @override
  String get localNetworkDescription =>
      'Wakeon works best when your phone and computer are connected to the same local network.';

  @override
  String get vpnMode => 'VPN mode';

  @override
  String get bestForRemoteWake => 'Best for remote wake';

  @override
  String get vpnModeDescription =>
      'Use WireGuard, Tailscale, ZeroTier, or your router VPN to connect back to your home network. Then use Wakeon normally.';

  @override
  String get routerWakeMode => 'Router wake mode';

  @override
  String get routerDependent => 'Router dependent';

  @override
  String get routerWakeModeDescription =>
      'Some routers include a built-in Wake-on-LAN feature. If your router supports it, you can wake your computer from the router panel.';

  @override
  String get advancedWanMode => 'Advanced WAN mode';

  @override
  String get notRecommended => 'Not recommended';

  @override
  String get advancedWanModeDescription =>
      'Public IP, port forwarding, static DHCP lease, and IP-MAC binding may be required. This depends heavily on your router and ISP.';

  @override
  String get wakeFromAnotherNetwork => 'Wake from another network';

  @override
  String get remoteWakeIntroDescription =>
      'Wake-on-LAN was designed for local networks. Remote wake is possible, but the safest and most reliable method is using a VPN into your home network.';

  @override
  String get remoteWakeSecurityWarning =>
      'Avoid exposing your computer directly to the internet. Prefer VPN-based access whenever possible.';

  @override
  String get remoteWakeGuideDescription =>
      'Learn how to wake devices from another network.';

  @override
  String get appTagline => 'Simple Wake-on-LAN by AlpWare Studio';

  @override
  String get noAds => 'No ads';

  @override
  String get noAdsDescription => 'Wakeon does not contain ads.';

  @override
  String get noAccount => 'No account';

  @override
  String get noAccountDescription => 'No sign in or cloud account is required.';

  @override
  String get localOnly => 'Local only';

  @override
  String get localOnlyDescription => 'Saved devices stay on your device.';

  @override
  String get openSource => 'Open source';

  @override
  String get openSourceDescription =>
      'Built to be simple, transparent, and community-friendly.';

  @override
  String get github => 'GitHub';

  @override
  String get addDevice => 'Add device';

  @override
  String get editDevice => 'Edit device';

  @override
  String get saveDevice => 'Save device';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get wake => 'Wake';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get scanNetwork => 'Scan network';

  @override
  String get settings => 'Settings';

  @override
  String get remoteWakeGuide => 'Remote wake guide';

  @override
  String get noDevicesYet => 'No devices yet';

  @override
  String get noDevicesDescription =>
      'Add your first computer and wake it with one tap.';

  @override
  String get deviceType => 'Device type';

  @override
  String get deviceTypeDesktop => 'Desktop';

  @override
  String get deviceTypeLaptop => 'Laptop';

  @override
  String get deviceTypeServer => 'Server';

  @override
  String get deviceTypeNas => 'NAS';

  @override
  String get deviceTypeRouter => 'Router';

  @override
  String get deviceTypeOther => 'Other';

  @override
  String get testSetup => 'Test setup';

  @override
  String deviceConfigurationLooksGood(Object deviceName) {
    return '$deviceName configuration looks good.';
  }

  @override
  String deviceConfigurationFailed(Object deviceName, Object error) {
    return '$deviceName configuration failed: $error';
  }

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupDescription =>
      'Save your devices as a JSON backup file.';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupDescription =>
      'Restore devices from a Wakeon JSON backup file.';

  @override
  String get backupExported => 'Backup exported.';

  @override
  String couldNotExportBackup(Object error) {
    return 'Could not export backup: $error';
  }

  @override
  String get importCancelled => 'Import cancelled.';

  @override
  String devicesImported(Object count) {
    return '$count devices imported.';
  }

  @override
  String couldNotImportBackup(Object error) {
    return 'Could not import backup: $error';
  }

  @override
  String get exportCancelled => 'Export cancelled.';

  @override
  String get noDevicesToExport => 'There are no devices to export.';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get searchDevices => 'Search devices';

  @override
  String get noSearchResults => 'No results found';

  @override
  String noSearchResultsDescription(Object query) {
    return 'No devices match “$query”.';
  }

  @override
  String get invalidBroadcastAddress => 'Invalid broadcast address.';

  @override
  String get udpSocketFailed => 'Could not open UDP socket.';

  @override
  String devicesFound(Object count) {
    return '$count devices found';
  }

  @override
  String get sortDevices => 'Sort devices';

  @override
  String get sortFavoritesFirst => 'Favorites first';

  @override
  String get sortNameAsc => 'Name (A-Z)';

  @override
  String get sortNameDesc => 'Name (Z-A)';

  @override
  String get sortRecentlyAdded => 'Recently added';

  @override
  String get sortRecentlyWoken => 'Recently woken';

  @override
  String get sortDeviceType => 'Device type';

  @override
  String sortedBy(Object sortType) {
    return 'Sorted by: $sortType';
  }

  @override
  String get macAddressRequiredManually =>
      'MAC address must be entered manually.';

  @override
  String get scanComplete => 'Scan complete';

  @override
  String get addManually => 'Add manually';

  @override
  String get general => 'General';

  @override
  String get dataBackup => 'Data & backup';

  @override
  String get trustPrivacy => 'Trust & privacy';

  @override
  String get projectLinks => 'Project links';

  @override
  String get privacySummaryTitle => 'Privacy-first by design';

  @override
  String get privacySummaryDescription =>
      'Wakeon keeps your device configuration on your device and avoids accounts, ads, analytics, and tracking.';

  @override
  String get savedLocally => 'Saved locally';

  @override
  String get savedLocallyDescription =>
      'Device profiles are stored only on this device.';

  @override
  String get noTracking => 'No tracking';

  @override
  String get noTrackingDescription =>
      'Wakeon does not include analytics or advertising SDKs.';

  @override
  String get backupControl => 'You control backups';

  @override
  String get backupControlDescription =>
      'Backup files are created only when you choose to export them.';

  @override
  String get openSourceProject => 'Open-source project';

  @override
  String get openSourceProjectDescription =>
      'View the source code, report issues, or contribute on GitHub.';

  @override
  String get aboutWakeon => 'About Wakeon';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get appVersion => 'App version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDescription =>
      'Wakeon does not collect personal data and keeps device profiles local.';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get openSourceLicensesDescription =>
      'View licenses for Flutter and third-party packages used by Wakeon.';

  @override
  String get studioDescription =>
      'Independent apps and tools focused on simplicity, privacy, and real user value.';

  @override
  String get brandNoAds => 'No ads';

  @override
  String get brandPrivacyFirst => 'Privacy-first';

  @override
  String get brandOpenSource => 'Open source';

  @override
  String get macHelpWindowsTitle => 'Windows';

  @override
  String get macHelpWindowsCommand => 'ipconfig /all';

  @override
  String get macHelpMacosTitle => 'macOS';

  @override
  String get macHelpMacosCommand => 'ifconfig';

  @override
  String get macHelpLinuxTitle => 'Linux';

  @override
  String get macHelpLinuxCommand => 'ip link';

  @override
  String get hostnameDetected => 'Hostname detected';

  @override
  String get hostnameNotAvailable => 'Hostname not available';

  @override
  String get hostAddress => 'Host address';

  @override
  String get hostAddressHint => '192.168.1.42';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get unknown => 'Unknown';

  @override
  String get lastSeenNever => 'Last seen: never';

  @override
  String lastSeenAt(Object date) {
    return 'Last seen: $date';
  }

  @override
  String get insertDot => 'Insert dot';

  @override
  String get networkAddressHelpTitle => 'Network address help';

  @override
  String get hostAddressHelpDescription =>
      'The device IP address used to check online/offline status. It can be filled automatically from network scan results.';

  @override
  String get broadcastAddressHelpDescription =>
      'The Wake-on-LAN broadcast address used to send the magic packet. It usually ends with .255.';

  @override
  String get networkScanAutoFillDescription =>
      'If you add a device from Network Scan, Wakeon fills the host and broadcast addresses automatically when possible.';
}
