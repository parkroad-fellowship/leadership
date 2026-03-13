import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/features/auth/cubit/google_sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/sign_in_cubit.dart';
import 'package:leadership/features/auth/cubit/social_login_cubit.dart';
import 'package:leadership/features/home/account/cubit/change_profile_picture_cubit.dart';
import 'package:leadership/features/home/account/cubit/sign_out_cubit.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/cubit/theme_cubit.dart';
import 'package:leadership/features/home/cubit/upload_media_cubit.dart';
import 'package:leadership/features/home/landing/churches/cubit/church_resource_cubit.dart';
import 'package:leadership/features/home/landing/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/event_resource_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_past_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/payment_instruction_resource_cubit.dart';
import 'package:leadership/features/home/landing/gifts/cubit/gift_resource_cubit.dart';
import 'package:leadership/features/home/landing/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/features/home/landing/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/class_group_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/debrief_note_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_ground_suggestion_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_offline_member_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_question_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_session_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_subscription_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/soul_resource_cubit.dart';
import 'package:leadership/features/home/landing/professions/cubit/profession_resource_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_approval_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_closed_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_draft_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/accounting_event_service.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
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
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/refund_resource_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/send_financial_report_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/utils/router/router.dart';

final GetIt getIt = GetIt.instance;

class Singletons {
  static void setup() {
    getIt
      ..registerSingleton<PRFLeadershipRouter>(PRFLeadershipRouter())
      ..registerSingleton<HiveService>(HiveService())
      ..registerSingleton<FirebaseService>(FirebaseServiceImpl())
      ..registerSingleton<FirebaseMessagingService>(
        FirebaseMessagingServiceImpl(),
      )
      ..registerSingleton<AuthService>(AuthService())
      ..registerSingleton<ExpenseCategoriesService>(ExpenseCategoriesService())
      ..registerSingleton<EventService>(EventService())
      ..registerSingleton<NotificationService>(NotificationServiceImpl())
      ..registerSingleton<SocketService>(SocketServiceImpl())
      ..registerSingleton<MediaService>(MediaServiceImpl())
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
      ..registerSingleton<DebriefNoteService>(
        DebriefNoteService(),
      )
      ..registerSingleton<MissionGroundSuggestionService>(
        MissionGroundSuggestionService(),
      )
      ..registerSingleton<MissionSessionService>(
        MissionSessionService(),
      )
      ..registerSingleton<ExpenseService>(ExpenseService())
      ..registerSingleton<MemberService>(MemberService())
      ..registerSingleton<AccountingEventService>(AccountingEventService())
      ..registerSingleton<AllocationEntryService>(AllocationEntryService())
      ..registerSingleton<RefundService>(RefundService())
      ..registerSingleton<SchoolService>(SchoolService())
      ..registerSingleton<SchoolContactService>(SchoolContactService())
      ..registerSingleton<ContactTypeService>(ContactTypeService())
      ..registerSingleton<ClassGroupService>(ClassGroupService())
      ..registerSingleton<ProfessionService>(ProfessionService())
      ..registerSingleton<MaritalStatusService>(MaritalStatusService())
      ..registerSingleton<ChurchService>(ChurchService())
      ..registerSingleton<DepartmentService>(DepartmentService())
      ..registerSingleton<GiftService>(GiftService());
  }

  static Future<void> setupDatabases() async {
    await getIt<HiveService>().initBoxes();
  }

