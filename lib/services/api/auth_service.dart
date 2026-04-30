import 'dart:convert';

import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class AuthService extends BaseAPIService<PRFUser> {
  @override
  String get endpoint => '/auth';

  @override
  PRFUser createFromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
      'AuthService does not support single responses yet.',
    );
  }

  @override
  List<PRFUser> createListFromResponse(Map<String, dynamic> response) {
    throw UnimplementedError(
      'AuthService does not support list responses yet.',
    );
  }

  Future<String> signIn({required SignInDTO signInDTO}) async {
    try {
      final response = await networkUtil.post(
        '$endpoint/login',
        body: json.encode(signInDTO.toJson()),
      );

      return response['token'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<PRFUser> getUser() async {
    try {
      final response = await networkUtil.get(
        '$endpoint/me',
        queryParameters: <String, dynamic>{
          'include':
              'roles.permissions,member.groupMembers.group,student,'
              'member.memberships.spiritualYear,member.profilePicture',
        },
      );

      return PRFUser.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> socialLogin({required SocialAuthDTO socialAuthDTO}) async {
    try {
      final response = await networkUtil.post(
        '$endpoint/social-leader-login',
        body: json.encode(socialAuthDTO.toJson()),
      );

      return response['token'] as String;
    } catch (e) {
      rethrow;
    }
  }

  Future<PRFUser> updateProfile({required UserUpdateDTO updateDTO}) async {
    try {
      final response = await networkUtil.post(
        '$endpoint/update-profile',
        body: json.encode(updateDTO.toJson()),
      );

      return PRFUser.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
