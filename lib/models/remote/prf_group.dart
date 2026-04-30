import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_group.freezed.dart';
part 'prf_group.g.dart';

@freezed
abstract class PRFGroup with _$PRFGroup {
  factory PRFGroup(
    String ulid,
    String name,
    String description,
    @JsonKey(name: 'official_whatsapp_link') String officialWhatsappLink,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  ) = _PRFGroup;

  factory PRFGroup.fromJson(Map<String, dynamic> json) =>
      _$PRFGroupFromJson(json);
}
