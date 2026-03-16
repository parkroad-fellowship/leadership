import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFResponsibleDesk {
  @JsonValue(1)
  chairperson(1, 'Chairperson', 'chairperson'),
  @JsonValue(2)
  viceChairperson(2, 'Vice Chairperson', 'vice chairperson'),
  @JsonValue(3)
  organisingSecretary(3, 'Organising Secretary', 'organising secretary'),
  @JsonValue(4)
  missions(4, 'Missions Desk', 'missions secretary'),
  @JsonValue(5)
  prayer(5, 'Prayer Desk', 'prayer secretary'),
  @JsonValue(6)
  followUp(6, 'Follow-up Desk', 'follow-up secretary'),
  @JsonValue(7)
  music(7, 'Music Desk', 'music secretary'),
  @JsonValue(8)
  treasurer(8, 'Treasurer', 'treasurer'),
  ;

  const PRFResponsibleDesk(this.apiKey, this._label, this.roleKey);

  final int apiKey;
  final String _label;
  final String roleKey;

  String get name => _label;

  static PRFResponsibleDesk fromRole(String role) {
    return PRFResponsibleDesk.values.firstWhere(
      (v) => v.roleKey == role,
      orElse: () => throw Exception('Unknown role: $role'),
    );
  }

  static List<PRFResponsibleDesk> fromRoles(List<String> roles) {
    return roles
        .map((role) {
          try {
            return fromRole(role);
          } catch (e) {
            return null;
          }
        })
        .whereType<PRFResponsibleDesk>()
        .toList();
  }

  static List<int> apiKeys(List<PRFResponsibleDesk> desks) {
    return desks.map((desk) => desk.apiKey).toList();
  }
}
