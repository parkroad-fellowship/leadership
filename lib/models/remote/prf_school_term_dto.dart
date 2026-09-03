import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_school_term_dto.freezed.dart';
part 'prf_school_term_dto.g.dart';

@freezed
abstract class PRFSchoolTermDTO with _$PRFSchoolTermDTO {
  factory PRFSchoolTermDTO({
    required String name,
    required int year,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus? isActive,
  }) = _PRFSchoolTermDTO;

  factory PRFSchoolTermDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFSchoolTermDTOFromJson(json);
}
