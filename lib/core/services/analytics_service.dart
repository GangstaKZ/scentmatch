import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this.analytics);
  final FirebaseAnalytics? analytics;
  Future<void> event(String name, [Map<String, Object>? parameters]) async {
    // Telemetry failure must never prevent the primary user action.
    // Do not send email, quiz age/gender, review text or personal notes.
    try {
      await analytics?.logEvent(name: name, parameters: parameters);
    } catch (_) {/* Delivery is best effort. */}
  }
}
