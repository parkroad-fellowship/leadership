import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/landing/_handset.dart';
import 'package:leadership/features/home/landing/_tablet.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';

@RoutePage()
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();

    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await getIt<NotificationService>().requestPermissions();
      await getIt<NotificationService>().init();

      await getIt<NotificationService>().scheduleGivingNotification();
    } catch (e) {
      Logger().e('NotificationService init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final actions = [
      [
        l10n.viewDeskActivities,
        'assets/svgs/events.svg',
        () => context.router.pushPath(
          PRFLeadershipRouter.deskActivitiesRoute,
        ),
        700,
      ],
      [
        l10n.viewMissions,
        'assets/svgs/missions.svg',
        () => context.router.pushPath(
          PRFLeadershipRouter.missionsRoute,
        ),
        700,
      ],
      [
        l10n.manageRequisitions,
        'assets/svgs/giving.svg',
        () => context.router.pushPath(
          PRFLeadershipRouter.requisitionApprovalsRoute,
        ),
        700,
      ],
    ];

    return AdaptiveBuilder(
      defaultBuilder: (_, _) => LandingPageTablet(actions: actions),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => LandingPageHandset(actions: actions),
        tablet: (_, _) => LandingPageTablet(actions: actions),
      ),
    );
  }
}
