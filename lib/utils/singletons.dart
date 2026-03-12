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
import 'package:leadership/features/home/landing/desk_activities/cubit/add_event_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_past_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_payment_instruction_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_missions_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_past_missions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_approval_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_closed_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_draft_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/accounting_event_service.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
import 'package:leadership/services/api/contact_type_service.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/api/expense_service.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';
import 'package:leadership/services/api/refund_service.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/api/school_contact_service.dart';
import 'package:leadership/services/api/school_service.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/shared_views/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/add_mission_refund_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/delete_allocation_entry_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/delete_receipt_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/edit_allocation_entry_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/shared_views/expenses/cubit/send_financial_report_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/delete_requisition_item_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/get_requisition_item_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/update_requisition_cubit.dart';
import 'package:leadership/shared_views/requisitions/cubit/update_requisition_item_cubit.dart';
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
      ..registerSingleton<ExpenseService>(ExpenseService())
      ..registerSingleton<MemberService>(MemberService())
      ..registerSingleton<AccountingEventService>(AccountingEventService())
      ..registerSingleton<AllocationEntryService>(AllocationEntryService())
      ..registerSingleton<RefundService>(RefundService())
      ..registerSingleton<SchoolService>(SchoolService())
      ..registerSingleton<SchoolContactService>(SchoolContactService())
      ..registerSingleton<ContactTypeService>(ContactTypeService());
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
      BlocProvider<AddEventCubit>(
        create: (context) => AddEventCubit(
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

      BlocProvider<UpdateRequisitionCubit>(
        create: (context) => UpdateRequisitionCubit(
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
      BlocProvider<UpdateRequisitionItemCubit>(
        create: (context) => UpdateRequisitionItemCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
        ),
      ),
      BlocProvider<DeleteRequisitionItemCubit>(
        create: (context) => DeleteRequisitionItemCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
        ),
      ),
      BlocProvider<GetRequisitionItemCubit>(
        create: (context) => GetRequisitionItemCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
        ),
      ),
      BlocProvider<CreatePaymentInstructionCubit>(
        create: (context) => CreatePaymentInstructionCubit(
          paymentInstructionService: getIt<PaymentInstructionService>(),
        ),
      ),
      BlocProvider<GetMissionsCubit>(
        create: (context) => GetMissionsCubit(
          missionService: getIt<MissionService>(),
        ),
      ),
      BlocProvider<GetPastMissionsCubit>(
        create: (context) => GetPastMissionsCubit(
          missionService: getIt<MissionService>(),
        ),
      ),
      BlocProvider<GetMissionCubit>(
        create: (context) => GetMissionCubit(
          missionService: getIt<MissionService>(),
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
      BlocProvider<GetAllocationEntriesCubit>(
        create: (context) => GetAllocationEntriesCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
        ),
      ),
      BlocProvider<AddAllocationEntryCubit>(
        create: (context) => AddAllocationEntryCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
          hiveService: getIt<HiveService>(),
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<EditAllocationEntryCubit>(
        create: (context) => EditAllocationEntryCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
          hiveService: getIt<HiveService>(),
          mediaService: getIt<MediaService>(),
        ),
      ),
      BlocProvider<DeleteAllocationEntryCubit>(
        create: (context) => DeleteAllocationEntryCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
        ),
      ),
      BlocProvider<AddMissionRefundCubit>(
        create: (context) =>
            AddMissionRefundCubit(refundService: getIt<RefundService>()),
      ),
      BlocProvider<DeleteReceiptCubit>(
        create: (context) => DeleteReceiptCubit(
          allocationEntryService: getIt<AllocationEntryService>(),
        ),
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
    ];
  }
}
