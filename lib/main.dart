import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final preferences = await SharedPreferences.getInstance();
    if (AppConfig.firebase) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      if (AppConfig.emulator) {
        await FirebaseAuth.instance
            .useAuthEmulator(AppConfig.emulatorHost, 9099);
        FirebaseFirestore.instance
            .useFirestoreEmulator(AppConfig.emulatorHost, 8080);
        FirebaseFunctions.instanceFor(region: 'europe-west1')
            .useFunctionsEmulator(AppConfig.emulatorHost, 5001);
        await FirebaseStorage.instance
            .useStorageEmulator(AppConfig.emulatorHost, 9199);
      } else {
        // Register App Check providers before enforcing them on the server.
        const webKey = String.fromEnvironment('APP_CHECK_WEB_KEY');
        if (!kIsWeb || webKey.isNotEmpty) {
          await FirebaseAppCheck.instance.activate(
              webProvider: kIsWeb ? ReCaptchaV3Provider(webKey) : null,
              androidProvider: kDebugMode
                  ? AndroidProvider.debug
                  : AndroidProvider.playIntegrity,
              appleProvider: kDebugMode
                  ? AppleProvider.debug
                  : AppleProvider.appAttestWithDeviceCheckFallback);
        }
      }
    }
    runApp(ProviderScope(
        overrides: [preferencesProvider.overrideWithValue(preferences)],
        child: const ScentMatchApp()));
  } catch (error, stack) {
    if (kDebugMode) {
      debugPrint('Bootstrap failed: ${error.runtimeType}\n$stack');
    }
    runApp(const BootstrapFailure());
  }
}

class BootstrapFailure extends StatelessWidget {
  const BootstrapFailure({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
      home: Scaffold(
          body: Center(
              child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cloud_off_outlined, size: 48),
                    SizedBox(height: 20),
                    Text(
                        'Не удалось запустить ScentMatch. Проверьте настройки Firebase и подключение.\n\nUnable to start. Check Firebase configuration and connection.',
                        textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    FilledButton(
                        onPressed: main, child: Text('Повторить / Retry'))
                  ])))));
}
