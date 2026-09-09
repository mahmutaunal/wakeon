import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// Best-effort ad telemetry. Analytics must never block product behavior.
class AdAnalytics {
  FirebaseAnalytics? _analytics;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
    } catch (_) {
      // Firebase account files are intentionally optional in this scaffold.
    }
  }

  Future<void> event(
    String name, {
    required String format,
    required String placement,
    String? reason,
  }) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: <String, Object>{
          'ad_format': format,
          'placement': placement,
          'reason': ?reason,
        },
      );
    } catch (_) {
      // Ad delivery remains independent from measurement availability.
    }
  }

  Future<void> setConsentStatus(String status) async {
    try {
      await _analytics?.setUserProperty(
        name: 'ad_consent_status',
        value: status,
      );
    } catch (_) {}
  }
}
