import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';

part 'prf_mission_offline_member.freezed.dart';
part 'prf_mission_offline_member.g.dart';

@freezed
abstract class PRFMissionOfflineMember with _$PRFMissionOfflineMember {
  factory PRFMissionOfflineMember(
    String ulid,
    String name,
    String phone,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    PRFMission? mission,
  }) = _PRFMissionOfflineMember;

  factory PRFMissionOfflineMember.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionOfflineMemberFromJson(json);
}

@freezed
abstract class PRFMissionOfflineMembersResponse
    with _$PRFMissionOfflineMembersResponse {
  factory PRFMissionOfflineMembersResponse(
    List<PRFMissionOfflineMember> data,
  ) = _PRFMissionOfflineMembersResponse;

  factory PRFMissionOfflineMembersResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PRFMissionOfflineMembersResponseFromJson(json);
}
