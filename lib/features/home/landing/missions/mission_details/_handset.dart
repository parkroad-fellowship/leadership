import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_cubit.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/expenses/expenses.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/mission_ground.dart';
import 'package:leadership/features/home/landing/requisitions/actions/create_requisition/create_requisition.dart';
import 'package:leadership/features/home/landing/requisitions/requisitions.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared_widgets/empty_state.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

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

  int tabCount = 3;

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

    // Fetch mission data
    context.read<GetMissionCubit>().getMission(missionUlid: missionUlid);

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
    Logger().i('Current Tab: $_currentTab');

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
                      Tab(text: l10n.requisitions),
                      Tab(text: l10n.expenses),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverFillRemaining(
                fillOverscroll: true,
                child: BlocBuilder<GetMissionCubit, GetMissionState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loaded: (mission) => TabBarView(
                        controller: _tabController,
                        children: [
                          MissionGroundView(mission: mission),

                          if (mission.accountingEvent != null)
                            RequisitionsView(
                              accountingEventUlid:
                                  mission.accountingEvent!.ulid,
                            )
                          else
                            PRFEmptyView(
                              label: l10n.requisitionUnavailable,
                              description: l10n.requisitionUnavailableDesc,
                            ),
                          ExpensesView(missionUlid: mission.ulid),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (message) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: $message',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      orElse: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<GetMissionCubit, GetMissionState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (mission) => switch (_currentTab) {
              2 => FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (mission.accountingEvent != null) {
                    WoltModalSheet.show<void>(
                      context: context,
                      pageListBuilder: (modalSheetContext) {
                        return [
                          WoltModalSheetPage(
                            child: CreateRequisitionView(
                              accountingEvent: mission.accountingEvent!,
                            ),
                          ),
                        ];
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.requisitionUnavailable)),
                    );
                  }
                },
                label: Text(l10n.create),
              ),
              _ => const SizedBox.shrink(),
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
