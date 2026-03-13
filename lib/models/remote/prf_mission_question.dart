class PRFMissionQuestion {
  const PRFMissionQuestion({
    required this.ulid,
    required this.question,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFMissionQuestion.fromJson(Map<String, dynamic> json) {
    return PRFMissionQuestion(
      ulid: (json['ulid'] ?? '').toString(),
      question: (json['question'] ?? json['body'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String question;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
