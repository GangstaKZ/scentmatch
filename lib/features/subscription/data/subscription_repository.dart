import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_config.dart';

/// Prepared adapter. The MVP paywall does not initiate a payment or grant Pro.
/// Firestore isPro must be updated only by a verified server webhook.
class SubscriptionRepository {
  bool _configured = false;
  bool get supported =>
      !kIsWeb &&
      [TargetPlatform.android, TargetPlatform.iOS]
          .contains(defaultTargetPlatform);
  Future<void> configure(String userId) async {
    if (!supported) return;
    final key = defaultTargetPlatform == TargetPlatform.iOS
        ? AppConfig.revenueCatIos
        : AppConfig.revenueCatAndroid;
    if (key.isEmpty) return;
    if (_configured) {
      await Purchases.logIn(userId);
      return;
    }
    await Purchases.configure(PurchasesConfiguration(key)..appUserID = userId);
    _configured = true;
  }

  Future<Offerings> offerings() async {
    if (!_configured) throw StateError('RevenueCat is not configured');
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> restore() async {
    if (!_configured) throw StateError('RevenueCat is not configured');
    return Purchases.restorePurchases();
  }

  Future<void> signOut() async {
    if (_configured) await Purchases.logOut();
  }
}
