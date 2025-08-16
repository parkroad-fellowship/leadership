import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_mission_type.freezed.dart';
part 'prf_mission_type.g.dart';

@freezed
abstract class PRFMissionType with _$PRFMissionType {
  factory PRFMissionType(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') int isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFMissionType;

  factory PRFMissionType.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionTypeFromJson(json);
}
