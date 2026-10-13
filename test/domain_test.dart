import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scentmatch/core/data/local_store.dart';
import 'package:scentmatch/features/catalog/domain/perfume.dart';
import 'package:scentmatch/features/catalog/domain/search_filter.dart';
import 'package:scentmatch/features/collection/data/collection_repository.dart';
import 'package:scentmatch/features/collection/domain/collection_item.dart';
import 'package:scentmatch/features/recommendations/domain/recommendation_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Perfume> catalog;
  setUp(() {
    catalog = (jsonDecode(File('assets/data/perfumes.json').readAsStringSync())
            as List)
        .map((e) => Perfume.fromJson(
            e['id'] as String, Map<String, dynamic>.from(e as Map)))
        .toList();
  });
  test('seed has 20 unique perfumes and valid related IDs', () {
    expect(catalog, hasLength(20));
    final ids = catalog.map((p) => p.id).toSet();
    expect(ids, hasLength(20));
    for (final perfume in catalog) {
      expect(perfume.notes.keys, containsAll(['top', 'middle', 'base']));
      expect(perfume.similarPerfumes.every(ids.contains), isTrue);
      expect(perfume.similarPerfumes.contains(perfume.id), isFalse);
    }
  });
  test('all search filters compose and normalize case and whitespace', () {
    const filter = SearchFilter(
        query: '  EXPLORER ',
        family: 'woody',
        brand: 'Montblanc',
        gender: 'male',
        priceRange: 'budget');
    expect(catalog.where(filter.matches).single.id, 'montblanc-explorer');
    expect(
        catalog.where(
            const SearchFilter(query: 'explorer', gender: 'female').matches),
        isEmpty);
  });
  test(
      'rank favors matching preferences, ignores age and handles empty catalog',
      () {
    const quiz = {
      'family': 'woody',
      'gender': 'male',
      'budget': 'budget',
      'season': 'summer',
      'longevity': 'medium',
      'mood': 'day',
      'age': 'any'
    };
    final engine = RecommendationEngine();
    final ranked = engine.rank(catalog, quiz);
    expect(ranked.first.perfumeId, 'montblanc-explorer');
    expect(ranked.first.score, 100);
    expect(ranked.map((r) => r.perfumeId),
        engine.rank(catalog, {...quiz, 'age': '45+'}).map((r) => r.perfumeId));
    expect(engine.rank([], quiz), isEmpty);
  });
  test('collection persists, moves between shelves and isolates users',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalCollectionRepository(LocalStore(prefs));
    final date = DateTime.utc(2026, 10, 13);
    await repo.save(
        'alice',
        CollectionItem(
            perfumeId: 'chanel-no5',
            type: CollectionType.wishlist,
            addedAt: date));
    await repo.save(
        'alice',
        CollectionItem(
            perfumeId: 'chanel-no5',
            type: CollectionType.collection,
            addedAt: date,
            rating: 4,
            note: 'Вечерний аромат'));
    final reloaded =
        await LocalCollectionRepository(LocalStore(prefs)).load('alice');
    expect(reloaded, hasLength(1));
    expect(reloaded.single.type, CollectionType.collection);
    expect(reloaded.single.rating, 4);
    expect(reloaded.single.note, 'Вечерний аромат');
    expect(await repo.load('bob'), isEmpty);
    await repo.remove('alice', 'chanel-no5');
    expect(await repo.load('alice'), isEmpty);
  });
}
