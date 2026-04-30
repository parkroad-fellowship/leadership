import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_member.dart';

// Generated model files
part 'auth.g.dart'; // Needed for toJson, fromJson
part 'auth.freezed.dart';

@freezed
abstract class SignInDTO with _$SignInDTO {
  factory SignInDTO({required String email, required String password}) =
      _SignInDTO;

  factory SignInDTO.fromJson(Map<String, dynamic> json) =>
      _$SignInDTOFromJson(json);
}

@freezed
abstract class PRFUser with _$PRFUser {
  factory PRFUser({
    required String ulid,
    required String name,
    required String email,
    required String timezone,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<PRFRole> roles,
    PRFMember? member,
  }) = _PRFUser;

  factory PRFUser.fromJson(Map<String, dynamic> json) =>
      _$PRFUserFromJson(json);
}

@freezed
abstract class PRFRole with _$PRFRole {
  factory PRFRole({
    required String name,
    required List<PRFPermission> permissions,
  }) = _PRFRole;

  factory PRFRole.fromJson(Map<String, dynamic> json) =>
      _$PRFRoleFromJson(json);
}

@freezed
abstract class PRFPermission with _$PRFPermission {
  factory PRFPermission({required String name}) = _PRFPermission;

  factory PRFPermission.fromJson(Map<String, dynamic> json) =>
      _$PRFPermissionFromJson(json);
}

@freezed
abstract class SocialAuthDTO with _$SocialAuthDTO {
  factory SocialAuthDTO({
    required String provider,
    @JsonKey(name: 'access_token') required String accessToken,
  }) = _SocialAuthDTO;

  factory SocialAuthDTO.fromJson(Map<String, dynamic> json) =>
      _$SocialAuthDTOFromJson(json);
}

@freezed
abstract class UserUpdateDTO with _$UserUpdateDTO {
  factory UserUpdateDTO({
    @JsonKey(includeIfNull: false) String? timezone,
    @JsonKey(name: 'fcm_tokens', includeIfNull: false) List<String>? fcmTokens,
  }) = _UserUpdateDTO;

  factory UserUpdateDTO.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateDTOFromJson(json);
}
