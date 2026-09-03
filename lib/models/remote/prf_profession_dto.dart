import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_profession_dto.freezed.dart';
part 'prf_profession_dto.g.dart';

@freezed
abstract class PRFProfessionDTO with _$PRFProfessionDTO {
  factory PRFProfessionDTO({
    required String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFProfessionDTO;

  factory PRFProfessionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFProfessionDTOFromJson(json);
}
