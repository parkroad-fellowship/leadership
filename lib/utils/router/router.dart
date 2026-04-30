import 'package:auto_route/auto_route.dart';
import 'package:leadership/utils/router/guards/auth_guard.dart';
import 'package:leadership/utils/router/router.gr.dart';

@AutoRouterConfig()
class PRFLeadershipRouter extends RootStackRouter {
  // Auth
  static const String decisionRoute = '/';
  static const String signInRoute = '/sign-in';

  // Landing
  static const String landingRoute = '/landing';
  static const String accountRoute = '/account';

  static const String deskActivitiesRoute = '/desk-activities';
  static const String deskActivityDetailsRoute = '/desk-activities/:ulid';

  static const String missionsRoute = '/missions';
  static const String missionDetailsRoute = '/missions/:ulid';

  static const String requisitionRoute =
      '/desk-activities/:ulid/requisitions/:ulid';

  static const String requisitionApprovalsRoute = '/requisition-approvals';

  static const String schools = '/schools';
  static const String schoolDetailsRoute = '/schools/:schoolUlid';
  static const String schoolContactsRoute = '/schools/:schoolUlid/contacts';

  // Settings
  static const String missionTypesRoute = '/mission-types';
  static const String schoolTermsRoute = '/school-terms';
  static const String professionsRoute = '/professions';
  static const String maritalStatusesRoute = '/marital-statuses';
  static const String churchesRoute = '/churches';
  static const String departmentsRoute = '/departments';
  static const String giftsRoute = '/gifts';

  // Members
  static const String membersRoute = '/members';
  static const String memberDetailsRoute = '/members/:memberUlid';

  @override
  List<AutoRoute> get routes => [
    // Auth
    CustomRoute<dynamic>(
      page: DecisionRoute.page,
      path: decisionRoute,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute<dynamic>(
      page: SignInRoute.page,
      path: signInRoute,
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    // Landing
    CustomRoute<dynamic>(
      page: LandingRoute.page,
      path: landingRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: AccountRoute.page,
      path: accountRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: DeskActivitiesRoute.page,
      path: deskActivitiesRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: DeskEventDetailsRoute.page,
      path: deskActivityDetailsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: RequisitionDetailsRoute.page,
      path: requisitionRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: MissionsRoute.page,
      path: missionsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: MissionsDetailsRoute.page,
      path: missionDetailsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    // Requisition Approvals
    CustomRoute<dynamic>(
      page: RequisitionApprovalsRoute.page,
      path: requisitionApprovalsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    // Schools
    CustomRoute<dynamic>(
      page: SchoolsRoute.page,
      path: schools,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: SchoolDetailsRoute.page,
      path: schoolDetailsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    // Settings
    CustomRoute<dynamic>(
      page: MissionTypesRoute.page,
      path: missionTypesRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: SchoolTermsRoute.page,
      path: schoolTermsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: ProfessionsRoute.page,
      path: professionsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: MaritalStatusesRoute.page,
      path: maritalStatusesRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: ChurchesRoute.page,
      path: churchesRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: DepartmentsRoute.page,
      path: departmentsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: GiftsRoute.page,
      path: giftsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    // Members
    CustomRoute<dynamic>(
      page: MembersRoute.page,
      path: membersRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute<dynamic>(
      page: MemberDetailsRoute.page,
      path: memberDetailsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ];
}
