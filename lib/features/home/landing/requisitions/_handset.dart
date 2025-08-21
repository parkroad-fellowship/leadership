import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisitions_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared_widgets/empty_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/router/router.gr.dart';

class RequisitionsViewHandset extends StatefulWidget {
  const RequisitionsViewHandset({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  State<RequisitionsViewHandset> createState() =>
      _RequisitionsViewHandsetState();
}

class _RequisitionsViewHandsetState extends State<RequisitionsViewHandset> {
  @override
  void initState() {
    super.initState();
    context.read<GetRequisitionsCubit>().getRequisitions(
      accountingEventUlid: widget.accountingEventUlid,
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
                  accountingEventUlid: widget.accountingEventUlid,
                ),
            child: PRFEmptyView(
              label: l10n.requisitions,
              description: 'No requisitions found for this activity',
              icon: Icons.receipt_outlined,
            ),
          ),
          loaded: (requisitions) {
            // Sort requisitions by creation date for timeline
            final sortedRequisitions = List<PRFRequisition>.from(requisitions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<GetRequisitionsCubit>().getRequisitions(
                    accountingEventUlid: widget.accountingEventUlid,
                  ),
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
                                  .read<GetRequisitionsCubit>()
                                  .getRequisitions(
                                    accountingEventUlid:
                                        widget.accountingEventUlid,
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
              ),
            );
          },
        );
      },
    );
  }
}

class TimelineRequisitionCard extends StatelessWidget {
  const TimelineRequisitionCard({
    required this.requisition,
    required this.isLast,
    required this.index,
    this.onTap,
    super.key,
  });

  final PRFRequisition requisition;
  final bool isLast;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = requisition.approvalStatus.color(theme);
    final requisitionDate = requisition.requisitionDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Column(
            children: [
              // Date badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor,
                      statusColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      requisitionDate.day.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      Misc.getMonthAbbreviation(requisitionDate.month),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Timeline line with flexible height
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withValues(alpha: 0.6),
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withValues(alpha: 0.1),
                            statusColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status and Member
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  requisition.member?.firstName ??
                                      'Unknown Member',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  requisition.approvalStatus.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Responsible Desk
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.business_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  requisition.responsibleDesk.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount and Items count
                          Row(
                            children: [
                              Flexible(
                                child: _buildInfoChip(
                                  context,
                                  Icons.attach_money_rounded,
                                  'Amount',
                                  Misc.formatCash(
                                    requisition.totalAmount / 100,
                                  ),
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildInfoChip(
                                  context,
                                  Icons.list_alt_rounded,
                                  'Items',
                                  '${requisition.requisitionItems.length}',
                                  theme.colorScheme.secondaryContainer,
                                  theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Date and Time
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Requested on',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Misc.formatDate(
                                          requisitionDate,
                                          'Africa/Nairobi',
                                        ),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (requisition.remarks?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 16),
                            Text(
                              requisition.remarks!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 16),

                          // View Details button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withValues(alpha: 0.1),
                                  statusColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Details',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: statusColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color backgroundColor,
    Color textColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
