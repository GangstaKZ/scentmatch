import 'package:cloud_functions/cloud_functions.dart';
import '../../catalog/domain/perfume.dart';
import '../domain/recommendation_engine.dart';

abstract interface class RecommendationRepository {
  Future<List<Recommendation>> recommend(
      List<Perfume> catalog, Map<String, String> quiz);
}

class LocalRecommendationRepository implements RecommendationRepository {
  @override
  Future<List<Recommendation>> recommend(
          List<Perfume> catalog, Map<String, String> quiz) async =>
      RecommendationEngine().rank(catalog, quiz);
}

class CloudRecommendationRepository implements RecommendationRepository {
  CloudRecommendationRepository(this.functions);
  final FirebaseFunctions functions;
  @override
  Future<List<Recommendation>> recommend(
      List<Perfume> catalog, Map<String, String> quiz) async {
    // Secret API keys and prompt construction belong in Cloud Functions.
    final response =
        await functions.httpsCallable('recommendPerfumes').call<dynamic>();
    final data = Map<String, dynamic>.from(response.data as Map);
    final ids = catalog.map((p) => p.id).toSet();
    return (data['recommendations'] as List)
        .map((e) {
          final value = Map<String, dynamic>.from(e as Map);
          return Recommendation(
              value['perfumeId'] as String,
              (value['score'] as num).toInt().clamp(0, 100),
              value['reason'] as String);
        })
        .where((r) => ids.contains(r.perfumeId))
        .toList();
  }
}
