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
import 'package:leadership/features/home/cubit/upload_media_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/add_event_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_past_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_payment_instruction_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_requisition_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_requisition_item_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_items_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocations_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_expense_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_missions_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_past_missions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_approval_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_closed_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_draft_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/approve_requisition_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/reject_requisition_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/cubit/request_review_cubit.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/allocation_entry_service.dart';
import 'package:leadership/services/api/allocation_service.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/expense_categories_service.dart';
import 'package:leadership/services/api/expense_service.dart';
import 'package:leadership/services/api/member_service.dart';
import 'package:leadership/services/api/mission_expenses_service.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/services/local_auth_service.dart';
import 'package:leadership/utils/router/router.dart';

final GetIt getIt = GetIt.instance;

class Singletons {
  static void setup() {
    getIt
      ..registerSingleton<PRFLeadershipRouter>(PRFLeadershipRouter())
      ..registerSingleton<HiveService>(HiveService())
      ..registerSingleton<LocalAuthService>(LocalAuthService())
      ..registerSingleton<FirebaseService>(FirebaseServiceImpl())
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
      ..registerSingleton<MissionExpensesService>(MissionExpensesService())
      ..registerSingleton<ExpenseService>(ExpenseService())
      ..registerSingleton<MemberService>(MemberService())
      ..registerSingleton<AllocationService>(AllocationService())
      ..registerSingleton<AllocationEntryService>(AllocationEntryService());
  }

  static Future<void> setupDatabases() async {
    await getIt<HiveService>().initBoxes();
  }

  static List<BlocProvider> registerCubits() {
    return <BlocProvider>[
      BlocProvider<SigninCubit>(
        create: (context) => SigninCubit(
          authService: getIt<AuthService>(),
          hiveService: getIt<HiveService>(),
          socketService: getIt<SocketService>(),
          firebaseService: getIt<FirebaseService>(),
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
        ),
      ),
      BlocProvider<GetRequisitionsCubit>(
        create: (context) => GetRequisitionsCubit(
          requisitionService: getIt<RequisitionService>(),
        ),
      ),
      BlocProvider<GetRequisitionCubit>(
        create: (context) => GetRequisitionCubit(
          requisitionService: getIt<RequisitionService>(),
        ),
      ),
      BlocProvider<CreateRequisitionCubit>(
        create: (context) => CreateRequisitionCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetRequisitionItemsCubit>(
        create: (context) => GetRequisitionItemsCubit(
          requisitionItemService: getIt<RequisitionItemService>(),
        ),
      ),
      BlocProvider<GetExpenseCategoriesCubit>(
        create: (context) => GetExpenseCategoriesCubit(
          expenseCategoriesService: getIt<ExpenseCategoriesService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<CreateRequisitionItemCubit>(
        create: (context) => CreateRequisitionItemCubit(
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
      BlocProvider<GetMissionExpenseCubit>(
        create: (context) => GetMissionExpenseCubit(
          missionExpensesService: getIt<MissionExpensesService>(),
        ),
      ),
      BlocProvider<GetMissionExpenseCubit>(
        create: (context) => GetMissionExpenseCubit(
          missionExpensesService: getIt<MissionExpensesService>(),
        ),
      ),
      BlocProvider<GetMembersCubit>(
        create: (context) => GetMembersCubit(
          memberService: getIt<MemberService>(),
        ),
      ),
      BlocProvider<RequestReviewCubit>(
        create: (context) => RequestReviewCubit(
          requisitionService: getIt<RequisitionService>(),
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
      BlocProvider<ApproveRequisitionCubit>(
        create: (context) => ApproveRequisitionCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<RejectRequisitionCubit>(
        create: (context) => RejectRequisitionCubit(
          requisitionService: getIt<RequisitionService>(),
          hiveService: getIt<HiveService>(),
        ),
      ),
      BlocProvider<GetAllocationsCubit>(
        create: (context) => GetAllocationsCubit(
          allocationService: getIt<AllocationService>(),
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
    ];
  }
}
