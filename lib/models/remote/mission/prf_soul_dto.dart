import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_soul_dto.freezed.dart';
part 'prf_soul_dto.g.dart';

@freezed
abstract class PRFSoulDTO with _$PRFSoulDTO {
  factory PRFSoulDTO({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'mission_ulid') required String missionUlid,
    @JsonKey(name: 'class_group_ulid') required String classGroupUlid,
    @JsonKey(name: 'decision_type', includeIfNull: false)
    required int decisionType,
    @JsonKey(name: 'admission_number') String? admissionNumber,
    String? notes,
  }) = _PRFSoulDTO;

  factory PRFSoulDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFSoulDTOFromJson(json);
}
