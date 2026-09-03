import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_church_dto.freezed.dart';
part 'prf_church_dto.g.dart';

@freezed
abstract class PRFChurchDTO with _$PRFChurchDTO {
  factory PRFChurchDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFChurchDTO;

  factory PRFChurchDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFChurchDTOFromJson(json);
}
