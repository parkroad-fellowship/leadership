import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_mission_subscription_dto.freezed.dart';
part 'prf_mission_subscription_dto.g.dart';

@freezed
abstract class PRFMissionSubscriptionDTO with _$PRFMissionSubscriptionDTO {
  factory PRFMissionSubscriptionDTO({
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    @JsonKey(name: 'member_ulid') required String memberUlid,
    String? notes,
  }) = _PRFMissionSubscriptionDTO;

  factory PRFMissionSubscriptionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionSubscriptionDTOFromJson(json);
}
