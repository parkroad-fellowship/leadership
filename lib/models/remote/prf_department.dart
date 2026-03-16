import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_department.freezed.dart';
part 'prf_department.g.dart';

@freezed
abstract class PRFDepartment with _$PRFDepartment {
  factory PRFDepartment(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFDepartment;

  factory PRFDepartment.fromJson(Map<String, dynamic> json) =>
      _$PRFDepartmentFromJson(json);
}
