import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../domain/perfume.dart';

abstract interface class CatalogRepository {
  Future<List<Perfume>> load();
}

class SeedCatalogRepository implements CatalogRepository {
  @override
  Future<List<Perfume>> load() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/data/perfumes.json'))
            as List;
    return data
        .map((e) => Perfume.fromJson(
            e['id'] as String, Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository(this.db);
  final FirebaseFirestore db;
  @override
  Future<List<Perfume>> load() async {
    final snapshot = await db.collection('perfumes').limit(500).get();
    return snapshot.docs.map((d) => Perfume.fromJson(d.id, d.data())).toList();
  }
}
