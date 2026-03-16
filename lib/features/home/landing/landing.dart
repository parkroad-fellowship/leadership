import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/landing/_handset.dart';
import 'package:leadership/features/home/landing/_tablet.dart';
import 'package:leadership/features/home/landing/models/landing_action_item.dart';
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
      await getIt<FirebaseMessagingService>().init();
    } catch (e) {
      Logger().e('NotificationService init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final actions = <LandingActionItem>[
      LandingActionItem(
        title: l10n.viewDeskActivities,
        assetPath: 'assets/svgs/events.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.deskActivitiesRoute,
        ),
        animationDelay: 700,
        isVisible: Misc.userCan(PRFPermissions.createEvent),
        isNeutralCard: true,
        deskGroup: 'My Desk',
      ),
      LandingActionItem(
        title: l10n.viewMissions,
        assetPath: 'assets/svgs/missions.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.missionsRoute,
        ),
        animationDelay: 700,
        isVisible: Misc.userCan(PRFPermissions.createEvent),
        deskGroup: 'Missions Desk',
      ),
      LandingActionItem(
        title: l10n.manageRequisitions,
        assetPath: 'assets/svgs/giving.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.requisitionApprovalsRoute,
        ),
        animationDelay: 700,
        isVisible: Misc.userCan(PRFPermissions.createEvent),
        isNeutralCard: true,
        deskGroup: 'My Desk',
      ),
      LandingActionItem(
        title: l10n.viewCommitteeActivities,
        assetPath: 'assets/svgs/events.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.deskActivitiesRoute,
        ),
        animationDelay: 700,
        isVisible: Misc.userCan(PRFPermissions.viewAnyCommitteeItem),
        deskGroup: 'Committee Desk',
      ),
      LandingActionItem(
        title: l10n.manageSchools,
        assetPath: 'assets/svgs/schools.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.schools,
        ),
        animationDelay: 700,
        isVisible: Misc.userCan(PRFPermissions.viewAnySchool),
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageMissionTypes,
        assetPath: 'assets/svgs/missions.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.missionTypesRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageSchoolTerms,
        assetPath: 'assets/svgs/schools.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.schoolTermsRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageProfessions,
        assetPath: 'assets/svgs/credentials.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.professionsRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageMaritalStatuses,
        assetPath: 'assets/svgs/credentials.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.maritalStatusesRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageChurches,
        assetPath: 'assets/svgs/explore.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.churchesRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageDepartments,
        assetPath: 'assets/svgs/events.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.departmentsRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageGifts,
        assetPath: 'assets/svgs/giving.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.giftsRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        isSettings: true,
      ),
      LandingActionItem(
        title: l10n.manageMembers,
        assetPath: 'assets/svgs/credentials.svg',
        onTap: () => context.router.pushPath(
          PRFLeadershipRouter.membersRoute,
        ),
        animationDelay: 700,
        isVisible: true,
        deskGroup: 'Organising Secretary',
      ),
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
