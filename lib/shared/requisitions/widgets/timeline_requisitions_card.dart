import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/shared/requisitions/widgets/approval_status_style.dart';
import 'package:leadership/utils/misc.dart';
import 'package:prf_design/prf_design.dart';

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
    final l10n = context.l10n;
    final statusSet = requisition.approvalStatus.statusSet(context);
    final statusLabel = requisition.approvalStatus.label(l10n);
    final requisitionDate = requisition.requisitionDate;
    final amount = l10n.requisitionsAmountKes(
      Misc.formatCash(requisition.totalAmount),
    );
    final formattedDate = Misc.formatDate(requisitionDate, 'Africa/Nairobi');
    final radius = BorderRadius.circular(PRFRadiusTokens.xl);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Column(
            children: [
              // Date badge
              ExcludeSemantics(
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 46,
                    minHeight: 46,
                  ),
                  padding: const EdgeInsets.all(PRFSpacingTokens.xs),
                  decoration: BoxDecoration(
                    color: statusSet.main,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    boxShadow: PRFShadowTokens.badge(statusSet.main),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        requisitionDate.day.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: statusSet.onColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(requisitionDate.month),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusSet.onColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Timeline line
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(
                    vertical: PRFSpacingTokens.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusSet.main.withValues(
                          alpha: PRFOpacities.prominent,
                        ),
                        theme.colorScheme.outlineVariant,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.xs),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: PRFSpacingTokens.md),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : PRFSpacingTokens.md),
            child: Semantics(
              button: true,
              label: l10n.requisitionsCardSemantics(
                amount,
                statusLabel,
                formattedDate,
              ),
              onTap: onTap,
              excludeSemantics: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
                ),
                child: Material(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: radius,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: amount + status
                        ColoredBox(
                          color: statusSet.main.withValues(
                            alpha: PRFOpacities.subtle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(PRFSpacingTokens.md),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    PRFSpacingTokens.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      PRFRadiusTokens.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.business_outlined,
                                    size: PRFSizeTokens.iconSm,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                Expanded(
                                  child: Text(
                                    amount,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                PRFStatusBadge(
                                  label: statusLabel,
                                  color: statusSet.main,
                                  foregroundColor: statusSet.onColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Details
                        Padding(
                          padding: const EdgeInsets.all(PRFSpacingTokens.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date
                              Container(
                                padding: const EdgeInsets.all(
                                  PRFSpacingTokens.md,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.md,
                                  ),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: PRFSizeTokens.iconMd,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: PRFSpacingTokens.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.requisitionsRequestedOn,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: PRFSpacingTokens.xs,
                                          ),
                                          Text(
                                            formattedDate,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (requisition.remarks?.isNotEmpty ?? false) ...[
                                const SizedBox(height: PRFSpacingTokens.md),
                                Text(
                                  requisition.remarks!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              const SizedBox(height: PRFSpacingTokens.md),

                              // View details affordance (whole card is tappable)
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  minHeight: PRFSizeTokens.minTouchTarget,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PRFSpacingTokens.md,
                                  vertical: PRFSpacingTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: statusSet.background,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.sm,
                                  ),
                                  border: Border.all(
                                    color: statusSet.main.withValues(
                                      alpha: PRFOpacities.glow,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        l10n.viewDetails,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: statusSet.foreground,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: PRFSpacingTokens.sm),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: PRFSizeTokens.iconMd,
                                      color: statusSet.foreground,
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
          ),
        ),
      ],
    );
  }
}
