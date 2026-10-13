class Perfume {
  const Perfume(
      {required this.id,
      required this.name,
      required this.brand,
      required this.family,
      required this.gender,
      required this.priceRange,
      required this.price,
      required this.longevity,
      required this.sillage,
      required this.season,
      required this.notes,
      required this.similarPerfumes,
      required this.color,
      this.imageUrl = '',
      this.popularity = 0});
  final String id, name, brand, family, gender, priceRange, sillage, imageUrl;
  final int price, longevity, color, popularity;
  final List<String> season, similarPerfumes;
  final Map<String, List<String>> notes;
  factory Perfume.fromJson(String id, Map<String, dynamic> json) => Perfume(
      id: id,
      name: json['name'] as String,
      brand: json['brand'] as String,
      family: json['family'] as String,
      gender: json['gender'] as String,
      priceRange: json['priceRange'] as String,
      price: (json['price'] as num).toInt(),
      longevity: (json['longevity'] as num).toInt(),
      sillage: json['sillage'] as String,
      season: List<String>.from(json['season'] as List),
      notes: (json['notes'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, List<String>.from(v as List))),
      similarPerfumes: List<String>.from(json['similarPerfumes'] as List),
      color: (json['color'] as num?)?.toInt() ?? 0xFFD4B98B,
      imageUrl: json['imageUrl'] as String? ?? '',
      popularity: (json['popularity'] as num?)?.toInt() ?? 0);
}
