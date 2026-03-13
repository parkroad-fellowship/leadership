import 'package:leadership/models/remote/prf_member.dart';

class PRFMissionSubscription {
  const PRFMissionSubscription({
    required this.ulid,
    required this.missionUlid,
    required this.memberUlid,
    this.member,
    this.createdAt,
    this.updatedAt,
  });

  factory PRFMissionSubscription.fromJson(Map<String, dynamic> json) {
    final memberJson = json['member'];

    return PRFMissionSubscription(
      ulid: (json['ulid'] ?? '').toString(),
      missionUlid: (json['mission_ulid'] ?? '').toString(),
      memberUlid: (json['member_ulid'] ?? '').toString(),
      member: memberJson is Map<String, dynamic>
          ? PRFMember.fromJson(memberJson)
          : null,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  final String ulid;
  final String missionUlid;
  final String memberUlid;
  final PRFMember? member;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final name = member?.fullName.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return memberUlid;
  }
}
