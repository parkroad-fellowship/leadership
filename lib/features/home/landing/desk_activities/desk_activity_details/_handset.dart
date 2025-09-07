import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/landing/expenses/accounting_event_expenses.dart';
import 'package:leadership/features/home/landing/requisitions/actions/create_requisition/create_requisition.dart';
import 'package:leadership/features/home/landing/requisitions/requisitions.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared_widgets/empty_state.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class DeskEventDetailsPageHandset extends StatefulWidget {
  const DeskEventDetailsPageHandset({required this.event, super.key});

  final PRFEvent event;

  @override
  State<DeskEventDetailsPageHandset> createState() =>
      _DeskEventDetailsPageHandsetState();
}

class _DeskEventDetailsPageHandsetState
    extends State<DeskEventDetailsPageHandset>
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
          child: CustomScrollView(
            slivers: [
              PRFNavBar(
                title: l10n.activityDetails,
                onBack: () => context.router.popUntilRouteWithPath(
                  PRFLeadershipRouter.deskActivitiesRoute,
                ),
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
                    Tab(text: l10n.requisitions),
                    Tab(text: l10n.expenses),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    if (event.accountingEvent != null)
                      RequisitionsView(
                        event: event,
                        accountingEvent: event.accountingEvent!,
                      )
                    else
                      PRFEmptyView(
                        label: l10n.requisitionUnavailable,
                        description: l10n.requisitionUnavailableDesc,
                      ),
                    if (event.accountingEvent != null)
                      AccountingEventExpensesView(
                        accountingEventUlid: event.accountingEvent!.ulid,
                      )
                    else
                      PRFEmptyView(
                        label: l10n.expensesUnavailable,
                        description: l10n.expensesUnavailableDesc,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: switch (_currentTab) {
        0 =>
          Misc.userCan(PRFPermissions.createRequisition)
              ? FloatingActionButton.extended(
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
                  label: Text(l10n.createRequisition),
                )
              : null,
        _ => const SizedBox.shrink(),
      },
    );
  }
}
