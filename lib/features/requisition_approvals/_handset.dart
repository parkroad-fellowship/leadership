import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/shared/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.dart';
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
  late final RequisitionResourceCubit _approvalCubit;
  late final RequisitionResourceCubit _closedCubit;
  late final RequisitionResourceCubit _draftCubit;

  @override
  void initState() {
    super.initState();

    _approvalCubit = RequisitionResourceCubit(
      requisitionService: getIt<RequisitionService>(),
      hiveService: getIt<HiveService>(),
      hiveDbService: getIt<RequisitionHiveDbService>(),
    )..loadApprovalRequisitions();

    _closedCubit = RequisitionResourceCubit(
      requisitionService: getIt<RequisitionService>(),
      hiveService: getIt<HiveService>(),
      hiveDbService: getIt<RequisitionHiveDbService>(),
    )..loadClosedRequisitions();

    _draftCubit = RequisitionResourceCubit(
      requisitionService: getIt<RequisitionService>(),
      hiveService: getIt<HiveService>(),
      hiveDbService: getIt<RequisitionHiveDbService>(),
    )..loadDraftRequisitions();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _approvalCubit.loadApprovalRequisitions();
      } else if (_tabController.index == 1) {
        _closedCubit.loadClosedRequisitions();
      } else {
        _draftCubit.loadDraftRequisitions();
      }
    });
  }

  @override
  void dispose() {
    _approvalCubit.close();
    _closedCubit.close();
    _draftCubit.close();
    super.dispose();
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
                      RequisitionResourceCubit,
                      ResourceState<PRFRequisition>
                    >(
                      bloc: _approvalCubit,
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
                      RequisitionResourceCubit,
                      ResourceState<PRFRequisition>
                    >(
                      bloc: _closedCubit,
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
                      RequisitionResourceCubit,
                      ResourceState<PRFRequisition>
                    >(
                      bloc: _draftCubit,
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
                BlocProvider.value(
                  value: _approvalCubit,
                  child: _buildApprovalRequisitions(context),
                ),
                BlocProvider.value(
                  value: _closedCubit,
                  child: _buildClosedRequisitions(context),
                ),
                BlocProvider.value(
                  value: _draftCubit,
                  child: _buildDraftRequisitions(context),
                ),
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

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<RequisitionResourceCubit>()
                    .loadApprovalRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noPendingRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<RequisitionResourceCubit>()
                  .loadApprovalRequisitions(),
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
                                  .read<RequisitionResourceCubit>()
                                  .loadApprovalRequisitions();
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

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<RequisitionResourceCubit>()
                    .loadClosedRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noClosedRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<RequisitionResourceCubit>()
                  .loadClosedRequisitions(),
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
                                  .read<RequisitionResourceCubit>()
                                  .loadDraftRequisitions();
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

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context
                    .read<RequisitionResourceCubit>()
                    .loadDraftRequisitions(),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: l10n.noDraftRequisitionsDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<RequisitionResourceCubit>()
                  .loadDraftRequisitions(),
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
                                  .read<RequisitionResourceCubit>()
                                  .loadDraftRequisitions();
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