  static List<BlocProvider> registerCubits() {
    return <BlocProvider>[
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(hiveService: getIt()),
      ),
      BlocProvider<SigninCubit>(
        create: (context) => SigninCubit(
          authService: getIt<AuthService>(),
          hiveService: getIt<HiveService>(),
          socketService: getIt<SocketService>(),
          firebaseMessagingService: getIt<FirebaseMessagingService>(),
        ),
      ),
      BlocProvider<SocialLoginCubit>(
        create: (context) => SocialLoginCubit(
          hiveService: getIt<HiveService>(),
          authService: getIt<AuthService>(),
        ),
      ),
      BlocProvider<GoogleSignInCubit>(
        create: (context) => GoogleSignInCubit(
          firebaseService: getIt<FirebaseService>(),
        ),
      ),
      BlocProvider<ChangeProfilePictureCubit>(
        create: (context) => ChangeProfilePictureCubit(
          mediaService: getIt<MediaService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<SignOutCubit>(
        create: (context) => SignOutCubit(
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetEventsCubit>(
        create: (context) => GetEventsCubit(
          eventService: getIt<EventService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetPastEventsCubit>(
        create: (context) => GetPastEventsCubit(
          eventService: getIt<EventService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<EventResourceCubit>(
        create: (context) => EventResourceCubit(
          eventService: getIt<EventService>(),
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<RequisitionResourceCubit>(
        create: (context) => RequisitionResourceCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<RequisitionItemResourceCubit>(
        create: (context) => RequisitionItemResourceCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
        ),
      ),
      BlocProvider<GetExpenseCategoriesCubit>(
        create: (context) => GetExpenseCategoriesCubit(
          expenseCategoriesService: getIt<ExpenseCategoriesService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<PaymentInstructionResourceCubit>(
        create: (context) => PaymentInstructionResourceCubit(
          paymentInstructionService: getIt<PaymentInstructionService>(),
        ),
      ),
      BlocProvider<MissionResourceCubit>(
        create: (context) => MissionResourceCubit(
          missionService: getIt<MissionService>(),
        ),
      ),
      BlocProvider<MissionQuestionResourceCubit>(
        create: (context) => MissionQuestionResourceCubit(
          missionQuestionService: getIt<MissionQuestionService>(),
        ),
      ),
      BlocProvider<MissionSubscriptionResourceCubit>(
        create: (context) => MissionSubscriptionResourceCubit(
          missionSubscriptionService: getIt<MissionSubscriptionService>(),
        ),
      ),
      BlocProvider<MissionOfflineMemberResourceCubit>(
        create: (context) => MissionOfflineMemberResourceCubit(
          missionOfflineMemberService: getIt<MissionOfflineMemberService>(),
        ),
      ),
      BlocProvider<MissionSessionResourceCubit>(
        create: (context) => MissionSessionResourceCubit(
          missionSessionService: getIt<MissionSessionService>(),
        ),
      ),
      BlocProvider<MissionTypeResourceCubit>(
        create: (context) => MissionTypeResourceCubit(
          missionTypeService: getIt<MissionTypeService>(),
        ),
      ),
      BlocProvider<SchoolTermResourceCubit>(
        create: (context) => SchoolTermResourceCubit(
          schoolTermService: getIt<SchoolTermService>(),
        ),
      ),
      BlocProvider<ClassGroupResourceCubit>(
        create: (context) => ClassGroupResourceCubit(
          classGroupService: getIt<ClassGroupService>(),
        ),
      ),
      BlocProvider<SoulResourceCubit>(
        create: (context) => SoulResourceCubit(
          missionSoulService: getIt<MissionSoulService>(),
        ),
      ),
      BlocProvider<DebriefNoteResourceCubit>(
        create: (context) => DebriefNoteResourceCubit(
          missionDebriefNoteService: getIt<DebriefNoteService>(),
        ),
      ),
      BlocProvider<MissionGroundSuggestionResourceCubit>(
        create: (context) => MissionGroundSuggestionResourceCubit(
          missionGroundSuggestionService:
              getIt<MissionGroundSuggestionService>(),
        ),
      ),
      BlocProvider<GetMembersCubit>(
        create: (context) => GetMembersCubit(
          memberService: getIt<MemberService>(),
        ),
      ),
      BlocProvider<GetApprovalRequisitionsCubit>(
        create: (context) => GetApprovalRequisitionsCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetClosedRequisitionsCubit>(
        create: (context) => GetClosedRequisitionsCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetDraftRequisitionsCubit>(
        create: (context) => GetDraftRequisitionsCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<AllocationEntryResourceCubit>(
        create: (context) => AllocationEntryResourceCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
          hiveService: getIt<HiveService>(),
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<RefundResourceCubit>(
        create: (context) =>
            RefundResourceCubit(refundService: getIt<RefundService>()),
      ),
      BlocProvider<SelectMediaCubit>(
        create: (context) => SelectMediaCubit(
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<UploadMediaCubit>(
        create: (context) => UploadMediaCubit(
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<SendFinancialReportCubit>(
        create: (context) => SendFinancialReportCubit(
          accountingEventService: getIt<AccountingEventService>(),
        ),
      ),
      BlocProvider<SchoolCubit>(
        create: (context) => SchoolCubit(
          schoolService: getIt<SchoolService>(),
        ),
      ),
      BlocProvider<ContactTypeCubit>(
        create: (context) => ContactTypeCubit(
          contactTypeService: getIt<ContactTypeService>(),
        ),
      ),
      BlocProvider<ContactCubit>(
        create: (context) => ContactCubit(
          schoolContactService: getIt<SchoolContactService>(),
        ),
      ),
      BlocProvider<ProfessionResourceCubit>(
        create: (context) => ProfessionResourceCubit(
          professionService: getIt<ProfessionService>(),
        ),
      ),
      BlocProvider<MaritalStatusResourceCubit>(
        create: (context) => MaritalStatusResourceCubit(
          maritalStatusService: getIt<MaritalStatusService>(),
        ),
      ),
      BlocProvider<ChurchResourceCubit>(
        create: (context) => ChurchResourceCubit(
          churchService: getIt<ChurchService>(),
        ),
      ),
      BlocProvider<MemberResourceCubit>(
        create: (context) => MemberResourceCubit(
          memberService: getIt<MemberService>(),
        ),
      ),
      BlocProvider<DepartmentResourceCubit>(
        create: (context) => DepartmentResourceCubit(
          departmentService: getIt<DepartmentService>(),
        ),
      ),
      BlocProvider<GiftResourceCubit>(
        create: (context) => GiftResourceCubit(
          giftService: getIt<GiftService>(),
        ),
      ),
    ];
  }
}
