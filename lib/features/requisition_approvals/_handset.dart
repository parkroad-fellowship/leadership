import 'dart:math';

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
                        listLoading: (items) => const SizedBox.square(
                          dimension: PRFSizeTokens.iconMd,
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
                        listLoading: (items) => const SizedBox.square(
                          dimension: PRFSizeTokens.iconMd,
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
                        listLoading: (items) => const SizedBox.square(
                          dimension: PRFSizeTokens.iconMd,
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
                            .withValues(alpha: PRFOpacities.stronger),
                        indicatorColor: theme.colorScheme.secondary,
                        dividerColor: theme.colorScheme.onPrimary.withValues(
                          alpha: PRFOpacities.muted,
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
    return _buildRequisitionTab(
      context,
      emptyDescription: context.l10n.noPendingRequisitionsDesc,
      reload: (cubit) => cubit.loadApprovalRequisitions(),
      reloadAfterDetails: (cubit) => cubit.loadApprovalRequisitions(),
    );
  }

  Widget _buildClosedRequisitions(BuildContext context) {
    return _buildRequisitionTab(
      context,
      emptyDescription: context.l10n.noClosedRequisitionsDesc,
      reload: (cubit) => cubit.loadClosedRequisitions(),
      reloadAfterDetails: (cubit) => cubit.loadClosedRequisitions(),
    );
  }

  Widget _buildDraftRequisitions(BuildContext context) {
    return _buildRequisitionTab(
      context,
      emptyDescription: context.l10n.noDraftRequisitionsDesc,
      reload: (cubit) => cubit.loadDraftRequisitions(),
      reloadAfterDetails: (cubit) => cubit.loadDraftRequisitions(),
    );
  }

  Widget _buildRequisitionTab(
    BuildContext context, {
    required String emptyDescription,
    required Future<void> Function(RequisitionResourceCubit cubit) reload,
    required Future<void> Function(RequisitionResourceCubit cubit)
    reloadAfterDetails,
  }) {
    final l10n = context.l10n;

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        final cubit = context.read<RequisitionResourceCubit>();
        return state.maybeWhen(
          listLoaded: (requisitions, page, hasMore) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedRequisitions.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => reload(cubit),
                child: PRFEmptyView(
                  label: l10n.noRequisitions,
                  description: emptyDescription,
                ),
              );
            }

            final duration = PRFMotionTokens.resolve(
              context,
              PRFMotionTokens.enterShort,
            );

            return RefreshIndicator(
              onRefresh: () => reload(cubit),
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
                  final card = TimelineRequisitionCard(
                    requisition: requisition,
                    isLast: isLast,
                    index: index,
                    onTap: () => context.router
                        .push(
                          RequisitionDetailsRoute(
                            requisitionUlid: requisition.ulid,
                          ),
                        )
                        .then((_) => reloadAfterDetails(cubit)),
                  );
                  if (duration == Duration.zero) return card;

                  // Cap the stagger so long lists don't make people wait.
                  final delay = PRFMotionTokens.stagger2 * min(index, 8);
                  return card
                      .animate()
                      .fadeIn(delay: delay, duration: duration)
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: delay,
                        duration: duration,
                        curve: PRFMotionTokens.emphasized,
                      );
                },
              ),
            );
          },
          error: (message, items) => PRFErrorView.fromMessage(
            title: l10n.requisitionApprovalsLoadError,
            message: l10n.commonLoadErrorMessage,
            retryLabel: l10n.commonTryAgain,
            onRetry: () => reload(cubit),
          ),
          orElse: () => const Center(child: PRFCircularProgressIndicator()),
        );
      },
    );
  }
}
