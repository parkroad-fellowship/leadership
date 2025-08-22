import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/local/adapters.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/local_storage/hive/auth_hive_service.dart';
import 'package:leadership/services/local_storage/hive/data_hive_service.dart';
import 'package:leadership/services/local_storage/hive/settings_hive_service.dart';
import 'package:leadership/utils/_index.dart';

class HiveService {
  factory HiveService() => instance ??= HiveService._();
  HiveService._();

  static HiveService? instance;

  late final AuthHiveService _auth;
  late final DataHiveService _data;
  late final SettingsHiveService _settings;

  AuthHiveService get auth => _auth;
  DataHiveService get data => _data;
  SettingsHiveService get settings => _settings;

  Future<void> initBoxes() async {
    await Hive.initFlutter();

    // Register adapters
    Hive
      ..registerAdapter(PRFUserAdapter())
      ..registerAdapter(PRFExpenseCategoryResponseAdapter());

    // Open boxes
    await Hive.openBox<dynamic>(PRFLeadershipConfig.instance!.values.hiveBox);
    await Hive.openBox<dynamic>(
      PRFLeadershipConfig.instance!.values.globalHiveAuthBox,
    );

    // Initialize services & sub-services
    _auth = AuthHiveService();
    _settings = SettingsHiveService();

    _data = DataHiveService();
    _data.initialize();
  }

  // Convenience methods that delegate to appropriate services
  void clearPrefs() {
    _auth.clearAuthData();
    _data.clearDataCache();
  }

  void clearBox() {
    _auth.clear();
    _data.clear();
  }

  // Member-related convenience methods
  PRFMember? retrieveMember() {
    return _auth.retrieveProfile()?.member;
  }

  List<String> retrieveMemberGroupUlids() {
    return retrieveMember()!.groupMembers
            ?.map((groupMember) => groupMember.group!.ulid)
            .toList() ??
        [];
  }

  List<String> get memberRoles {
    return _auth.roles;
  }

  List<PRFResponsibleDesk> get responsibleDesks => PRFResponsibleDesk.fromRoles(
    _auth.roles,
  );
}
