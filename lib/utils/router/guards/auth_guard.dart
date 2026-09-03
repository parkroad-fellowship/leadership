import 'package:auto_route/auto_route.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
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
