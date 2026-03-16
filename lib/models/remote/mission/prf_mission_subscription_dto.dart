import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_mission_role.dart';
import 'package:leadership/enums/prf_mission_subscription_status.dart';

part 'prf_mission_subscription_dto.freezed.dart';
part 'prf_mission_subscription_dto.g.dart';

@freezed
abstract class PRFMissionSubscriptionDTO with _$PRFMissionSubscriptionDTO {
  factory PRFMissionSubscriptionDTO({
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    @JsonKey(name: 'member_ulid') required String memberUlid,
    String? notes,
    PRFMissionSubscriptionStatus? status,
    @JsonKey(name: 'mission_role') PRFMissionRole? missionRole,
  }) = _PRFMissionSubscriptionDTO;

  factory PRFMissionSubscriptionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSubscriptionDTOFromJson(json);
}
