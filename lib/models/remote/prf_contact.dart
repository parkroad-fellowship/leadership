import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';

part 'prf_contact.freezed.dart';
part 'prf_contact.g.dart';

@freezed
abstract class PRFContact with _$PRFContact {
  factory PRFContact(
    String ulid,
    String name,
    String phone,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    String? email,
    @JsonKey(name: 'contact_type') PRFContactType? contactType,
  }) = _PRFContact;

  factory PRFContact.fromJson(Map<String, dynamic> json) =>
      _$PRFContactFromJson(json);
}

@freezed
abstract class PRFContactResponse with _$PRFContactResponse {
  factory PRFContactResponse(
    List<PRFContact> data,
  ) = _PRFContactResponse;

  factory PRFContactResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFContactResponseFromJson(json);
}
