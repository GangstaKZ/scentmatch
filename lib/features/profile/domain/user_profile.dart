class UserProfile {
  const UserProfile(
      {required this.id,
      required this.name,
      required this.email,
      required this.createdAt,
      this.quizAnswers = const {},
      this.isPro = false});
  final String id, name, email;
  final DateTime createdAt;
  final Map<String, String> quizAnswers;
  final bool isPro;
  bool get quizComplete => quizAnswers.length == 7;
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'quizAnswers': quizAnswers,
        'isPro': isPro
      };
  factory UserProfile.fromJson(String id, Map<String, dynamic> json) =>
      UserProfile(
          id: id,
          name: json['name'] as String? ?? '',
          email: json['email'] as String? ?? '',
          createdAt: DateTime.tryParse(json['createdAt'].toString()) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          quizAnswers:
              Map<String, String>.from(json['quizAnswers'] as Map? ?? {}),
          isPro: json['isPro'] == true);
  UserProfile withQuiz(Map<String, String> answers) => UserProfile(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt,
      quizAnswers: Map.unmodifiable(answers),
      isPro: isPro);
}
