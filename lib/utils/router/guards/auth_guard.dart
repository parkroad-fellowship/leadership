import 'package:auto_route/auto_route.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/router/router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final token = getIt<HiveService>().auth.retrieveToken();
    final isLoggedOut = getIt<HiveService>().auth.isLoggedOut();

    if (token != null && !isLoggedOut) {
      resolver.next();
    } else {
      router.push(const DecisionRoute());
    }
  }
}
