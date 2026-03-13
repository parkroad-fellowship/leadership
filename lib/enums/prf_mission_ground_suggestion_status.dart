import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionGroundSuggestionStatus {
  @JsonValue(1)
  pending,
  @JsonValue(2)
  initiatedContact,
  @JsonValue(3)
  visitScheduled,
  @JsonValue(4)
  missionScheduled,
  @JsonValue(5)
  completed,
  @JsonValue(6)
  ignore
  ;

  String get name {
    switch (this) {
      case PRFMissionGroundSuggestionStatus.pending:
        return 'Pending';
      case PRFMissionGroundSuggestionStatus.initiatedContact:
        return 'Initiated Contact';
      case PRFMissionGroundSuggestionStatus.visitScheduled:
        return 'Visit Scheduled';
      case PRFMissionGroundSuggestionStatus.missionScheduled:
        return 'Mission Scheduled';
      case PRFMissionGroundSuggestionStatus.completed:
        return 'Completed';
      case PRFMissionGroundSuggestionStatus.ignore:
        return 'Ignore';
    }
  }

  int get apiKey {
    switch (this) {
      case PRFMissionGroundSuggestionStatus.pending:
        return 1;
      case PRFMissionGroundSuggestionStatus.initiatedContact:
        return 2;
      case PRFMissionGroundSuggestionStatus.visitScheduled:
        return 3;
      case PRFMissionGroundSuggestionStatus.missionScheduled:
        return 4;
      case PRFMissionGroundSuggestionStatus.completed:
        return 5;
      case PRFMissionGroundSuggestionStatus.ignore:
        return 6;
    }
  }
}
