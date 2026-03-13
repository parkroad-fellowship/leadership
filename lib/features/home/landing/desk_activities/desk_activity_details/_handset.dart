import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared_views/expenses/expenses.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition/create_requisition.dart';
import 'package:leadership/shared_views/requisitions/requisitions.dart';
import 'package:leadership/utils/_index.dart';
import 'package:prf_design/prf_design.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      body: DefaultTabController(
        length: tabCount,
        child: Column(
          children: [
            ColoredBox(
              color: theme.colorScheme.primary,
              child: Column(
                children: [
                  PRFBrandedNavBar(
                    title: l10n.activityDetails,
                    onBack: () => context.router.popUntilRouteWithPath(
                      PRFLeadershipRouter.deskActivitiesRoute,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PRFSpacingTokens.lg,
                      0,
                      PRFSpacingTokens.lg,
                      PRFSpacingTokens.sm,
                    ),
                    child: Transform.translate(
                      offset: const Offset(0, -6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          controller: _tabController,
                          onTap: (value) => setState(() => _currentTab = value),
                          isScrollable: true,
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.65),
                          indicatorColor: theme.colorScheme.secondary,
                          dividerColor: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.2,
                          ),
                          labelStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.sm,
                          ),
                          tabs: [
                            Tab(text: l10n.requisitions),
                            Tab(text: l10n.expenses),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                    ExpensesView(
                      accountingEventUlid: event.accountingEvent!.ulid,
                      showFinancialReport: true,
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
      floatingActionButton: switch (_currentTab) {
        0 =>
          Misc.userCan(PRFPermissions.createRequisition)
              ? FloatingActionButton.extended(
                  backgroundColor: PRFColorPalette.lime300,
                  foregroundColor: PRFColorPalette.navy900,
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (event.accountingEvent != null) {
                      PRFBottomSheet.show<void>(
                        context,
                        title: l10n.createRequisition,
                        child: CreateRequisitionView(
                          accountingEvent: event.accountingEvent!,
                        ),
                      );
                    } else {
                      PRFSnackbar.error(
                        context,
                        l10n.requisitionUnavailable,
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
