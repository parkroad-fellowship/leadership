import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_approval_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_closed_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/get_draft_requisitions_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          ColoredBox(
            color: theme.colorScheme.primary,
            child: Column(
              children: [
                PRFBrandedNavBar(
                  title: l10n.manageReqs,
                  onBack: () => context.router.popUntilRouteWithPath(
                    PRFLeadershipRouter.landingRoute,
                  ),
                  actions: [
                    BlocBuilder<
                      GetApprovalRequisitionsCubit,
                      ResourceState<PRFRequisition>
                    >(
                      builder: (context, state) => state.maybeWhen(
                        listLoading: () => const SizedBox.square(
                          dimension: 20,
                          child: PRFCircularProgressIndicator(),
                        ),
                        orElse: SizedBox.shrink,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    BlocBuilder<
                      GetClosedRequisitionsCubit,
                      ResourceState<PRFRequisition>
                    >(
                      builder: (context, state) => state.maybeWhen(
                        listLoading: () => const SizedBox.square(
                          dimension: 20,
                          child: PRFCircularProgressIndicator(),
                        ),
                        orElse: SizedBox.shrink,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.lg),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PRFSpacingTokens.lg,
                    0,
                    PRFSpacingTokens.lg,
                    PRFSpacingTokens.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(0, -6),
                      child: TabBar(
                        controller: _tabController,
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
                          Tab(text: l10n.pendingApproval),
                          Tab(text: l10n.closed),
                          Tab(text: l10n.drafts),
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
                _buildApprovalRequisitions(context),
                _buildClosedRequisitions(context),
                _buildDraftRequisitions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<
      GetApprovalRequisitionsCubit,
      ResourceState<PRFRequisition>
    >(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<GetApprovalRequisitionsCubit>()
                    .getApprovalRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noPendingRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetClosedRequisitionsCubit>()
                  .getClosedRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
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
                              RequisitionDetailsRoute(
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
                        duration: PRFMotionTokens.enterShort,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: PRFMotionTokens.emphasized,
                      );
                },
              ),
            );
          },
          error: (message, items) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClosedRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<
      GetClosedRequisitionsCubit,
      ResourceState<PRFRequisition>
    >(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<GetClosedRequisitionsCubit>()
                    .getClosedRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noClosedRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetDraftRequisitionsCubit>()
                  .getDraftRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
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
                              RequisitionDetailsRoute(
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
                        duration: PRFMotionTokens.enterShort,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: PRFMotionTokens.emphasized,
                      );
                },
              ),
            );
          },
          error: (message, items) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraftRequisitions(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<
      GetDraftRequisitionsCubit,
      ResourceState<PRFRequisition>
    >(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<GetClosedRequisitionsCubit>()
                    .getClosedRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noDraftRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetApprovalRequisitionsCubit>()
                  .getApprovalRequisitions(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
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
                              RequisitionDetailsRoute(
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
                        duration: PRFMotionTokens.enterShort,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: PRFMotionTokens.emphasized,
                      );
                },
              ),
            );
          },
          error: (message, items) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
