import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/data/local_store.dart';
import '../domain/collection_item.dart';

abstract interface class CollectionRepository {
  Future<List<CollectionItem>> load(String uid);
  Future<void> save(String uid, CollectionItem item);
  Future<void> remove(String uid, String perfumeId);
}

class LocalCollectionRepository implements CollectionRepository {
  LocalCollectionRepository(this.store);
  final LocalStore store;
  @override
  Future<List<CollectionItem>> load(String uid) async =>
      (store.read('collection_$uid') ?? {})
          .entries
          .map((e) => CollectionItem.fromJson(
              e.key, Map<String, dynamic>.from(e.value as Map)))
          .toList();
  @override
  Future<void> save(String uid, CollectionItem item) async {
    final data = store.read('collection_$uid') ?? {};
    data[item.perfumeId] = item.toJson();
    await store.write('collection_$uid', data);
  }

  @override
  Future<void> remove(String uid, String perfumeId) async {
    final data = store.read('collection_$uid') ?? {};
    data.remove(perfumeId);
    await store.write('collection_$uid', data);
  }
}

class FirestoreCollectionRepository implements CollectionRepository {
  FirestoreCollectionRepository(this.db);
  final FirebaseFirestore db;
  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      db.collection('collections').doc(uid).collection('items');
  @override
  Future<List<CollectionItem>> load(String uid) async =>
      (await _items(uid).get())
          .docs
          .map((d) => CollectionItem.fromJson(d.id, d.data()))
          .toList();
  @override
  Future<void> save(String uid, CollectionItem item) =>
      _items(uid).doc(item.perfumeId).set(item.toJson());
  @override
  Future<void> remove(String uid, String perfumeId) =>
      _items(uid).doc(perfumeId).delete();
}
