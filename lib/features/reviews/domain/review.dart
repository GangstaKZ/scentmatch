class Review {
  const Review(
      {required this.id,
      required this.userId,
      required this.text,
      required this.rating,
      required this.createdAt});
  final String id, userId, text;
  final int rating;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'text': text,
        'rating': rating,
        'createdAt': createdAt.toIso8601String()
      };
  factory Review.fromJson(String id, Map<String, dynamic> json) => Review(
      id: id,
      userId: json['userId'] as String,
      text: json['text'] as String,
      rating: (json['rating'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String));
}
