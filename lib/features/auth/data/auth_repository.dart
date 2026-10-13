import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/config/app_config.dart';

class AuthIdentity {
  const AuthIdentity(this.id, this.name, this.email);
  final String id, name, email;
}

abstract interface class AuthRepository {
  Stream<AuthIdentity?> watch();
  Future<void> signIn(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> google();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

/// Demo is a local workspace, never fake email/Google authentication.
class DemoAuthRepository implements AuthRepository {
  @override
  Stream<AuthIdentity?> watch() =>
      Stream.value(const AuthIdentity('demo', 'Исследователь', ''));
  Never _unavailable() => throw StateError('Authentication requires Firebase');
  @override
  Future<void> signIn(String email, String password) async => _unavailable();
  @override
  Future<void> register(String name, String email, String password) async =>
      _unavailable();
  @override
  Future<void> google() async => _unavailable();
  @override
  Future<void> resetPassword(String email) async => _unavailable();
  @override
  Future<void> signOut() async {}
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this.auth);
  final FirebaseAuth auth;
  final GoogleSignIn _google = GoogleSignIn(
      scopes: ['email'],
      clientId: defaultTargetPlatform == TargetPlatform.iOS &&
              AppConfig.googleIosClientId.isNotEmpty
          ? AppConfig.googleIosClientId
          : null,
      serverClientId:
          AppConfig.googleClientId.isEmpty ? null : AppConfig.googleClientId);
  @override
  Stream<AuthIdentity?> watch() => auth.userChanges().map((u) => u == null
      ? null
      : AuthIdentity(u.uid, u.displayName ?? '', u.email ?? ''));
  @override
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await credential.user!.updateDisplayName(name.trim());
  }

  @override
  Future<void> google() async {
    if (kIsWeb) {
      await auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    final account = await _google.signIn();
    if (account == null) return;
    final token = await account.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.credential(
        accessToken: token.accessToken, idToken: token.idToken));
  }

  @override
  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  @override
  Future<void> signOut() async {
    await auth.signOut();
    if (!kIsWeb) await _google.signOut();
  }
}
