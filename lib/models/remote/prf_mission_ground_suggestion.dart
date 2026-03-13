class PRFMissionGroundSuggestion {
  const PRFMissionGroundSuggestion({
    required this.ulid,
    required this.suggestion,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFMissionGroundSuggestion.fromJson(Map<String, dynamic> json) {
    return PRFMissionGroundSuggestion(
      ulid: (json['ulid'] ?? '').toString(),
      suggestion: (json['suggestion'] ?? json['body'] ?? '').toString(),
      status: json['status']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String suggestion;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
