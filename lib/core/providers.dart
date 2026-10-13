import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'data/local_store.dart';
import 'services/analytics_service.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/catalog/data/catalog_repository.dart';
import '../features/catalog/domain/perfume.dart';
import '../features/collection/data/collection_repository.dart';
import '../features/collection/domain/collection_item.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/reviews/data/reviews_repository.dart';
import '../features/reviews/domain/review.dart';
import '../features/recommendations/data/recommendation_repository.dart';
import '../features/recommendations/domain/recommendation_engine.dart';
import '../features/subscription/data/subscription_repository.dart';

final preferencesProvider = Provider<SharedPreferences>(
    (ref) => throw StateError('Override at bootstrap'));
final localStoreProvider =
    Provider((ref) => LocalStore(ref.watch(preferencesProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AppConfig.firebase
        ? FirebaseAuthRepository(FirebaseAuth.instance)
        : DemoAuthRepository());
final identityProvider =
    StreamProvider((ref) => ref.watch(authRepositoryProvider).watch());
final profileRepositoryProvider = Provider<ProfileRepository>((ref) =>
    AppConfig.firebase
        ? FirestoreProfileRepository(FirebaseFirestore.instance)
        : LocalProfileRepository(ref.watch(localStoreProvider)));
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final identity = await ref.watch(identityProvider.future);
  if (identity == null) return null;
  return repository.load(identity);
});
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) =>
    AppConfig.firebase
        ? FirestoreCatalogRepository(FirebaseFirestore.instance)
        : SeedCatalogRepository());
final catalogProvider = FutureProvider<List<Perfume>>(
    (ref) => ref.watch(catalogRepositoryProvider).load());
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) =>
    AppConfig.firebase
        ? FirestoreCollectionRepository(FirebaseFirestore.instance)
        : LocalCollectionRepository(ref.watch(localStoreProvider)));
final collectionProvider = FutureProvider<List<CollectionItem>>((ref) async {
  final repository = ref.watch(collectionRepositoryProvider);
  final identity = await ref.watch(identityProvider.future);
  if (identity == null) return [];
  return repository.load(identity.id);
});
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) =>
    AppConfig.firebase
        ? FirestoreReviewsRepository(FirebaseFirestore.instance)
        : LocalReviewsRepository(ref.watch(localStoreProvider)));
final reviewsProvider = FutureProvider.family<List<Review>, String>(
    (ref, id) => ref.watch(reviewsRepositoryProvider).load(id));
final recommendationRepositoryProvider = Provider<RecommendationRepository>(
    (ref) => AppConfig.firebase && AppConfig.remoteRecommendations
        ? CloudRecommendationRepository(
            FirebaseFunctions.instanceFor(region: 'europe-west1'))
        : LocalRecommendationRepository());
final recommendationsProvider =
    FutureProvider<List<Recommendation>>((ref) async {
  // Watch AsyncValue as well as its future so a late upstream completion
  // rebuilds this provider instead of retaining an obsolete pending future.
  final profileState = ref.watch(profileProvider);
  final catalogState = ref.watch(catalogProvider);
  final profileFuture = profileState.hasValue
      ? Future.value(profileState.requireValue)
      : ref.watch(profileProvider.future);
  final catalogFuture = catalogState.hasValue
      ? Future.value(catalogState.requireValue)
      : ref.watch(catalogProvider.future);
  final repository = ref.watch(recommendationRepositoryProvider);
  final profile = await profileFuture;
  final catalog = await catalogFuture;
  if (profile == null || !profile.quizComplete) return [];
  return repository.recommend(catalog, profile.quizAnswers);
});
final analyticsProvider = Provider((ref) =>
    AnalyticsService(AppConfig.firebase ? FirebaseAnalytics.instance : null));
final subscriptionProvider = Provider((ref) => SubscriptionRepository());
final actionsProvider = Provider((ref) => UserActions(ref));

class UserActions {
  UserActions(this.ref);
  final Ref ref;
  String get uid =>
      ref.read(identityProvider).valueOrNull?.id ??
      (throw StateError('Sign in required'));
  Future<void> saveQuiz(Map<String, String> answers) async {
    if (answers.length != 7) {
      throw ArgumentError('Complete all seven questions');
    }
    await ref.read(profileRepositoryProvider).saveQuiz(uid, answers);
    ref.invalidate(profileProvider);
    await ref.read(analyticsProvider).event('quiz_completed');
  }

  Future<void> saveItem(CollectionItem item) async {
    await ref.read(collectionRepositoryProvider).save(uid, item);
    ref.invalidate(collectionProvider);
    await ref.read(analyticsProvider).event('collection_saved',
        {'type': item.type.name, 'perfume_id': item.perfumeId});
  }

  Future<void> removeItem(String id) async {
    await ref.read(collectionRepositoryProvider).remove(uid, id);
    ref.invalidate(collectionProvider);
  }

  Future<void> review(String perfumeId, String text, int rating) async {
    if (text.trim().isEmpty || text.length > 2000 || rating < 1 || rating > 5) {
      throw ArgumentError('Invalid review');
    }
    // One review per user and fragrance, editable without duplicate submissions.
    await ref.read(reviewsRepositoryProvider).save(
        perfumeId,
        Review(
            id: uid,
            userId: uid,
            text: text.trim(),
            rating: rating,
            createdAt: DateTime.now().toUtc()));
    ref.invalidate(reviewsProvider(perfumeId));
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class AppSettings {
  const AppSettings(
      {this.dark = true, this.locale = 'ru', this.welcomeSeen = false});
  final bool dark, welcomeSeen;
  final String locale;
}

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(preferencesProvider);
    return AppSettings(
        dark: prefs.getBool('dark') ?? true,
        locale: prefs.getString('locale') ?? 'ru',
        welcomeSeen: prefs.getBool('welcomeSeen') ?? false);
  }

  Future<void> update({bool? dark, String? locale, bool? welcomeSeen}) async {
    final next = AppSettings(
        dark: dark ?? state.dark,
        locale: locale ?? state.locale,
        welcomeSeen: welcomeSeen ?? state.welcomeSeen);
    final prefs = ref.read(preferencesProvider);
    await prefs.setBool('dark', next.dark);
    await prefs.setString('locale', next.locale);
    await prefs.setBool('welcomeSeen', next.welcomeSeen);
    state = next;
  }
}
