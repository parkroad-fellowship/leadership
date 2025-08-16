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

  static const String requisitionRoute = '/desk-activities/:ulid/requisitions/:ulid';

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
      page: RequisitionRoute.page,
      path: requisitionRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ];
}
