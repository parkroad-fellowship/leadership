import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionRole {
  @JsonValue(1)
  member,
  @JsonValue(2)
  leader,
  @JsonValue(3)
  assistant,
  @JsonValue(4)
  discipleshipTrainer,
  @JsonValue(5)
  musicInstruments,
  @JsonValue(6)
  transportation
  ;

  String get name {
    switch (this) {
      case PRFMissionRole.member:
        return 'Member';
      case PRFMissionRole.leader:
        return 'Mission Leader';
      case PRFMissionRole.assistant:
        return 'Assistant Mission Leader';
      case PRFMissionRole.discipleshipTrainer:
        return 'Discipleship Trainer';
      case PRFMissionRole.musicInstruments:
        return 'Music Instruments';
      case PRFMissionRole.transportation:
        return 'Transportation';
    }
  }
}
