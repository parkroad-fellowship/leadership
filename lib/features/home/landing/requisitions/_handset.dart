import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisitions_cubit.dart';
import 'package:leadership/features/home/landing/requisitions/widgets/timeline_requisitions_card.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_widgets/empty_state.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:leadership/utils/router/router.gr.dart';

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
    context.read<GetRequisitionsCubit>().getRequisitions(
      accountingEventUlid: accountingEvent.ulid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetRequisitionsCubit, GetRequisitionsState>(
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () =>
                context.read<GetRequisitionsCubit>().getRequisitions(
                  accountingEventUlid: accountingEvent.ulid,
                ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (event != null) ...[
                    _buildEventHeroCard(context, event!, l10n, theme),
                    const SizedBox(height: 24),
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
          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<GetRequisitionsCubit>().getRequisitions(
                    accountingEventUlid: accountingEvent.ulid,
                  ),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (event != null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildEventHeroCard(
                          context,
                          event!,
                          l10n,
                          theme,
                        ),
                      ),
                    ),
                  ],
                  // Requisitions List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                      RequisitionRoute(
                                        requisitionUlid: requisition.ulid,
                                      ),
                                    )
                                    .then((_) {
                                      // ignore: use_build_context_synchronously
                                      context
                                          .read<GetRequisitionsCubit>()
                                          .getRequisitions(
                                            accountingEventUlid:
                                                accountingEvent.ulid,
                                          );
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
                        childCount: sortedRequisitions.length,
                      ),
                    ),
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        );
      },
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
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                        borderRadius: BorderRadius.circular(20),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  event.name.toUpperCase(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                if (event.venue != null)
                  Text(
                    event.venue!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 8),
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
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDateTimeChip(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
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
