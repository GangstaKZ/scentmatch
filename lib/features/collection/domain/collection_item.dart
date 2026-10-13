enum CollectionType { collection, wishlist }

class CollectionItem {
  const CollectionItem(
      {required this.perfumeId,
      required this.type,
      required this.addedAt,
      this.rating = 0,
      this.note = ''});
  final String perfumeId, note;
  final CollectionType type;
  final int rating;
  final DateTime addedAt;
  Map<String, dynamic> toJson() => {
        'perfumeId': perfumeId,
        'type': type.name,
        'rating': rating,
        'note': note,
        'addedAt': addedAt.toIso8601String()
      };
  factory CollectionItem.fromJson(String id, Map<String, dynamic> json) =>
      CollectionItem(
          perfumeId: id,
          type: CollectionType.values.byName(json['type'] as String),
          addedAt: DateTime.parse(json['addedAt'] as String),
          rating: (json['rating'] as num).toInt(),
          note: json['note'] as String? ?? '');
}
