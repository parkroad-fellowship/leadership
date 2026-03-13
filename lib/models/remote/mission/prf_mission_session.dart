import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/mission/prf_mission_session_transcript.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/models/remote/prf_member.dart';

part 'prf_mission_session.freezed.dart';
part 'prf_mission_session.g.dart';

@freezed
abstract class PRFMissionSession with _$PRFMissionSession {
  factory PRFMissionSession(
    String entity,
    String ulid,
    @JsonKey(name: 'starts_at') DateTime startsAt,
    @JsonKey(name: 'ends_at') DateTime endsAt,
    String notes, {
    @Default(0) int order,
    PRFMember? facilitator,
    PRFMember? speaker,
    PRFMission? mission,
    @JsonKey(name: 'class_group') PRFClassGroup? classGroup,
    @Default([])
    @JsonKey(name: 'mission_session_transcripts')
    List<PRFMissionSessionTranscript> transcripts,
  }) = _PRFMissionSession;

  factory PRFMissionSession.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSessionFromJson(json);
}

@freezed
abstract class PRFMissionSessionsResponse with _$PRFMissionSessionsResponse {
  factory PRFMissionSessionsResponse(List<PRFMissionSession> data) =
      _PRFMissionSessionsResponse;

  factory PRFMissionSessionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSessionsResponseFromJson(json);
}
