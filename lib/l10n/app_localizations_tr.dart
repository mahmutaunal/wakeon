// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Wakeon';

  @override
  String get deviceName => 'Cihaz adı';

  @override
  String get deviceNameHint => 'Masaüstü PC';

  @override
  String get macAddress => 'MAC adresi';

  @override
  String get macAddressHint => 'AA:BB:CC:DD:EE:FF';

  @override
  String get broadcastAddress => 'Broadcast adresi';

  @override
  String get broadcastAddressHint => '192.168.1.255';

  @override
  String get port => 'Port';

  @override
  String get portHint => '9';

  @override
  String get requiredFieldError => 'Bu alan zorunludur.';

  @override
  String get broadcastAddressRequired => 'Broadcast adresi zorunludur.';

  @override
  String get invalidIpv4Address => 'Geçerli bir IPv4 adresi girin.';

  @override
  String get macAddressRequired => 'MAC adresi zorunludur.';

  @override
  String get invalidMacAddress => 'Geçerli bir MAC adresi girin.';

  @override
  String get invalidPort => 'Invalid port.';

  @override
  String get portRangeError => 'Port 1 ile 65535 arasında olmalıdır.';

  @override
  String get updateDeviceProfileDescription =>
      'Bu Wake-on-LAN cihaz profilini güncelle.';

  @override
  String get addDeviceProfileDescription =>
      'Bu cihazdan uyandırmak istediğin cihazu ekle.';

  @override
  String get howToFindMacAddress => 'MAC adresini nasıl bulursun?';

  @override
  String get windowsCommandPromptInstruction =>
      'Uyandırmak istediğiniz cihazın MAC adresini bulun. Komut İstemi’ni aç ve şunu çalıştır:';

  @override
  String get usePhysicalAddressInstruction =>
      'Ethernet bağdaştırıcının Fiziksel Adres değerini kullan.';

  @override
  String get edit => 'Düzenle';

  @override
  String wakePacketSent(Object deviceName) {
    return '$deviceName cihazına uyandırma paketi gönderildi.';
  }

  @override
  String couldNotWakeDevice(Object deviceName, Object error) {
    return '$deviceName uyandırılamadı: $error';
  }

  @override
  String get deleteDeviceQuestion => 'Cihaz silinsin mi?';

  @override
  String deviceWillBeRemoved(Object deviceName) {
    return '$deviceName Wakeon\'dan kaldırılacak.';
  }

  @override
  String deviceDeleted(Object deviceName) {
    return '$deviceName silindi.';
  }

  @override
  String get neverWoken => 'Hiç uyandırılmadı';

  @override
  String lastWake(Object date) {
    return 'Son uyandırma: $date';
  }

  @override
  String deviceNetworkAddress(Object address, Object port) {
    return '$address · Port $port';
  }

  @override
  String deviceWithIp(Object ip) {
    return 'Cihaz $ip';
  }

  @override
  String get unknownDevice => 'Bilinmeyen cihaz';

  @override
  String get scanningLocalNetwork => 'Yerel ağ taranıyor...';

  @override
  String get scanMayTakeSeconds => 'Bu işlem birkaç saniye sürebilir.';

  @override
  String get noDevicesFound => 'Cihaz bulunamadı';

  @override
  String get noDevicesFoundDescription =>
      'Bazı cihazlar keşfi engelleyebilir. Bilgisayarını yine de manuel olarak ekleyebilirsin.';

  @override
  String get scanAgain => 'Tekrar tara';

  @override
  String get scanFailed => 'Tarama başarısız oldu';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get localNetwork => 'Yerel ağ';

  @override
  String get recommended => 'Önerilen';

  @override
  String get localNetworkDescription =>
      'Wakeon, telefonun ve bilgisayarın aynı yerel ağa bağlı olduğunda en iyi şekilde çalışır.';

  @override
  String get vpnMode => 'VPN modu';

  @override
  String get bestForRemoteWake => 'Uzaktan uyandırma için en iyisi';

  @override
  String get vpnModeDescription =>
      'Ev ağına geri bağlanmak için WireGuard, Tailscale, ZeroTier veya yönlendiricinin VPN özelliğini kullan. Ardından Wakeon\'u normal şekilde kullan.';

  @override
  String get routerWakeMode => 'Yönlendirici uyandırma modu';

  @override
  String get routerDependent => 'Yönlendiriciye bağlı';

  @override
  String get routerWakeModeDescription =>
      'Bazı yönlendiriciler yerleşik Wake-on-LAN özelliği sunar. Yönlendiricin destekliyorsa bilgisayarını yönetim panelinden uyandırabilirsin.';

  @override
  String get advancedWanMode => 'Gelişmiş WAN modu';

  @override
  String get notRecommended => 'Önerilmez';

  @override
  String get advancedWanModeDescription =>
      'Genel IP, port yönlendirme, statik DHCP kiralaması ve IP-MAC eşleştirmesi gerekebilir. Bu yöntem büyük ölçüde yönlendiricine ve internet sağlayıcına bağlıdır.';

  @override
  String get wakeFromAnotherNetwork => 'Başka bir ağdan uyandır';

  @override
  String get remoteWakeIntroDescription =>
      'Wake-on-LAN yerel ağlar için tasarlanmıştır. Uzaktan uyandırma mümkündür ancak en güvenli ve en güvenilir yöntem ev ağına VPN ile bağlanmaktır.';

  @override
  String get remoteWakeSecurityWarning =>
      'Bilgisayarını doğrudan internete açmaktan kaçın. Mümkün olduğunda VPN tabanlı erişimi tercih et.';

  @override
  String get remoteWakeGuideDescription =>
      'Cihazları başka bir ağdan nasıl uyandırabileceğini öğren.';

  @override
  String get appTagline =>
      'AlpWare Studio tarafından geliştirilen basit Wake-on-LAN uygulaması';

  @override
  String get noAds => 'Reklam yok';

  @override
  String get noAdsDescription => 'Wakeon reklam içermez.';

  @override
  String get noAccount => 'Hesap yok';

  @override
  String get noAccountDescription => 'Oturum açma veya bulut hesabı gerekmez.';

  @override
  String get localOnly => 'Tamamen yerel';

  @override
  String get localOnlyDescription =>
      'Kaydedilen cihazlar yalnızca cihazında saklanır.';

  @override
  String get openSource => 'Açık kaynak';

  @override
  String get openSourceDescription =>
      'Basit, şeffaf ve topluluk dostu olacak şekilde geliştirilmiştir.';

  @override
  String get github => 'GitHub';

  @override
  String get addDevice => 'Cihaz ekle';

  @override
  String get editDevice => 'Cihazı düzenle';

  @override
  String get saveDevice => 'Cihazı kaydet';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get wake => 'Uyandır';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'İptal';

  @override
  String get scanNetwork => 'Ağı tara';

  @override
  String get settings => 'Ayarlar';

  @override
  String get remoteWakeGuide => 'Uzaktan uyandırma rehberi';

  @override
  String get noDevicesYet => 'Henüz cihaz yok';

  @override
  String get noDevicesDescription =>
      'İlk bilgisayarını ekle ve tek dokunuşla uyandır.';

  @override
  String get deviceType => 'Cihaz türü';

  @override
  String get deviceTypeDesktop => 'Masaüstü';

  @override
  String get deviceTypeLaptop => 'Dizüstü';

  @override
  String get deviceTypeServer => 'Sunucu';

  @override
  String get deviceTypeNas => 'NAS';

  @override
  String get deviceTypeRouter => 'Yönlendirici';

  @override
  String get deviceTypeOther => 'Diğer';

  @override
  String get testSetup => 'Kurulumu test et';

  @override
  String deviceConfigurationLooksGood(Object deviceName) {
    return '$deviceName yapılandırması iyi görünüyor.';
  }

  @override
  String deviceConfigurationFailed(Object deviceName, Object error) {
    return '$deviceName yapılandırması başarısız oldu: $error';
  }

  @override
  String get exportBackup => 'Yedeği dışa aktar';

  @override
  String get exportBackupDescription =>
      'Cihazlarınızı JSON yedek dosyası olarak kaydedin.';

  @override
  String get importBackup => 'Yedeği içe aktar';

  @override
  String get importBackupDescription =>
      'Wakeon JSON yedek dosyasından cihazları geri yükleyin.';

  @override
  String get backupExported => 'Yedek dışa aktarıldı.';

  @override
  String couldNotExportBackup(Object error) {
    return 'Yedek dışa aktarılamadı: $error';
  }

  @override
  String get importCancelled => 'İçe aktarma iptal edildi.';

  @override
  String devicesImported(Object count) {
    return '$count cihaz içe aktarıldı.';
  }

  @override
  String couldNotImportBackup(Object error) {
    return 'Yedek içe aktarılamadı: $error';
  }

  @override
  String get exportCancelled => 'Dışa aktarma iptal edildi.';

  @override
  String get noDevicesToExport => 'Dışa aktarılacak cihaz yok.';

  @override
  String get favorites => 'Favoriler';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get removeFromFavorites => 'Favorilerden çıkar';

  @override
  String get searchDevices => 'Cihazlarda ara';

  @override
  String get noSearchResults => 'Sonuç bulunamadı';

  @override
  String noSearchResultsDescription(Object query) {
    return '“$query” ile eşleşen cihaz bulunamadı.';
  }

  @override
  String get invalidBroadcastAddress => 'Invalid broadcast address.';

  @override
  String get udpSocketFailed => 'Could not open UDP socket.';

  @override
  String devicesFound(Object count) {
    return '$count cihaz bulundu';
  }

  @override
  String get sortDevices => 'Cihazları sırala';

  @override
  String get sortFavoritesFirst => 'Favoriler önce';

  @override
  String get sortNameAsc => 'İsim (A-Z)';

  @override
  String get sortNameDesc => 'İsim (Z-A)';

  @override
  String get sortRecentlyAdded => 'Son eklenenler';

  @override
  String get sortRecentlyWoken => 'Son uyandırılanlar';

  @override
  String get sortDeviceType => 'Cihaz türü';

  @override
  String sortedBy(Object sortType) {
    return 'Sıralama: $sortType';
  }

  @override
  String get macAddressRequiredManually => 'MAC adresi manuel girilmelidir.';

  @override
  String get scanComplete => 'Tarama tamamlandı';

  @override
  String get addManually => 'Manuel ekle';

  @override
  String get general => 'Genel';

  @override
  String get dataBackup => 'Veri ve yedekleme';

  @override
  String get trustPrivacy => 'Güven ve gizlilik';

  @override
  String get projectLinks => 'Proje bağlantıları';

  @override
  String get privacySummaryTitle => 'Gizlilik odaklı tasarım';

  @override
  String get privacySummaryDescription =>
      'Wakeon cihaz yapılandırmalarınızı cihazınızda tutar; hesap, reklam, analiz ve takip sistemleri kullanmaz.';

  @override
  String get savedLocally => 'Yerel olarak saklanır';

  @override
  String get savedLocallyDescription =>
      'Cihaz profilleri yalnızca bu cihazda saklanır.';

  @override
  String get noTracking => 'Takip yok';

  @override
  String get noTrackingDescription =>
      'Wakeon analiz veya reklam SDK\'ları içermez.';

  @override
  String get backupControl => 'Yedekler sizin kontrolünüzde';

  @override
  String get backupControlDescription =>
      'Yedek dosyaları yalnızca siz dışa aktarmayı seçtiğinizde oluşturulur.';

  @override
  String get openSourceProject => 'Açık kaynak proje';

  @override
  String get openSourceProjectDescription =>
      'Kaynak kodu görüntüleyin, hata bildirin veya GitHub üzerinden katkı sağlayın.';

  @override
  String get aboutWakeon => 'Wakeon hakkında';

  @override
  String versionLabel(Object version) {
    return 'Sürüm $version';
  }

  @override
  String get appVersion => 'Uygulama sürümü';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get privacyPolicyDescription =>
      'Wakeon kişisel veri toplamaz ve cihaz profillerini yerel olarak saklar.';

  @override
  String get openSourceLicenses => 'Açık kaynak lisansları';

  @override
  String get openSourceLicensesDescription =>
      'Wakeon tarafından kullanılan Flutter ve üçüncü taraf paket lisanslarını görüntüleyin.';

  @override
  String get studioDescription =>
      'Sadelik, gizlilik ve gerçek kullanıcı değeri odağında bağımsız uygulamalar ve araçlar.';

  @override
  String get brandNoAds => 'Reklam yok';

  @override
  String get brandPrivacyFirst => 'Gizlilik odaklı';

  @override
  String get brandOpenSource => 'Açık kaynak';

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
  String get hostnameDetected => 'Cihaz adı algılandı';

  @override
  String get hostnameNotAvailable => 'Cihaz adı bulunamadı';

  @override
  String get hostAddress => 'Host adresi';

  @override
  String get hostAddressHint => '192.168.1.42';

  @override
  String get online => 'Çevrimiçi';

  @override
  String get offline => 'Çevrimdışı';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get lastSeenNever => 'Son görülme: hiç';

  @override
  String lastSeenAt(Object date) {
    return 'Son görülme: $date';
  }

  @override
  String get insertDot => 'Nokta ekle';

  @override
  String get networkAddressHelpTitle => 'Ağ adresi yardımı';

  @override
  String get hostAddressHelpDescription =>
      'Çevrimiçi/çevrimdışı durumunu kontrol etmek için kullanılan cihaz IP adresidir. Ağ taraması sonucundan otomatik doldurulabilir.';

  @override
  String get broadcastAddressHelpDescription =>
      'Magic packet göndermek için kullanılan Wake-on-LAN broadcast adresidir. Genellikle .255 ile biter.';

  @override
  String get networkScanAutoFillDescription =>
      'Cihazı Ağ Taraması üzerinden eklerseniz Wakeon mümkün olduğunda host ve broadcast adreslerini otomatik doldurur.';
}
