import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_department_dto.freezed.dart';
part 'prf_department_dto.g.dart';

@freezed
abstract class PRFDepartmentDTO with _$PRFDepartmentDTO {
  factory PRFDepartmentDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFDepartmentDTO;

  factory PRFDepartmentDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFDepartmentDTOFromJson(json);
}
