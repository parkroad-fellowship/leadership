import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_mission_ground_suggestion_status.dart';
import 'package:leadership/models/remote/prf_member.dart';

part 'prf_mission_ground_suggestion.freezed.dart';
part 'prf_mission_ground_suggestion.g.dart';

@freezed
abstract class PRFMissionGroundSuggestion with _$PRFMissionGroundSuggestion {
  factory PRFMissionGroundSuggestion(
    String ulid,
    String name,
    @JsonKey(name: 'contact_person') String contactPerson,
    @JsonKey(name: 'contact_number') String contactNumber, {
    String? notes,
    @Default(PRFMissionGroundSuggestionStatus.pending)
    PRFMissionGroundSuggestionStatus status,
    PRFMember? suggestor,
  }) = _PRFMissionGroundSuggestion;

  factory PRFMissionGroundSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionGroundSuggestionFromJson(json);
}

@freezed
abstract class PRFMissionGroundSuggestionResponse
    with _$PRFMissionGroundSuggestionResponse {
  factory PRFMissionGroundSuggestionResponse(
    List<PRFMissionGroundSuggestion> data,
  ) = _PRFMissionGroundSuggestionResponse;

  factory PRFMissionGroundSuggestionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PRFMissionGroundSuggestionResponseFromJson(json);
}
