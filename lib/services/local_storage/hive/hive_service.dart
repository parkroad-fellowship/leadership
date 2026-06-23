import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/hive/hive_registrar.g.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/local/adapters.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/allocation_entry_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/expense_category_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/kv/auth_hive_service.dart';
import 'package:leadership/services/local_storage/hive/kv/settings_hive_service.dart';
import 'package:leadership/utils/_index.dart';

class HiveService {
  factory HiveService() => instance ??= HiveService._();
  HiveService._();

  static HiveService? instance;
  static const String _binaryAdapterMigrationMarker =
      'hive_binary_adapter_migration_v1';
  static const String _migrationMetaBoxName = 'hive_migration_meta';

  // ----- Auth / settings boxes -----

  late final AuthHiveService _auth;
  late final SettingsHiveService _settings;

    // ----- Entity CRUD services -----

  late final AllocationEntryHiveDbService _allocationEntries;
  late final ExpenseCategoryHiveDbService _expenseCategories;
  late final RequisitionHiveDbService _requisitions;


  AuthHiveService get auth => _auth;
  SettingsHiveService get settings => _settings;

  AllocationEntryHiveDbService get allocationEntries => _allocationEntries;
  ExpenseCategoryHiveDbService get expenseCategories => _expenseCategories;
  RequisitionHiveDbService get requisitions => _requisitions;



  // ----- Initialisation -----

  Future<void> initBoxes() async {
    await Hive.initFlutter();

    // Register generated adapters.
    Hive.registerAdapters();

    final appBoxName = PRFLeadershipConfig.instance!.values.hiveBox;
    final globalAuthBoxName =
        PRFLeadershipConfig.instance!.values.globalHiveAuthBox;

    final cipher = _buildCipher();

    await _runLegacyAdapterMigrationIfNeeded(
      appBoxName: appBoxName,
      globalAuthBoxName: globalAuthBoxName,
    );

    // Open auth/settings boxes.
    await _openBoxSafe(appBoxName, cipher: cipher);
    await _openBoxSafe(globalAuthBoxName, cipher: cipher);

    // Initialize auth/settings sub-services.
    _auth = AuthHiveService();
    _settings = SettingsHiveService();

    // Instantiate entity CRUD services.
    _allocationEntries = AllocationEntryHiveDbService();
    _expenseCategories = ExpenseCategoryHiveDbService();
    _requisitions = RequisitionHiveDbService();

    // Open all entity boxes with the shared cipher.
    final entityBoxNames = [
      _allocationEntries.boxName,
      _expenseCategories.boxName,
      _requisitions.boxName,

    ];

    for (final name in entityBoxNames) {
      await _openBoxSafe(name, cipher: cipher);
    }
  }

  HiveAesCipher? _buildCipher() {
    final key = PRFLeadershipConfig.instance!.values.hiveEncryptionKey;
    if (key.isEmpty) {
      return null;
    }

    try {
      final decodedKey = base64Decode(key);
      return HiveAesCipher(Uint8List.fromList(decodedKey));
    } catch (_) {
      // Fallback for plain-text keys: derive a stable 32-byte key.
    }

    final hashedKey = sha256.convert(utf8.encode(key)).bytes;
    return HiveAesCipher(Uint8List.fromList(hashedKey));
  }

  Future<Box<dynamic>> _openBoxSafe(
    String name, {
    HiveAesCipher? cipher,
  }) async {
    try {
      return await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    } catch (_) {
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<dynamic>(name, encryptionCipher: cipher);
    }
  }

  Future<void> _runLegacyAdapterMigrationIfNeeded({
    required String appBoxName,
    required String globalAuthBoxName,
  }) async {
    final migrationBox = await _openBoxSafe(_migrationMetaBoxName);
    final hasMigrated =
        migrationBox.get(_binaryAdapterMigrationMarker) as bool? ?? false;
    if (hasMigrated) {
      await migrationBox.close();
      return;
    }

    // Legacy adapters used JSON-string payloads. Generated adapters use
    // binary fields, so reset once before opening app/global boxes.
    if (await Hive.boxExists(appBoxName)) {
      await Hive.deleteBoxFromDisk(appBoxName);
    }

    if (await Hive.boxExists(globalAuthBoxName)) {
      await Hive.deleteBoxFromDisk(globalAuthBoxName);
    }

    await migrationBox.put(_binaryAdapterMigrationMarker, true);
    await migrationBox.close();
  }

  // ----- Entity table management -----

  /// Wipes all entity boxes. Called on sign-out to clear user data.
  Future<void> clearAllTables() async {
    final services = <BaseHiveDbService<dynamic>>[];
    for (final s in services) {
      await s.clearAll();
    }
  }

  // Convenience methods that delegate to appropriate services
  void clearPrefs() {
    _auth.clearAuthData();
  }

  void clearBox() {
    _auth.clear();
  }

  // Member-related convenience methods
  PRFMember? retrieveMember() {
    return _auth.retrieveProfile()?.member;
  }

  List<String> get memberRoles {
    return _auth.roles;
  }

  List<PRFResponsibleDesk> get responsibleDesks => PRFResponsibleDesk.fromRoles(
    _auth.roles,
  );
}
