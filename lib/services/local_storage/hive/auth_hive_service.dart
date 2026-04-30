import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/services/local_storage/hive/_base_hive_service.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';

class AuthHiveService extends BaseHiveService {
  @override
  String get boxName => PRFLeadershipConfig.instance!.values.hiveBox;

  // Token management
  void persistToken(String token) {
    putWithExpiry('accessToken', token, const Duration(days: 3));

    // Update logout status in global box
    Hive.box<dynamic>(
      PRFLeadershipConfig.instance!.values.globalHiveAuthBox,
    ).put('isLoggedOut', false);
  }

  String? retrieveToken() {
    final token = getWithExpiry<String>('accessToken');
    if (token == null) {
      Hive.box<dynamic>(
        PRFLeadershipConfig.instance!.values.globalHiveAuthBox,
      ).put('isLoggedOut', true);
    }
    return token;
  }

  bool isLoggedOut() {
    return Hive.box<dynamic>(
              PRFLeadershipConfig.instance!.values.globalHiveAuthBox,
            ).get('isLoggedOut')
            as bool? ??
        false;
  }

  // Profile management
  void persistProfile(PRFUser profile) {
    Logger().i('Persisting profile: $profile');
    put('profile', profile);
  }

  PRFUser? retrieveProfile() {
    return get<PRFUser>('profile');
  }

  String get timezone => retrieveProfile()!.timezone;

  List<String> get roles =>
      retrieveProfile()!.roles.map((role) => role.name).toList();

  // Clear auth data
  void clearAuthData() {
    deleteAll([
      'accessToken',
      'accessToken_expiry',
      'profile',
    ]);
  }
}
