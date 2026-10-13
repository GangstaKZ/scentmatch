import '../../catalog/domain/perfume.dart';

class Recommendation {
  const Recommendation(this.perfumeId, this.score, this.reason);
  final String perfumeId;

  /// Heuristic match score, not a probability or an AI confidence metric.
  final int score;
  final String reason;
}

class RecommendationEngine {
  List<Recommendation> rank(List<Perfume> catalog, Map<String, String> quiz) {
    final ranked = catalog.map((p) {
      var points = 0;
      if (p.family == quiz['family']) points += 35;
      if (p.gender == quiz['gender'] ||
          p.gender == 'unisex' ||
          quiz['gender'] == 'any') points += 15;
      if (p.priceRange == quiz['budget']) points += 20;
      if (p.season.contains(quiz['season'])) points += 15;
      final longevity = p.longevity >= 8
          ? 'long'
          : p.longevity >= 4
              ? 'medium'
              : 'light';
      if (longevity == quiz['longevity']) points += 10;
      final mood = quiz['mood'];
      if ((mood == 'bold' && ['woody', 'amber'].contains(p.family)) ||
          (mood == 'romantic' && p.family == 'floral') ||
          (mood == 'calm' && p.family == 'fresh') ||
          mood == 'day' ||
          mood == 'evening') points += 5;
      return Recommendation(p.id, points, 'local');
    }).toList();
    ranked.sort((a, b) {
      final score = b.score.compareTo(a.score);
      return score != 0 ? score : a.perfumeId.compareTo(b.perfumeId);
    });
    // Age is saved for the profile, but is not used to infer taste.
    return ranked.take(6).toList();
  }
}
