import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_contact_type.freezed.dart';
part 'prf_contact_type.g.dart';

@freezed
abstract class PRFContactType with _$PRFContactType {
  factory PRFContactType(
    String ulid,
    String name,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFContactType;

  factory PRFContactType.fromJson(Map<String, dynamic> json) =>
      _$PRFContactTypeFromJson(json);
}
