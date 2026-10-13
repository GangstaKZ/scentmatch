import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/data/local_store.dart';
import '../domain/review.dart';

abstract interface class ReviewsRepository {
  Future<List<Review>> load(String perfumeId);
  Future<void> save(String perfumeId, Review review);
}

class LocalReviewsRepository implements ReviewsRepository {
  LocalReviewsRepository(this.store);
  final LocalStore store;
  @override
  Future<List<Review>> load(String perfumeId) async =>
      (store.read('reviews_$perfumeId') ?? {})
          .entries
          .map((e) =>
              Review.fromJson(e.key, Map<String, dynamic>.from(e.value as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  @override
  Future<void> save(String perfumeId, Review review) async {
    final json = store.read('reviews_$perfumeId') ?? {};
    json[review.id] = review.toJson();
    await store.write('reviews_$perfumeId', json);
  }
}

class FirestoreReviewsRepository implements ReviewsRepository {
  FirestoreReviewsRepository(this.db);
  final FirebaseFirestore db;
  CollectionReference<Map<String, dynamic>> _items(String id) =>
      db.collection('reviews').doc(id).collection('items');
  @override
  Future<List<Review>> load(String perfumeId) async => (await _items(perfumeId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get())
      .docs
      .map((d) => Review.fromJson(d.id, d.data()))
      .toList();
  @override
  Future<void> save(String perfumeId, Review review) =>
      _items(perfumeId).doc(review.id).set(review.toJson());
}
