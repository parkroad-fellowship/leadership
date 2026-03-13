class PRFMissionDebriefNote {
  const PRFMissionDebriefNote({
    required this.ulid,
    required this.note,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFMissionDebriefNote.fromJson(Map<String, dynamic> json) {
    return PRFMissionDebriefNote(
      ulid: (json['ulid'] ?? '').toString(),
      note: (json['note'] ?? json['body'] ?? '').toString(),
      category: (json['category'] ?? json['type'])?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String note;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
