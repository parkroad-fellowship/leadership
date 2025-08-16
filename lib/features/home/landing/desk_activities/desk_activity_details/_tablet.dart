import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/information/information.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition/create_requisition.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class DeskEventDetailsPageTablet extends StatefulWidget {
  const DeskEventDetailsPageTablet({required this.event, super.key});

  final PRFEvent event;

  @override
  State<DeskEventDetailsPageTablet> createState() =>
      _DeskEventDetailsPageTabletState();
}

class _DeskEventDetailsPageTabletState extends State<DeskEventDetailsPageTablet>
    with SingleTickerProviderStateMixin {
  PRFEvent get event => widget.event;

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
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_changeTab);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(_changeTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: DefaultTabController(
        length: tabCount,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: CustomScrollView(
              slivers: [
                PRFNavBar(
                  title: l10n.activityDetails,
                  onBack: () => context.router.popUntilRouteWithPath(
                    PRFLeadershipRouter.deskActivitiesRoute,
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    onTap: (value) => setState(() {
                      Logger().d(value);
                      _currentTab = value;
                    }),
                    isScrollable: true,
                    tabs: [
                      Tab(text: l10n.info),
                      Tab(text: l10n.requisitions),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        InformationView(event: event),
                        const Placeholder(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: switch (_currentTab) {
        1 => FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (event.accountingEvent != null) {
              WoltModalSheet.show<void>(
                context: context,
                pageListBuilder: (modalSheetContext) {
                  return [
                    WoltModalSheetPage(
                      child: CreateRequisitionView(
                        accountingEvent: event.accountingEvent!,
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
    );
  }
}
