import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_resource_cubit.dart';
import 'package:leadership/shared_views/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<RequisitionResourceCubit, ResourceState<PRFRequisition>>(
      builder: (context, state) {
        return switch (state) {
          ResourceListLoaded<PRFRequisition>(:final items) when items.isEmpty =>
            RefreshIndicator(
              onRefresh: () => context
                  .read<RequisitionResourceCubit>()
                  .loadForAccountingEvent(
                    accountingEventUlid: accountingEvent.ulid,
                  ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (event != null) ...[
                      _buildEventHeroCard(context, event!, l10n, theme),
                      const SizedBox(height: PRFSpacingTokens.xxl),
                    ],
                    PRFEmptyView(
                      label: l10n.requisitions,
                      description: 'No requisitions found for this activity',
                      icon: Icons.receipt_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ResourceListLoaded<PRFRequisition>(:final items) => _buildLoadedList(
            context,
            theme,
            l10n,
            items,
          ),
          ResourceMutated<PRFRequisition>(:final items) when items.isEmpty =>
            RefreshIndicator(
              onRefresh: () => context
                  .read<RequisitionResourceCubit>()
                  .loadForAccountingEvent(
                    accountingEventUlid: accountingEvent.ulid,
                  ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PRFEmptyView(
                  label: l10n.requisitions,
                  description: 'No requisitions found for this activity',
                  icon: Icons.receipt_outlined,
                ),
              ),
            ),
          ResourceMutated<PRFRequisition>(:final items) => _buildLoadedList(
            context,
            theme,
            l10n,
            items,
          ),
          ResourceError<PRFRequisition>(:final message, :final items)
              when items.isEmpty =>
            Center(
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ResourceError<PRFRequisition>(:final items) when items.isNotEmpty =>
            _buildLoadedList(
              context,
              theme,
              l10n,
              items,
            ),
          ResourceError<PRFRequisition>(:final message) => Center(
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _ => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
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
      onRefresh: () => context
          .read<RequisitionResourceCubit>()
          .loadForAccountingEvent(accountingEventUlid: accountingEvent.ulid),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (event != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                child: _buildEventHeroCard(
                  context,
                  event!,
                  l10n,
                  theme,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                              if (!context.mounted) {
                                return;
                              }
                              context
                                  .read<RequisitionResourceCubit>()
                                  .loadForAccountingEvent(
                                    accountingEventUlid: accountingEvent.ulid,
                                  );
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
                childCount: sortedRequisitions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
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
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.xxl),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                      ),
                      child: Text(
                        'EVENT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  event.name.toUpperCase(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                if (event.venue != null)
                  Text(
                    event.venue!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: PRFSpacingTokens.xl),
                Row(
                  children: [
                    _buildDateTimeChip(
                      context,
                      Icons.play_arrow_rounded,
                      l10n.missionStart(
                        Misc.formatMissionDate(event.startDate, timezone),
                        Misc.formatTime(event.startTime, timezone),
                      ),
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Row(
                  children: [
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
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDateTimeChip(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.md,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: PRFSpacingTokens.sm),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
