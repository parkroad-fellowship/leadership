import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_mission_subscription_status.dart';

part 'prf_mission_subscription_update_dto.freezed.dart';
part 'prf_mission_subscription_update_dto.g.dart';

@freezed
abstract class PRFMissionSubscriptionUpdateDTO
    with _$PRFMissionSubscriptionUpdateDTO {
  factory PRFMissionSubscriptionUpdateDTO({
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    @JsonKey(name: 'member_ulid') required String memberUlid,
    required PRFMissionSubscriptionStatus status,
  }) = _PRFMissionSubscriptionUpdateDTO;

  factory PRFMissionSubscriptionUpdateDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSubscriptionUpdateDTOFromJson(json);
}
