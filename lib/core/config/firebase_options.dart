import 'package:firebase_core/firebase_core.dart';

/// No secrets or fabricated project credentials. Supply platform-specific
/// public config via --dart-define-from-file (see config/firebase.example.json).
/// Alternatively replace this file using `flutterfire configure`.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const project = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if ([apiKey, appId, sender, project].any((v) => v.isEmpty)) {
      throw StateError('Firebase configuration is missing');
    }
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: sender,
      projectId: project,
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      iosClientId: String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      iosBundleId: 'com.scentmatch.scentmatch',
    );
  }
}
