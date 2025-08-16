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

  static const String deskEventsRoute = '/desk-events';
  static const String deskEventDetailsRoute = '/desk-events/:ulid';

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
      page: DeskEventsRoute.page,
      path: deskEventsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    CustomRoute<dynamic>(
      page: DeskEventDetailsRoute.page,
      path: deskEventDetailsRoute,
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ];
}
