import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_mission_offline_member_dto.freezed.dart';
part 'prf_mission_offline_member_dto.g.dart';

@freezed
abstract class PRFMissionOfflineMemberDTO with _$PRFMissionOfflineMemberDTO {
  factory PRFMissionOfflineMemberDTO({
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    required String name,
    required String phone,
  }) = _PRFMissionOfflineMemberDTO;

  factory PRFMissionOfflineMemberDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionOfflineMemberDTOFromJson(json);
}
