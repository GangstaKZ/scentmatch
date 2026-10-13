/// Demo is deliberately explicit: a Firebase initialization failure never
/// silently switches an authenticated user to a different data store.
abstract final class AppConfig {
  static const firebase = bool.fromEnvironment('USE_FIREBASE');
  static const emulator = bool.fromEnvironment('USE_EMULATORS');
  static const emulatorHost =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');
  static const remoteRecommendations =
      bool.fromEnvironment('USE_REMOTE_RECOMMENDATIONS');
  static const revenueCatAndroid =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const revenueCatIos = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const affiliateBase = String.fromEnvironment('AFFILIATE_BASE_URL');
}
