import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFMissionGroundSuggestionStatus {
  @JsonValue(1)
  pending(1, 'Pending'),
  @JsonValue(2)
  initiatedContact(2, 'Initiated Contact'),
  @JsonValue(3)
  visitScheduled(3, 'Visit Scheduled'),
  @JsonValue(4)
  missionScheduled(4, 'Mission Scheduled'),
  @JsonValue(5)
  completed(5, 'Completed'),
  @JsonValue(6)
  ignore(6, 'Ignore'),
  ;

  const PRFMissionGroundSuggestionStatus(this.apiKey, this._label);

  final int apiKey;
  final String _label;

  String get name => _label;
}
