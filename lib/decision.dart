import 'package:auto_route/auto_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/_index.dart';
import 'package:upgrader/upgrader.dart';

@RoutePage()
class DecisionPage extends StatefulWidget {
  const DecisionPage({super.key});

  @override
  State<DecisionPage> createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> {
  @override
  void initState() {
    super.initState();
    final accessToken = getIt<HiveService>().auth.retrieveToken();

    if (accessToken == null) {
      _redirectToPage(context, PRFLeadershipRouter.signInRoute);
      return;
    }

    final profile = getIt<HiveService>().auth.retrieveProfile();
    if (profile == null) {
      _redirectToPage(context, PRFLeadershipRouter.signInRoute);
      return;
    }

    /// If both the member and student are null, then the user is lacking a
    /// profile and should be redirected to the sign-in page.
    if (profile.member == null) {
      _redirectToPage(context, PRFLeadershipRouter.signInRoute);
      return;
    }

    _redirectToPage(context, PRFLeadershipRouter.landingRoute);
  }

  void _redirectToPage(BuildContext context, String routeName) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.router.pushPath(routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => Misc.exitApp(
        context: context,
        didPop: didPop,
        result: result,
      ),
      child: UpgradeAlert(
        showIgnore: false,
        showLater: false,
        child: Scaffold(
          body: Center(
            child: ExtendedImage.asset(
              'assets/images/app-logo.png',
              width: 222,
              cacheRawData: true,
            ),
          ),
        ),
      ),
    );
  }
}
