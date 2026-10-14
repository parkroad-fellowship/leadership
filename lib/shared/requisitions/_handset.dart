import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/shared/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class RequisitionsViewHandset extends StatefulWidget {
  const RequisitionsViewHandset({
    required this.accountingEvent,
    this.event,
    super.key,
  });
  final PRFAccountingEvent accountingEvent;
  final PRFEvent? event;

  @override
  State<RequisitionsViewHandset> createState() =>
      _RequisitionsViewHandsetState();
}

class _RequisitionsViewHandsetState extends State<RequisitionsViewHandset>
    with TimezoneMixin {
  PRFEvent? get event => widget.event;
  PRFAccountingEvent get accountingEvent => widget.accountingEvent;
  @override
  void initState() {
    super.initState();
    context.read<RequisitionResourceCubit>().loadForAccountingEvent(
      accountingEventUlid: accountingEvent.ulid,
    );
  }

  Future<void> _reload() {
    final cubit = context.read<RequisitionResourceCubit>()..invalidate();
    return cubit.loadForAccountingEvent(
      accountingEventUlid: accountingEvent.ulid,
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (event != null) ...[
              _buildEventHeroCard(context, event!, l10n, theme),
              const SizedBox(height: PRFSpacingTokens.xxl),
            ],
            PRFEmptyView(
              label: l10n.requisitionsEmptyTitle,
              description: l10n.requisitionsEmptyDescription,
              icon: Icons.receipt_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: PRFErrorView.fromMessage(
        title: l10n.requisitionsLoadErrorTitle,
        message: l10n.requisitionsLoadErrorMessage,
        retryLabel: l10n.tryAgain,
        onRetry: _reload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        return switch (state) {
          ResourceListLoaded<PRFRequisition>(:final items) when items.isEmpty =>
            _buildEmpty(l10n, theme),
          ResourceListLoaded<PRFRequisition>(:final items) => _buildLoadedList(
            context,
            theme,
            l10n,
            items,
          ),
          ResourceMutating<PRFRequisition>(:final items) when items.isEmpty =>
            _buildEmpty(l10n, theme),
          ResourceMutating<PRFRequisition>(:final items) => _buildLoadedList(
            context,
            theme,
            l10n,
            items,
          ),
          ResourceError<PRFRequisition>(:final items) when items.isNotEmpty =>
            _buildLoadedList(context, theme, l10n, items),
          ResourceError<PRFRequisition>() => _buildError(l10n),
          _ => const Center(child: PRFCircularProgressIndicator()),
        };
      },
    );
  }

  Widget _buildLoadedList(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    List<PRFRequisition> requisitions,
  ) {
    final sortedRequisitions = List<PRFRequisition>.from(requisitions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: _reload,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (event != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                child: _buildEventHeroCard(context, event!, l10n, theme),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final requisition = sortedRequisitions[index];
                final isLast = index == sortedRequisitions.length - 1;

                return TimelineRequisitionCard(
                      requisition: requisition,
                      isLast: isLast,
                      index: index,
                      // No reload on return: detail actions persist to the same
                      // Hive box and the list re-emits from its DB stream.
                      onTap: () => context.router.push(
                        RequisitionDetailsRoute(
                          requisitionUlid: requisition.ulid,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: PRFMotionTokens.resolve(
                        context,
                        Duration(milliseconds: min(index, 8) * 100),
                      ),
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.enterShort,
                      ),
                    )
                    .slideX(
                      begin: 0.3,
                      end: 0,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.enterShort,
                      ),
                      curve: PRFMotionTokens.emphasized,
                    );
              }, childCount: sortedRequisitions.length),
            ),
          ),
          // Leaves room below the last card for the floating action button.
          const SliverToBoxAdapter(
            child: SizedBox(height: PRFSpacingTokens.xxxl * 2.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeroCard(
    BuildContext context,
    PRFEvent event,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final scheme = theme.colorScheme;
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                scheme.primary.withValues(alpha: PRFOpacities.stronger),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.xxl),
            boxShadow: PRFShadowTokens.heroGlow(scheme.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.md,
                        vertical: PRFSpacingTokens.xs,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                      ),
                      child: Text(
                        l10n.requisitionsEventBadge.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: scheme.onPrimary,
                        size: PRFSizeTokens.iconMd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  event.name.toUpperCase(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                if (event.venue != null)
                  Text(
                    event.venue!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary.withValues(
                        alpha: PRFOpacities.nearOpaque,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: PRFSpacingTokens.xl),
                _buildDateTimeChip(
                  context,
                  Icons.play_arrow_rounded,
                  l10n.missionStart(
                    Misc.formatMissionDate(event.startDate, timezone),
                    Misc.formatTime(event.startTime, timezone),
                  ),
                  theme,
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                _buildDateTimeChip(
                  context,
                  Icons.stop_rounded,
                  l10n.missionEnd(
                    Misc.formatMissionDate(event.endDate, timezone),
                    Misc.formatTime(event.endTime, timezone),
                  ),
                  theme,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        );
  }

  Widget _buildDateTimeChip(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    final onPrimary = theme.colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.md,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: PRFOpacities.muted),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: onPrimary, size: PRFSizeTokens.iconSm),
          const SizedBox(width: PRFSpacingTokens.sm),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
