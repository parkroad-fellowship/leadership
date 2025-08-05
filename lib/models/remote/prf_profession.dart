import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_profession.freezed.dart';
part 'prf_profession.g.dart';

@freezed
abstract class PRFProfession with _$PRFProfession {
  factory PRFProfession(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') int isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFProfession;

  factory PRFProfession.fromJson(Map<String, dynamic> json) =>
      _$PRFProfessionFromJson(json);
}
