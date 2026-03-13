class PRFMissionSoul {
  const PRFMissionSoul({
    required this.ulid,
    required this.name,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFMissionSoul.fromJson(Map<String, dynamic> json) {
    return PRFMissionSoul(
      ulid: (json['ulid'] ?? '').toString(),
      name:
          (json['name'] ??
                  json['full_name'] ??
                  json['person_name'] ??
                  json['soul_name'] ??
                  'Unnamed soul')
              .toString(),
      note: (json['decision_note'] ?? json['note'] ?? json['description'])
          ?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String name;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
