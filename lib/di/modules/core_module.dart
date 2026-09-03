import 'package:get_it/get_it.dart';
import 'package:leadership/services/api/accounting_event_service.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
import 'package:leadership/services/api/auth_service.dart';
import 'package:leadership/services/api/church_service.dart';
import 'package:leadership/services/api/class_group_service.dart';
import 'package:leadership/services/api/contact_type_service.dart';
import 'package:leadership/services/api/debrief_note_service.dart';
import 'package:leadership/services/api/department_service.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/api/expense_service.dart';
import 'package:leadership/services/api/gift_service.dart';
import 'package:leadership/services/api/marital_status_service.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/services/api/mission_ground_suggestion_service.dart';
import 'package:leadership/services/api/mission_offline_member_service.dart';
import 'package:leadership/services/api/mission_question_service.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/api/mission_session_service.dart';
import 'package:leadership/services/api/mission_subscription_service.dart';
import 'package:leadership/services/api/mission_type_service.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';
import 'package:leadership/services/api/profession_service.dart';
import 'package:leadership/services/api/refund_service.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/api/school_contact_service.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/services/api/school_term_service.dart';
import 'package:leadership/services/api/soul_service.dart';
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
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/router/router.dart';

class CoreModule {
  static void register(GetIt getIt) {
    getIt
      ..registerSingleton<PRFLeadershipRouter>(PRFLeadershipRouter())
      ..registerSingleton<HiveService>(HiveService())
      ..registerSingleton<AuthService>(AuthService())
      ..registerSingleton<AccountingEventService>(AccountingEventService())
      ..registerSingleton<AllocationEntryService>(AllocationEntryService())
      ..registerSingleton<RefundService>(RefundService())
      ..registerSingleton<ExpenseCategoriesService>(ExpenseCategoriesService())
      ..registerSingleton<EventService>(EventService())
      ..registerSingleton<RequisitionService>(RequisitionService())
      ..registerSingleton<RequisitionItemService>(RequisitionItemService())
      ..registerSingleton<PaymentInstructionService>(
        PaymentInstructionService(),
      )
      ..registerSingleton<MissionService>(MissionService())
      ..registerSingleton<MissionSubscriptionService>(
        MissionSubscriptionService(),
      )
      ..registerSingleton<MissionOfflineMemberService>(
        MissionOfflineMemberService(),
      )
      ..registerSingleton<MissionTypeService>(MissionTypeService())
      ..registerSingleton<SchoolTermService>(SchoolTermService())
      ..registerSingleton<MissionQuestionService>(MissionQuestionService())
      ..registerSingleton<MissionSoulService>(MissionSoulService())
      ..registerSingleton<DebriefNoteService>(DebriefNoteService())
      ..registerSingleton<MissionGroundSuggestionService>(
        MissionGroundSuggestionService(),
      )
      ..registerSingleton<MissionSessionService>(MissionSessionService())
      ..registerSingleton<ExpenseService>(ExpenseService())
      ..registerSingleton<MemberService>(MemberService())
      ..registerSingleton<SchoolService>(SchoolService())
      ..registerSingleton<SchoolContactService>(SchoolContactService())
      ..registerSingleton<ContactTypeService>(ContactTypeService())
      ..registerSingleton<ClassGroupService>(ClassGroupService())
      ..registerSingleton<ProfessionService>(ProfessionService())
      ..registerSingleton<MaritalStatusService>(MaritalStatusService())
      ..registerSingleton<ChurchService>(ChurchService())
      ..registerSingleton<DepartmentService>(DepartmentService())
      ..registerSingleton<GiftService>(GiftService())
      ..registerSingleton<EventHiveDbService>(EventHiveDbService())
      ..registerSingleton<AllocationEntryHiveDbService>(
        AllocationEntryHiveDbService(),
      )
      ..registerSingleton<RefundHiveDbService>(RefundHiveDbService())
      ..registerSingleton<RequisitionHiveDbService>(RequisitionHiveDbService())
      ..registerSingleton<MissionHiveDbService>(MissionHiveDbService())
      ..registerSingleton<MissionQuestionHiveDbService>(
        MissionQuestionHiveDbService(),
      )
      ..registerSingleton<DebriefNoteHiveDbService>(DebriefNoteHiveDbService())
      ..registerSingleton<SoulHiveDbService>(SoulHiveDbService())
      ..registerSingleton<MissionSubscriptionHiveDbService>(
        MissionSubscriptionHiveDbService(),
      )
      ..registerSingleton<MissionOfflineMemberHiveDbService>(
        MissionOfflineMemberHiveDbService(),
      )
      ..registerSingleton<MissionSessionHiveDbService>(
        MissionSessionHiveDbService(),
      )
      ..registerSingleton<MissionTypeHiveDbService>(MissionTypeHiveDbService())
      ..registerSingleton<SchoolTermHiveDbService>(SchoolTermHiveDbService())
      ..registerSingleton<RequisitionItemHiveDbService>(
        RequisitionItemHiveDbService(),
      )
      ..registerSingleton<ExpenseCategoryHiveDbService>(
        ExpenseCategoryHiveDbService(),
      )
      ..registerSingleton<PaymentInstructionHiveDbService>(
        PaymentInstructionHiveDbService(),
      )
      ..registerSingleton<SchoolHiveDbService>(SchoolHiveDbService())
      ..registerSingleton<ContactHiveDbService>(ContactHiveDbService())
      ..registerSingleton<ContactTypeHiveDbService>(ContactTypeHiveDbService())
      ..registerSingleton<ClassGroupHiveDbService>(ClassGroupHiveDbService())
      ..registerSingleton<ProfessionHiveDbService>(ProfessionHiveDbService())
      ..registerSingleton<MaritalStatusHiveDbService>(
        MaritalStatusHiveDbService(),
      )
      ..registerSingleton<ChurchHiveDbService>(ChurchHiveDbService())
      ..registerSingleton<DepartmentHiveDbService>(DepartmentHiveDbService())
      ..registerSingleton<MemberHiveDbService>(MemberHiveDbService())
      ..registerSingleton<GiftHiveDbService>(GiftHiveDbService())
      ..registerSingleton<MissionGroundSuggestionHiveDbService>(
        MissionGroundSuggestionHiveDbService(),
      );
  }
}
