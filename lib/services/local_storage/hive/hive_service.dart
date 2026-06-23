import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/hive/hive_registrar.g.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/allocation_entry_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/church_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/class_group_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/contact_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/contact_type_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/debrief_note_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/department_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/event_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/expense_category_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/gift_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/marital_status_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/member_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_ground_suggestion_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_offline_member_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_question_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_session_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_subscription_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_type_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/payment_instruction_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/profession_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/refund_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_item_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/school_term_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/db/soul_hive_db_service.dart';
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
  late final ChurchHiveDbService _churches;
  late final ClassGroupHiveDbService _classGroups;
  late final ContactHiveDbService _contacts;
  late final ContactTypeHiveDbService _contactTypes;
  late final DebriefNoteHiveDbService _debriefNotes;
  late final DepartmentHiveDbService _departments;
  late final EventHiveDbService _events;
  late final ExpenseCategoryHiveDbService _expenseCategories;
  late final GiftHiveDbService _gifts;
  late final MaritalStatusHiveDbService _maritalStatuses;
  late final MemberHiveDbService _members;
  late final MissionGroundSuggestionHiveDbService _missionGroundSuggestions;
  late final MissionHiveDbService _missions;
  late final MissionOfflineMemberHiveDbService _missionOfflineMembers;
  late final MissionQuestionHiveDbService _missionQuestions;
  late final MissionSessionHiveDbService _missionSessions;
  late final MissionSubscriptionHiveDbService _missionSubscriptions;
  late final MissionTypeHiveDbService _missionTypes;
  late final PaymentInstructionHiveDbService _paymentInstructions;
  late final ProfessionHiveDbService _professions;
  late final RefundHiveDbService _refunds;
  late final RequisitionHiveDbService _requisitions;
  late final RequisitionItemHiveDbService _requisitionItems;
  late final SchoolHiveDbService _schools;
  late final SchoolTermHiveDbService _schoolTerms;
  late final SoulHiveDbService _souls;

  AuthHiveService get auth => _auth;
  SettingsHiveService get settings => _settings;

  AllocationEntryHiveDbService get allocationEntries => _allocationEntries;
  ChurchHiveDbService get churches => _churches;
  ClassGroupHiveDbService get classGroups => _classGroups;
  ContactHiveDbService get contacts => _contacts;
  ContactTypeHiveDbService get contactTypes => _contactTypes;
  DebriefNoteHiveDbService get debriefNotes => _debriefNotes;
  DepartmentHiveDbService get departments => _departments;
  EventHiveDbService get events => _events;
  ExpenseCategoryHiveDbService get expenseCategories => _expenseCategories;
  GiftHiveDbService get gifts => _gifts;
  MaritalStatusHiveDbService get maritalStatuses => _maritalStatuses;
  MemberHiveDbService get members => _members;
  MissionGroundSuggestionHiveDbService get missionGroundSuggestions =>
      _missionGroundSuggestions;
  MissionHiveDbService get missions => _missions;
  MissionOfflineMemberHiveDbService get missionOfflineMembers =>
      _missionOfflineMembers;
  MissionQuestionHiveDbService get missionQuestions => _missionQuestions;
  MissionSessionHiveDbService get missionSessions => _missionSessions;
  MissionSubscriptionHiveDbService get missionSubscriptions =>
      _missionSubscriptions;
  MissionTypeHiveDbService get missionTypes => _missionTypes;
  PaymentInstructionHiveDbService get paymentInstructions =>
      _paymentInstructions;
  ProfessionHiveDbService get professions => _professions;
  RefundHiveDbService get refunds => _refunds;
  RequisitionHiveDbService get requisitions => _requisitions;
  RequisitionItemHiveDbService get requisitionItems => _requisitionItems;
  SchoolHiveDbService get schools => _schools;
  SchoolTermHiveDbService get schoolTerms => _schoolTerms;
  SoulHiveDbService get souls => _souls;

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
    _churches = ChurchHiveDbService();
    _classGroups = ClassGroupHiveDbService();
    _contacts = ContactHiveDbService();
    _contactTypes = ContactTypeHiveDbService();
    _debriefNotes = DebriefNoteHiveDbService();
    _departments = DepartmentHiveDbService();
    _events = EventHiveDbService();
    _expenseCategories = ExpenseCategoryHiveDbService();
    _gifts = GiftHiveDbService();
    _maritalStatuses = MaritalStatusHiveDbService();
    _members = MemberHiveDbService();
    _missionGroundSuggestions = MissionGroundSuggestionHiveDbService();
    _missions = MissionHiveDbService();
    _missionOfflineMembers = MissionOfflineMemberHiveDbService();
    _missionQuestions = MissionQuestionHiveDbService();
    _missionSessions = MissionSessionHiveDbService();
    _missionSubscriptions = MissionSubscriptionHiveDbService();
    _missionTypes = MissionTypeHiveDbService();
    _paymentInstructions = PaymentInstructionHiveDbService();
    _professions = ProfessionHiveDbService();
    _refunds = RefundHiveDbService();
    _requisitions = RequisitionHiveDbService();
    _requisitionItems = RequisitionItemHiveDbService();
    _schools = SchoolHiveDbService();
    _schoolTerms = SchoolTermHiveDbService();
    _souls = SoulHiveDbService();

    // Open all entity boxes with the shared cipher.
    final entityBoxNames = [
      _allocationEntries.boxName,
      _churches.boxName,
      _classGroups.boxName,
      _contacts.boxName,
      _contactTypes.boxName,
      _debriefNotes.boxName,
      _departments.boxName,
      _events.boxName,
      _expenseCategories.boxName,
      _gifts.boxName,
      _maritalStatuses.boxName,
      _members.boxName,
      _missionGroundSuggestions.boxName,
      _missions.boxName,
      _missionOfflineMembers.boxName,
      _missionQuestions.boxName,
      _missionSessions.boxName,
      _missionSubscriptions.boxName,
      _missionTypes.boxName,
      _paymentInstructions.boxName,
      _professions.boxName,
      _refunds.boxName,
      _requisitions.boxName,
      _requisitionItems.boxName,
      _schools.boxName,
      _schoolTerms.boxName,
      _souls.boxName,
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

  Future<void> clearAllTables() async {
    final services = <BaseHiveDbService<dynamic>>[
      _allocationEntries,
      _churches,
      _classGroups,
      _contacts,
      _contactTypes,
      _debriefNotes,
      _departments,
      _events,
      _expenseCategories,
      _gifts,
      _maritalStatuses,
      _members,
      _missionGroundSuggestions,
      _missions,
      _missionOfflineMembers,
      _missionQuestions,
      _missionSessions,
      _missionSubscriptions,
      _missionTypes,
      _paymentInstructions,
      _professions,
      _refunds,
      _requisitions,
      _requisitionItems,
      _schools,
      _schoolTerms,
      _souls,
    ];
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
