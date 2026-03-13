class PRFSchoolTerm {
  const PRFSchoolTerm({
    required this.ulid,
    required this.name,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFSchoolTerm.fromJson(Map<String, dynamic> json) {
    return PRFSchoolTerm(
      ulid: (json['ulid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? json['term'] ?? 'Unknown term')
          .toString(),
      isActive: (json['is_active'] as num?)?.toInt(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String name;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
