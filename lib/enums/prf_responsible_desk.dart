import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFResponsibleDesk {
  @JsonValue(1)
  chairperson,
  @JsonValue(2)
  viceChairperson,
  @JsonValue(3)
  organisingSecretary,
  @JsonValue(4)
  missions,
  @JsonValue(5)
  prayer,
  @JsonValue(6)
  followUp,
  @JsonValue(7)
  music,
  @JsonValue(8)
  treasurer
  ;

  int get apiKey {
    switch (this) {
      case PRFResponsibleDesk.chairperson:
        return 1;
      case PRFResponsibleDesk.viceChairperson:
        return 2;
      case PRFResponsibleDesk.organisingSecretary:
        return 3;
      case PRFResponsibleDesk.missions:
        return 4;
      case PRFResponsibleDesk.prayer:
        return 5;
      case PRFResponsibleDesk.followUp:
        return 6;
      case PRFResponsibleDesk.music:
        return 7;
      case PRFResponsibleDesk.treasurer:
        return 8;
    }
  }

  String get name {
    switch (this) {
      case PRFResponsibleDesk.chairperson:
        return 'Chairperson';
      case PRFResponsibleDesk.viceChairperson:
        return 'Vice Chairperson';
      case PRFResponsibleDesk.organisingSecretary:
        return 'Organising Secretary';
      case PRFResponsibleDesk.missions:
        return 'Missions Desk';
      case PRFResponsibleDesk.prayer:
        return 'Prayer Desk';
      case PRFResponsibleDesk.followUp:
        return 'Follow-up Desk';
      case PRFResponsibleDesk.music:
        return 'Music Desk';
      case PRFResponsibleDesk.treasurer:
        return 'Treasurer';
    }
  }

  static PRFResponsibleDesk fromRole(
    String role,
  ) {
    switch (role) {
      case 'chairperson':
        return PRFResponsibleDesk.chairperson;
      case 'vice chairperson':
        return PRFResponsibleDesk.viceChairperson;
      case 'organising secretary':
        return PRFResponsibleDesk.organisingSecretary;
      case 'missions secretary':
        return PRFResponsibleDesk.missions;
      case 'prayer secretary':
        return PRFResponsibleDesk.prayer;
      case 'follow-up secretary':
        return PRFResponsibleDesk.followUp;
      case 'music secretary':
        return PRFResponsibleDesk.music;
      case 'treasurer':
        return PRFResponsibleDesk.treasurer;
      default:
        throw Exception('Unknown role: $role');
    }
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
