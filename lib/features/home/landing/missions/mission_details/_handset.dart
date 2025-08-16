import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/expenses/expenses.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/mission_ground.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';

class MissionsDetailsPageHandset extends StatefulWidget {
  const MissionsDetailsPageHandset({required this.missionUlid, super.key});

  final String missionUlid;

  @override
  State<MissionsDetailsPageHandset> createState() =>
      _MissionsDetailsPageHandsetState();
}

class _MissionsDetailsPageHandsetState extends State<MissionsDetailsPageHandset>
    with SingleTickerProviderStateMixin {
  String get missionUlid => widget.missionUlid;

  int tabCount = 2;

  late TabController _tabController;
  int _currentTab = 0;

  void _changeTab() {
    setState(() {
      _currentTab = _tabController.index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_changeTab);
  }

  @override
  void dispose() {
    _tabController.removeListener(_changeTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Logger().i(_currentTab);

    return Scaffold(
      body: DefaultTabController(
        length: tabCount,
        child: SafeArea(
          child: CustomScrollView(
            physics: const ScrollPhysics(),
            slivers: [
              // Start Navigation Bar
              PRFNavBar(
                title: l10n.missionDetails,
                onBack: () => context.router.popUntilRouteWithPath(
                  PRFLeadershipRouter.missionsRoute,
                ),
              ),
              // End Navigation Bar
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    onTap: (value) => setState(() {
                      _currentTab = value;
                    }),
                    isScrollable: true,
                    tabs: [
                      Tab(text: l10n.missionGround),
                      Tab(text: l10n.expenses),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverFillRemaining(
                fillOverscroll: true,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    MissionGroundView(missionUlid: missionUlid),

                    ExpensesView(missionUlid: missionUlid),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
