import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/enums/prf_institution_type.dart';

part 'prf_class_group.freezed.dart';
part 'prf_class_group.g.dart';

@freezed
abstract class PRFClassGroup with _$PRFClassGroup {
  factory PRFClassGroup(
    String ulid,
    String name,
    @JsonKey(name: 'institution_type') PRFInstitutionType institutionType,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFClassGroup;

  factory PRFClassGroup.fromJson(Map<String, dynamic> json) =>
      _$PRFClassGroupFromJson(json);
}

@freezed
abstract class PRFClassGroupResponse with _$PRFClassGroupResponse {
  factory PRFClassGroupResponse(List<PRFClassGroup> data) =
      _PRFClassGroupResponse;

  factory PRFClassGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFClassGroupResponseFromJson(json);
}
