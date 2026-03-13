import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_active_status.dart';

part 'prf_profession.freezed.dart';
part 'prf_profession.g.dart';

@freezed
abstract class PRFProfession with _$PRFProfession {
  factory PRFProfession(
    String ulid,
    String name,
    @JsonKey(name: 'is_active') @JsonEnum() PRFActiveStatus isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFProfession;

  factory PRFProfession.fromJson(Map<String, dynamic> json) =>
      _$PRFProfessionFromJson(json);
}
