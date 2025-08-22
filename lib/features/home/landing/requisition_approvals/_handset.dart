import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_approval_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_closed_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_draft_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/router/router.gr.dart';

class RequisitionApprovalsPageHandset extends StatefulWidget {
  const RequisitionApprovalsPageHandset({super.key});

  @override
  State<RequisitionApprovalsPageHandset> createState() =>
      _RequisitionApprovalsPageHandsetState();
}

class _RequisitionApprovalsPageHandsetState
    extends State<RequisitionApprovalsPageHandset>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    context.read<GetApprovalRequisitionsCubit>().getApprovalRequisitions();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        context.read<GetApprovalRequisitionsCubit>().getApprovalRequisitions();
      } else if (_tabController.index == 1) {
        context.read<GetClosedRequisitionsCubit>().getClosedRequisitions();
      } else {
        context.read<GetDraftRequisitionsCubit>().getDraftRequisitions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            l10n.manageReqs,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          leading: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
              onPressed: () => context.router.popUntilRouteWithPath(
                PRFLeadershipRouter.landingRoute,
              ),
            ),
          ),
          actions: [
            BlocBuilder<
              GetApprovalRequisitionsCubit,
              GetApprovalRequisitionsState
            >(
              builder: (context, state) => state.maybeWhen(
                loading: () => const SizedBox.square(
                  dimension: 24,
                  child: PRFCircularProgressIndicator(),
                ),
                orElse: SizedBox.shrink,
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<GetClosedRequisitionsCubit, GetClosedRequisitionsState>(
              builder: (context, state) => state.maybeWhen(
                loading: () => const SizedBox.square(
                  dimension: 24,
                  child: PRFCircularProgressIndicator(),
                ),
                orElse: SizedBox.shrink,
              ),
            ),
            const SizedBox(width: 16),
          ],
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.pendingApproval),
              Tab(text: l10n.closed),
              Tab(text: l10n.drafts),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            _buildApprovalRequisitions(context),
            _buildClosedRequisitions(context),
            _buildDraftRequisitions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<
      GetApprovalRequisitionsCubit,
      GetApprovalRequisitionsState
    >(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () => context
                .read<GetApprovalRequisitionsCubit>()
                .getApprovalRequisitions(),
            child: PRFEmptyView(
              label: l10n.noRequisitions,
              description: l10n.noPendingRequisitionsDesc,
            ),
          ),
          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetApprovalRequisitionsCubit>()
                  .getApprovalRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: sortedRequisitions.length,
                itemBuilder: (context, index) {
                  final requisition = sortedRequisitions[index];
                  final isLast = index == sortedRequisitions.length - 1;

                  return TimelineRequisitionCard(
                        requisition: requisition,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router
                            .push(
                              RequisitionRoute(
                                requisitionUlid: requisition.ulid,
                              ),
                            )
                            .then((_) {
                              // ignore: use_build_context_synchronously
                              context
                                  .read<GetApprovalRequisitionsCubit>()
                                  .getApprovalRequisitions();
                            }),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClosedRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetClosedRequisitionsCubit, GetClosedRequisitionsState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () => context
                .read<GetClosedRequisitionsCubit>()
                .getClosedRequisitions(),
            child: PRFEmptyView(
              label: l10n.noRequisitions,
              description: l10n.noClosedRequisitionsDesc,
            ),
          ),

          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetApprovalRequisitionsCubit>()
                  .getApprovalRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: sortedRequisitions.length,
                itemBuilder: (context, index) {
                  final requisition = sortedRequisitions[index];
                  final isLast = index == sortedRequisitions.length - 1;

                  return TimelineRequisitionCard(
                        requisition: requisition,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router
                            .push(
                              RequisitionRoute(
                                requisitionUlid: requisition.ulid,
                              ),
                            )
                            .then((_) {
                              // ignore: use_build_context_synchronously
                              context
                                  .read<GetApprovalRequisitionsCubit>()
                                  .getApprovalRequisitions();
                            }),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDraftRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetDraftRequisitionsCubit, GetDraftRequisitionsState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () => context
                .read<GetClosedRequisitionsCubit>()
                .getClosedRequisitions(),
            child: PRFEmptyView(
              label: l10n.noRequisitions,
              description: l10n.noDraftRequisitionsDesc,
            ),
          ),

          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetApprovalRequisitionsCubit>()
                  .getApprovalRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: sortedRequisitions.length,
                itemBuilder: (context, index) {
                  final requisition = sortedRequisitions[index];
                  final isLast = index == sortedRequisitions.length - 1;

                  return TimelineRequisitionCard(
                        requisition: requisition,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router
                            .push(
                              RequisitionRoute(
                                requisitionUlid: requisition.ulid,
                              ),
                            )
                            .then((_) {
                              // ignore: use_build_context_synchronously
                              context
                                  .read<GetApprovalRequisitionsCubit>()
                                  .getApprovalRequisitions();
                            }),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          },
        );
      },
    );
  }
}
