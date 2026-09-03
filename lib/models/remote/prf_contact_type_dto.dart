import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_contact_type_dto.freezed.dart';
part 'prf_contact_type_dto.g.dart';

@freezed
abstract class PRFContactTypeDTO with _$PRFContactTypeDTO {
  factory PRFContactTypeDTO({
    required String name,
  }) = _PRFContactTypeDTO;

  factory PRFContactTypeDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFContactTypeDTOFromJson(json);
}
