import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_marital_status_dto.freezed.dart';
part 'prf_marital_status_dto.g.dart';

@freezed
abstract class PRFMaritalStatusDTO with _$PRFMaritalStatusDTO {
  factory PRFMaritalStatusDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFMaritalStatusDTO;

  factory PRFMaritalStatusDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMaritalStatusDTOFromJson(json);
}
