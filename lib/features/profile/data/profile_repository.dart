import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/data/local_store.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> load(AuthIdentity identity);
  Future<void> saveQuiz(String uid, Map<String, String> answers);
}

class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this.store);
  final LocalStore store;
  @override
  Future<UserProfile> load(AuthIdentity identity) async {
    final json = store.read('profile_${identity.id}');
    if (json != null) return UserProfile.fromJson(identity.id, json);
    final profile = UserProfile(
        id: identity.id,
        name: identity.name,
        email: identity.email,
        createdAt: DateTime.now());
    await store.write('profile_${identity.id}', profile.toJson());
    return profile;
  }

  @override
  Future<void> saveQuiz(String uid, Map<String, String> answers) async {
    final json = store.read('profile_$uid');
    if (json == null) throw StateError('Profile missing');
    await store.write('profile_$uid',
        UserProfile.fromJson(uid, json).withQuiz(answers).toJson());
  }
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this.db);
  final FirebaseFirestore db;
  @override
  Future<UserProfile> load(AuthIdentity identity) async {
    final doc = db.collection('users').doc(identity.id);
    // A transaction prevents racing loads from resetting quiz/subscription state.
    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        // Auth emits the new account before updateDisplayName completes.
        // Fill that initial empty name without overwriting an existing profile.
        if ((data['name'] as String? ?? '').isEmpty &&
            identity.name.trim().isNotEmpty) {
          transaction.update(doc, {'name': identity.name.trim()});
          return UserProfile.fromJson(
              identity.id, {...data, 'name': identity.name.trim()});
        }
        return UserProfile.fromJson(identity.id, data);
      }
      final profile = UserProfile(
          id: identity.id,
          name: identity.name,
          email: identity.email,
          createdAt: DateTime.now().toUtc());
      transaction.set(doc, profile.toJson());
      return profile;
    });
  }

  @override
  Future<void> saveQuiz(String uid, Map<String, String> answers) =>
      db.collection('users').doc(uid).update({'quizAnswers': answers});
}
