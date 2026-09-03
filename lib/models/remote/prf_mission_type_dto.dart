import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_mission_type_dto.freezed.dart';
part 'prf_mission_type_dto.g.dart';

@freezed
abstract class PRFMissionTypeDTO with _$PRFMissionTypeDTO {
  factory PRFMissionTypeDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFMissionTypeDTO;

  factory PRFMissionTypeDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionTypeDTOFromJson(json);
}
