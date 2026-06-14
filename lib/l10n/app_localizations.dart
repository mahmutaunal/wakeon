import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Wakeon'**
  String get appName;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Desktop PC'**
  String get deviceNameHint;

  /// No description provided for @macAddress.
  ///
  /// In en, this message translates to:
  /// **'MAC address'**
  String get macAddress;

  /// No description provided for @macAddressHint.
  ///
  /// In en, this message translates to:
  /// **'AA:BB:CC:DD:EE:FF'**
  String get macAddressHint;

  /// No description provided for @broadcastAddress.
  ///
  /// In en, this message translates to:
  /// **'Broadcast address'**
  String get broadcastAddress;

  /// No description provided for @broadcastAddressHint.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.255'**
  String get broadcastAddressHint;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @portHint.
  ///
  /// In en, this message translates to:
  /// **'9'**
  String get portHint;

  /// No description provided for @requiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredFieldError;

  /// No description provided for @broadcastAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Broadcast address is required.'**
  String get broadcastAddressRequired;

  /// No description provided for @invalidIpv4Address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IPv4 address.'**
  String get invalidIpv4Address;

  /// No description provided for @macAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'MAC address is required.'**
  String get macAddressRequired;

  /// No description provided for @invalidMacAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid MAC address.'**
  String get invalidMacAddress;

  /// No description provided for @invalidPort.
  ///
  /// In en, this message translates to:
  /// **'Invalid port.'**
  String get invalidPort;

  /// No description provided for @portRangeError.
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1 and 65535.'**
  String get portRangeError;

  /// No description provided for @updateDeviceProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Update this Wake-on-LAN device profile.'**
  String get updateDeviceProfileDescription;

  /// No description provided for @addDeviceProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a device you want to wake from this device.'**
  String get addDeviceProfileDescription;

  /// No description provided for @howToFindMacAddress.
  ///
  /// In en, this message translates to:
  /// **'How to find your MAC address'**
  String get howToFindMacAddress;

  /// No description provided for @windowsCommandPromptInstruction.
  ///
  /// In en, this message translates to:
  /// **'Find the MAC address of the device you want to wake. Open Command Prompt and run:'**
  String get windowsCommandPromptInstruction;

  /// No description provided for @usePhysicalAddressInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use the MAC address (Physical Address) of your Ethernet adapter. On macOS use \'ifconfig\', and on Linux use \'ip link\' to find it.'**
  String get usePhysicalAddressInstruction;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @wakePacketSent.
  ///
  /// In en, this message translates to:
  /// **'Wake packet sent to {deviceName}.'**
  String wakePacketSent(Object deviceName);

  /// No description provided for @couldNotWakeDevice.
  ///
  /// In en, this message translates to:
  /// **'Could not wake {deviceName}: {error}'**
  String couldNotWakeDevice(Object deviceName, Object error);

  /// No description provided for @deleteDeviceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete device?'**
  String get deleteDeviceQuestion;

  /// No description provided for @deviceWillBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{deviceName} will be removed from Wakeon.'**
  String deviceWillBeRemoved(Object deviceName);

  /// No description provided for @deviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'{deviceName} deleted.'**
  String deviceDeleted(Object deviceName);

  /// No description provided for @neverWoken.
  ///
  /// In en, this message translates to:
  /// **'Never woken'**
  String get neverWoken;

  /// No description provided for @lastWake.
  ///
  /// In en, this message translates to:
  /// **'Last wake: {date}'**
  String lastWake(Object date);

  /// No description provided for @deviceNetworkAddress.
  ///
  /// In en, this message translates to:
  /// **'{address} · Port {port}'**
  String deviceNetworkAddress(Object address, Object port);

  /// No description provided for @deviceWithIp.
  ///
  /// In en, this message translates to:
  /// **'Device {ip}'**
  String deviceWithIp(Object ip);

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get unknownDevice;

  /// No description provided for @scanningLocalNetwork.
  ///
  /// In en, this message translates to:
  /// **'Scanning your local network...'**
  String get scanningLocalNetwork;

  /// No description provided for @scanMayTakeSeconds.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds.'**
  String get scanMayTakeSeconds;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @noDevicesFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Some devices may block discovery. You can still add your computer manually.'**
  String get noDevicesFoundDescription;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed'**
  String get scanFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @localNetwork.
  ///
  /// In en, this message translates to:
  /// **'Local network'**
  String get localNetwork;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @localNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Wakeon works best when your phone and computer are connected to the same local network.'**
  String get localNetworkDescription;

  /// No description provided for @vpnMode.
  ///
  /// In en, this message translates to:
  /// **'VPN mode'**
  String get vpnMode;

  /// No description provided for @bestForRemoteWake.
  ///
  /// In en, this message translates to:
  /// **'Best for remote wake'**
  String get bestForRemoteWake;

  /// No description provided for @vpnModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use WireGuard, Tailscale, ZeroTier, or your router VPN to connect back to your home network. Then use Wakeon normally.'**
  String get vpnModeDescription;

  /// No description provided for @routerWakeMode.
  ///
  /// In en, this message translates to:
  /// **'Router wake mode'**
  String get routerWakeMode;

  /// No description provided for @routerDependent.
  ///
  /// In en, this message translates to:
  /// **'Router dependent'**
  String get routerDependent;

  /// No description provided for @routerWakeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Some routers include a built-in Wake-on-LAN feature. If your router supports it, you can wake your computer from the router panel.'**
  String get routerWakeModeDescription;

  /// No description provided for @advancedWanMode.
  ///
  /// In en, this message translates to:
  /// **'Advanced WAN mode'**
  String get advancedWanMode;

  /// No description provided for @notRecommended.
  ///
  /// In en, this message translates to:
  /// **'Not recommended'**
  String get notRecommended;

  /// No description provided for @advancedWanModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Public IP, port forwarding, static DHCP lease, and IP-MAC binding may be required. This depends heavily on your router and ISP.'**
  String get advancedWanModeDescription;

  /// No description provided for @wakeFromAnotherNetwork.
  ///
  /// In en, this message translates to:
  /// **'Wake from another network'**
  String get wakeFromAnotherNetwork;

  /// No description provided for @remoteWakeIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Wake-on-LAN was designed for local networks. Remote wake is possible, but the safest and most reliable method is using a VPN into your home network.'**
  String get remoteWakeIntroDescription;

  /// No description provided for @remoteWakeSecurityWarning.
  ///
  /// In en, this message translates to:
  /// **'Avoid exposing your computer directly to the internet. Prefer VPN-based access whenever possible.'**
  String get remoteWakeSecurityWarning;

  /// No description provided for @remoteWakeGuideDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn how to wake devices from another network.'**
  String get remoteWakeGuideDescription;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Simple Wake-on-LAN by AlpWare Studio'**
  String get appTagline;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get noAds;

  /// No description provided for @noAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'Wakeon does not contain ads.'**
  String get noAdsDescription;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get noAccount;

  /// No description provided for @noAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'No sign in or cloud account is required.'**
  String get noAccountDescription;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnly;

  /// No description provided for @localOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Saved devices stay on your device.'**
  String get localOnlyDescription;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get openSource;

  /// No description provided for @openSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Built to be simple, transparent, and community-friendly.'**
  String get openSourceDescription;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDevice;

  /// No description provided for @editDevice.
  ///
  /// In en, this message translates to:
  /// **'Edit device'**
  String get editDevice;

  /// No description provided for @saveDevice.
  ///
  /// In en, this message translates to:
  /// **'Save device'**
  String get saveDevice;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @wake.
  ///
  /// In en, this message translates to:
  /// **'Wake'**
  String get wake;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @scanNetwork.
  ///
  /// In en, this message translates to:
  /// **'Scan network'**
  String get scanNetwork;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @remoteWakeGuide.
  ///
  /// In en, this message translates to:
  /// **'Remote wake guide'**
  String get remoteWakeGuide;

  /// No description provided for @noDevicesYet.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevicesYet;

  /// No description provided for @noDevicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first computer and wake it with one tap.'**
  String get noDevicesDescription;

  /// No description provided for @deviceType.
  ///
  /// In en, this message translates to:
  /// **'Device type'**
  String get deviceType;

  /// No description provided for @deviceTypeDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get deviceTypeDesktop;

  /// No description provided for @deviceTypeLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get deviceTypeLaptop;

  /// No description provided for @deviceTypeServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get deviceTypeServer;

  /// No description provided for @deviceTypeNas.
  ///
  /// In en, this message translates to:
  /// **'NAS'**
  String get deviceTypeNas;

  /// No description provided for @deviceTypeRouter.
  ///
  /// In en, this message translates to:
  /// **'Router'**
  String get deviceTypeRouter;

  /// No description provided for @deviceTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get deviceTypeOther;

  /// No description provided for @testSetup.
  ///
  /// In en, this message translates to:
  /// **'Test setup'**
  String get testSetup;

  /// No description provided for @deviceConfigurationLooksGood.
  ///
  /// In en, this message translates to:
  /// **'{deviceName} configuration looks good.'**
  String deviceConfigurationLooksGood(Object deviceName);

  /// No description provided for @deviceConfigurationFailed.
  ///
  /// In en, this message translates to:
  /// **'{deviceName} configuration failed: {error}'**
  String deviceConfigurationFailed(Object deviceName, Object error);

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Save your devices as a JSON backup file.'**
  String get exportBackupDescription;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @importBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore devices from a Wakeon JSON backup file.'**
  String get importBackupDescription;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported.'**
  String get backupExported;

  /// No description provided for @couldNotExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not export backup: {error}'**
  String couldNotExportBackup(Object error);

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get importCancelled;

  /// No description provided for @devicesImported.
  ///
  /// In en, this message translates to:
  /// **'{count} devices imported.'**
  String devicesImported(Object count);

  /// No description provided for @couldNotImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not import backup: {error}'**
  String couldNotImportBackup(Object error);

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get exportCancelled;

  /// No description provided for @noDevicesToExport.
  ///
  /// In en, this message translates to:
  /// **'There are no devices to export.'**
  String get noDevicesToExport;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @searchDevices.
  ///
  /// In en, this message translates to:
  /// **'Search devices'**
  String get searchDevices;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'No devices match “{query}”.'**
  String noSearchResultsDescription(Object query);

  /// No description provided for @invalidBroadcastAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid broadcast address.'**
  String get invalidBroadcastAddress;

  /// No description provided for @udpSocketFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open UDP socket.'**
  String get udpSocketFailed;

  /// No description provided for @devicesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} devices found'**
  String devicesFound(Object count);

  /// No description provided for @sortDevices.
  ///
  /// In en, this message translates to:
  /// **'Sort devices'**
  String get sortDevices;

  /// No description provided for @sortFavoritesFirst.
  ///
  /// In en, this message translates to:
  /// **'Favorites first'**
  String get sortFavoritesFirst;

  /// No description provided for @sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortNameDesc;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecentlyAdded;

  /// No description provided for @sortRecentlyWoken.
  ///
  /// In en, this message translates to:
  /// **'Recently woken'**
  String get sortRecentlyWoken;

  /// No description provided for @sortDeviceType.
  ///
  /// In en, this message translates to:
  /// **'Device type'**
  String get sortDeviceType;

  /// No description provided for @sortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sorted by: {sortType}'**
  String sortedBy(Object sortType);

  /// No description provided for @macAddressRequiredManually.
  ///
  /// In en, this message translates to:
  /// **'MAC address must be entered manually.'**
  String get macAddressRequiredManually;

  /// No description provided for @scanComplete.
  ///
  /// In en, this message translates to:
  /// **'Scan complete'**
  String get scanComplete;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get dataBackup;

  /// No description provided for @trustPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Trust & privacy'**
  String get trustPrivacy;

  /// No description provided for @projectLinks.
  ///
  /// In en, this message translates to:
  /// **'Project links'**
  String get projectLinks;

  /// No description provided for @privacySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first by design'**
  String get privacySummaryTitle;

  /// No description provided for @privacySummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Wakeon keeps your device configuration on your device and avoids accounts, ads, analytics, and tracking.'**
  String get privacySummaryDescription;

  /// No description provided for @savedLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get savedLocally;

  /// No description provided for @savedLocallyDescription.
  ///
  /// In en, this message translates to:
  /// **'Device profiles are stored only on this device.'**
  String get savedLocallyDescription;

  /// No description provided for @noTracking.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get noTracking;

  /// No description provided for @noTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Wakeon does not include analytics or advertising SDKs.'**
  String get noTrackingDescription;

  /// No description provided for @backupControl.
  ///
  /// In en, this message translates to:
  /// **'You control backups'**
  String get backupControl;

  /// No description provided for @backupControlDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup files are created only when you choose to export them.'**
  String get backupControlDescription;

  /// No description provided for @openSourceProject.
  ///
  /// In en, this message translates to:
  /// **'Open-source project'**
  String get openSourceProject;

  /// No description provided for @openSourceProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'View the source code, report issues, or contribute on GitHub.'**
  String get openSourceProjectDescription;

  /// No description provided for @aboutWakeon.
  ///
  /// In en, this message translates to:
  /// **'About Wakeon'**
  String get aboutWakeon;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Wakeon does not collect personal data and keeps device profiles local.'**
  String get privacyPolicyDescription;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @openSourceLicensesDescription.
  ///
  /// In en, this message translates to:
  /// **'View licenses for Flutter and third-party packages used by Wakeon.'**
  String get openSourceLicensesDescription;

  /// No description provided for @studioDescription.
  ///
  /// In en, this message translates to:
  /// **'Independent apps and tools focused on simplicity, privacy, and real user value.'**
  String get studioDescription;

  /// No description provided for @brandNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get brandNoAds;

  /// No description provided for @brandPrivacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first'**
  String get brandPrivacyFirst;

  /// No description provided for @brandOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get brandOpenSource;

  /// No description provided for @macHelpWindowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get macHelpWindowsTitle;

  /// No description provided for @macHelpWindowsCommand.
  ///
  /// In en, this message translates to:
  /// **'ipconfig /all'**
  String get macHelpWindowsCommand;

  /// No description provided for @macHelpMacosTitle.
  ///
  /// In en, this message translates to:
  /// **'macOS'**
  String get macHelpMacosTitle;

  /// No description provided for @macHelpMacosCommand.
  ///
  /// In en, this message translates to:
  /// **'ifconfig'**
  String get macHelpMacosCommand;

  /// No description provided for @macHelpLinuxTitle.
  ///
  /// In en, this message translates to:
  /// **'Linux'**
  String get macHelpLinuxTitle;

  /// No description provided for @macHelpLinuxCommand.
  ///
  /// In en, this message translates to:
  /// **'ip link'**
  String get macHelpLinuxCommand;

  /// No description provided for @hostnameDetected.
  ///
  /// In en, this message translates to:
  /// **'Hostname detected'**
  String get hostnameDetected;

  /// No description provided for @hostnameNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Hostname not available'**
  String get hostnameNotAvailable;

  /// No description provided for @hostAddress.
  ///
  /// In en, this message translates to:
  /// **'Host address'**
  String get hostAddress;

  /// No description provided for @hostAddressHint.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.42'**
  String get hostAddressHint;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @lastSeenNever.
  ///
  /// In en, this message translates to:
  /// **'Last seen: never'**
  String get lastSeenNever;

  /// No description provided for @lastSeenAt.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {date}'**
  String lastSeenAt(Object date);

  /// No description provided for @insertDot.
  ///
  /// In en, this message translates to:
  /// **'Insert dot'**
  String get insertDot;

  /// No description provided for @networkAddressHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Network address help'**
  String get networkAddressHelpTitle;

  /// No description provided for @hostAddressHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'The device IP address used to check online/offline status. It can be filled automatically from network scan results.'**
  String get hostAddressHelpDescription;

  /// No description provided for @broadcastAddressHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'The Wake-on-LAN broadcast address used to send the magic packet. It usually ends with .255.'**
  String get broadcastAddressHelpDescription;

  /// No description provided for @networkScanAutoFillDescription.
  ///
  /// In en, this message translates to:
  /// **'If you add a device from Network Scan, Wakeon fills the host and broadcast addresses automatically when possible.'**
  String get networkScanAutoFillDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
