import 'package:leadership/enums/prf_theme_mode.dart';
import 'package:leadership/services/local_storage/hive/_base_hive_service.dart';
import 'package:leadership/utils/_index.dart';

class SettingsHiveService extends BaseHiveService {
  @override
  String get boxName => PRFLeadershipConfig.instance!.values.globalHiveAuthBox;

  void toggleNotifications({required bool enable}) {
    put('notificationsEnabled', enable);
  }

  bool areNotificationsEnabled() {
    return get<bool>('notificationsEnabled') ?? true;
  }

  void setPermissionRequested({required bool requested}) {
    put('permissionRequested', requested);
  }

  bool hasPermissionBeenRequested() {
    return get<bool>('permissionRequested') ?? false;
  }

  void setThemeMode(PRFThemeMode themeMode) {
    put('themeMode', themeMode.name);
  }

  PRFThemeMode getThemeMode() {
    final themeModeName = get<String>('themeMode') ?? PRFThemeMode.system.name;
    return PRFThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeName,
      orElse: () => PRFThemeMode.system,
    );
  }
}
