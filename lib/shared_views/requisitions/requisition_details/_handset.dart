import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_items_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared_views/requisitions/cubit/delete_requisition_item_cubit.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/approval_requisition/_handset.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_payment_instruction/create_payment_instruction.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition_item/create_requisition_item.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/edit_requisition/_handset.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/edit_requisition_item/edit_requisition_item.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/recall_requisition/recall_requisition.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/request_review/_handset.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/shared_widgets/progress/circular_progress_indicator.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/current_member_mixin.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class RequisitionDetailsPageHandset extends StatefulWidget {
  const RequisitionDetailsPageHandset({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  State<RequisitionDetailsPageHandset> createState() =>
      _RequisitionDetailsPageHandsetState();
}

class _RequisitionDetailsPageHandsetState
    extends State<RequisitionDetailsPageHandset>
    with CurrentMemberMixin {
  @override
  void initState() {
    super.initState();

    context.read<GetRequisitionCubit>().getRequisition(
      requisitionUlid: widget.requisitionUlid,
    );

    context.read<GetRequisitionItemsCubit>().getRequisitionItems(
      requisitionUlid: widget.requisitionUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
      builder: (context, requisitionState) {
        return Scaffold(
          appBar: PRFAppBar(
            title: l10n.requisitionDetails,

            actions: requisitionState.maybeWhen(
              loaded: (requisition) => [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        requisition.approvalStatus.icon,
                        size: 14,
                        color: requisition.approvalStatus.color(
                          Theme.of(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        requisition.approvalStatus.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: requisition.approvalStatus.color(
                            Theme.of(context),
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              orElse: () => null,
            ),
          ),
          body: BlocBuilder<GetRequisitionItemsCubit, GetRequisitionItemsState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () => const Center(
                  child: PRFCircularProgressIndicator(),
                ),
                loaded: (requisitionItems) =>
                    BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
                      builder: (context, requisitionState) {
                        return requisitionState.maybeWhen(
                          loaded: (requisition) => _buildRequisitionItemsList(
                            context,
                            l10n,
                            requisitionItems,
                            requisition,
                          ),
                          orElse: () => _buildRequisitionItemsList(
                            context,
                            l10n,
                            requisitionItems,
                            null,
                          ),
                        );
                      },
                    ),
                empty: () => _buildEmptyState(context, l10n),
                error: (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.error}: $message',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<GetRequisitionItemsCubit>()
                              .getRequisitionItems(
                                requisitionUlid: widget.requisitionUlid,
                              );
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: _buildBottomActionBar(context, l10n),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
      builder: (context, requisitionState) {
        return requisitionState.maybeWhen(
          loaded: (requisition) => _buildEmptyStateContent(
            context,
            theme,
            requisition.approvalStatus,
          ),
          orElse: () => _buildEmptyStateContent(
            context,
            theme,
            PRFApprovalStatus.pending,
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateContent(
    BuildContext context,
    ThemeData theme,
    PRFApprovalStatus status,
  ) {
    final l10n = context.l10n;
    final isEditable = status == PRFApprovalStatus.pending;
    final isUnderReview = status == PRFApprovalStatus.underReview;

    IconData emptyStateIcon;
    String title;
    String subtitle;
    Color iconColor;

    switch (status) {
      case PRFApprovalStatus.pending:
        emptyStateIcon = Icons.receipt_long_outlined;
        title = l10n.noRequisitionItems;
        subtitle = l10n.noItemsAddedYet;
        iconColor = status.color(theme);
      case PRFApprovalStatus.underReview:
        emptyStateIcon = Icons.hourglass_empty;
        title = l10n.underReview;
        subtitle = l10n.requisitionUnderReviewDesc;
        iconColor = status.color(theme);
      case PRFApprovalStatus.approved:
        emptyStateIcon = Icons.check_circle_outline;
        title = l10n.requisitionApproved;
        subtitle = l10n.requisitionApprovedDesc;
        iconColor = status.color(theme);
      case PRFApprovalStatus.rejected:
        emptyStateIcon = Icons.cancel_outlined;
        title = l10n.requisitionRejected;
        subtitle = l10n.requisitionRejectedDesc;
        iconColor = status.color(theme);
      case PRFApprovalStatus.recalled:
        emptyStateIcon = Icons.undo_outlined;
        title = l10n.requisitionRecalled;
        subtitle = l10n.requisitionRecalledDesc;
        iconColor = status.color(theme);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyStateIcon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isEditable)
              ElevatedButton.icon(
                onPressed: Misc.userCan(PRFPermissions.createRequisitionItem)
                    ? () => _showCreateRequisitionItemModal(context)
                    : null,
                icon: const Icon(Icons.add),
                label: Text(l10n.addItem),

                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              )
            else if (isUnderReview)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: status.color(theme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: status.color(theme).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: status.color(theme),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.reviewInProgress,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.color(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => context.router.pop(),
                icon: const Icon(Icons.add),
                label: Text(l10n.createNewRequisition),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequisitionItemsList(
    BuildContext context,
    AppLocalizations l10n,
    List<PRFRequisitionItem> items,
    PRFRequisition? requisition,
  ) {
    final theme = Theme.of(context);

    return BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
      builder: (context, requisitionState) {
        return CustomScrollView(
          slivers: [
            // Requisition Details Header
            SliverToBoxAdapter(
              child: requisitionState.maybeWhen(
                loaded: (requisition) =>
                    _buildRequisitionDetailsCard(context, requisition),
                orElse: () => const SizedBox.shrink(),
              ),
            ),

            // Items list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return _buildRequisitionItemCard(
                      context,
                      theme,
                      item,
                      index,
                      requisition,
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),

            // Bottom spacing for bottom action bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequisitionItemCard(
    BuildContext context,
    ThemeData theme,
    PRFRequisitionItem item,
    int index,
    PRFRequisition? requisition,
  ) {
    final l10n = context.l10n;
    final isEditable = requisition?.approvalStatus == PRFApprovalStatus.pending;
    final isDeletable =
        isEditable && Misc.userCan(PRFPermissions.deleteRequisitionItem);

    return BlocListener<DeleteRequisitionItemCubit, DeleteRequisitionItemState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: () {
                // Refresh the lists after deletion
                context.read<GetRequisitionCubit>().getRequisition(
                  requisitionUlid: widget.requisitionUlid,
                );
                context.read<GetRequisitionItemsCubit>().getRequisitionItems(
                  requisitionUlid: widget.requisitionUlid,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: theme.colorScheme.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              orElse: () {},
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                    theme.colorScheme.primary.withValues(alpha: 0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(1.2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Main content
                    InkWell(
                      onTap: isEditable
                          ? () => _showEditRequisitionItemModal(context, item)
                          : () => _showItemDetails(context, item),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          18,
                          isDeletable ? 56 : 16,
                          18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon, name, category, and price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon badge
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 22,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name and category
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.1,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (item.expenseCategory != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                item.expenseCategory!.name,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          if (item.expenseCategory != null)
                                            const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.event_note,
                                                  size: 14,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat.MMMd().format(
                                                    item.createdAt,
                                                  ),
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Total price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        NumberFormat.currency(
                                          symbol: 'KES ',
                                          decimalDigits: 0,
                                        ).format(item.totalPrice),
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Total',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Narration if available
                            if (item.narration != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.notes,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.narration!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Details chips
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _buildDetailChip(
                                  context,
                                  '${item.quantity}',
                                  Icons.numbers,
                                  'Qty',
                                ),
                                const SizedBox(width: 10),
                                _buildDetailChip(
                                  context,
                                  NumberFormat.currency(
                                    symbol: 'KES ',
                                    decimalDigits: 0,
                                  ).format(item.unitPrice),
                                  Icons.attach_money,
                                  'Unit',
                                ),
                                const SizedBox(width: 10),
                                _buildDetailChip(
                                  context,
                                  DateFormat.yMMMd().format(item.createdAt),
                                  Icons.calendar_today,
                                  'Date',
                                ),
                              ],
                            ),

                            if (isEditable) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tap to edit item',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Delete button (floating action on the card)
                    if (isDeletable)
                      Positioned(
                        right: 10,
                        top: 10,
                        child:
                            BlocBuilder<
                              DeleteRequisitionItemCubit,
                              DeleteRequisitionItemState
                            >(
                              builder: (context, state) {
                                final isLoading = state.maybeWhen(
                                  orElse: () => false,
                                  loading: (loadingIndex) =>
                                      loadingIndex == index,
                                );
                                return Material(
                                  color: Colors.transparent,
                                  child: Tooltip(
                                    message: 'Delete Item',
                                    child: InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () => _showDeleteConfirmationDialog(
                                              context,
                                              item,
                                              theme,
                                              l10n,
                                              index,
                                            ),
                                      borderRadius: BorderRadius.circular(22),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error
                                              .withValues(
                                                alpha: 0.12,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.error
                                                .withValues(
                                                  alpha: 0.3,
                                                ),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    // ignore: lines_longer_than_80_chars
                                                    PRFCircularProgressIndicator(),
                                              )
                                            : Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: theme.colorScheme.error,
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.25)
        .fadeIn(duration: 380.ms);
  }

  Widget _buildDetailChip(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, PRFRequisitionItem item) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            pageTitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (item.expenseCategory != null) ...[
                    _buildDetailRow(
                      context,
                      l10n.category,
                      item.expenseCategory!.name,
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildDetailRow(
                    context,
                    l10n.unitPrice,
                    NumberFormat.currency(
                      symbol: 'KES ',
                      decimalDigits: 0,
                    ).format(item.unitPrice),
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    l10n.quantity,
                    '${item.quantity}',
                    Icons.numbers,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    l10n.totalPrice,
                    NumberFormat.currency(
                      symbol: 'KES ',
                      decimalDigits: 0,
                    ).format(item.totalPrice),
                    Icons.calculate,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    l10n.created,
                    DateFormat.yMMMd().add_Hm().format(item.createdAt),
                    Icons.schedule,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    PRFRequisitionItem item,
    ThemeData theme,
    AppLocalizations l10n,
    int index,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Item',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this item?',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat.currency(
                        symbol: 'KES ',
                        decimalDigits: 0,
                      ).format(item.totalPrice)} • Qty: ${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            BlocConsumer<
              DeleteRequisitionItemCubit,
              DeleteRequisitionItemState
            >(
              listener: (listenerContext, state) {
                state.maybeWhen(
                  loaded: () {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  error: (message) {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  orElse: () {},
                );
              },
              builder: (consumerContext, state) {
                return state.maybeWhen(
                  loading: (_) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  orElse: () =>
                      _buildDeleteActionButton(context, theme, item, index),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteActionButton(
    BuildContext context,
    ThemeData theme,
    PRFRequisitionItem item,
    int index,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<DeleteRequisitionItemCubit>().deleteRequisitionItem(
          requisitionItemUlid: item.ulid,
          index: index,
        );
      },
      icon: const Icon(Icons.delete_outline, size: 18),
      label: const Text('Delete'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
      builder: (context, requisitionState) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status-aware action rows
                  ...requisitionState.maybeWhen(
                    loaded: (requisition) => _buildStatusAwareActions(
                      context,
                      l10n,
                      requisition.approvalStatus,
                      requisition.paymentInstruction,
                    ),
                    orElse: () => _buildDefaultActions(context, l10n),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStatusAwareActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFApprovalStatus status,
    PRFPaymentInstruction? paymentInstruction,
  ) {
    switch (status) {
      case PRFApprovalStatus.pending:
        return _buildPendingActions(context, l10n, paymentInstruction);
      case PRFApprovalStatus.underReview:
        return _buildUnderReviewActions(context, l10n, paymentInstruction);
      case PRFApprovalStatus.approved:
        return _buildApprovedActions(context, l10n, paymentInstruction);
      case PRFApprovalStatus.rejected:
        return _buildRejectedActions(context, l10n);
      case PRFApprovalStatus.recalled:
        return [];
    }
  }

  List<Widget> _buildPendingActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFPaymentInstruction? paymentInstruction,
  ) {
    return [
      // Primary Actions Row
      Row(
        children: [
          // Add Item Action
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add,
              label: l10n.create,
              onPressed: () => _showCreateRequisitionItemModal(context),
              isPrimary: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisitionItem),
            ),
          ),
          const SizedBox(width: 12),
          // Payment Action
          Expanded(
            child: _buildActionButton(
              context,
              icon: paymentInstruction != null
                  ? Icons.visibility
                  : Icons.payment,
              label: paymentInstruction != null
                  ? l10n.viewPayment
                  : l10n.payment,
              onPressed: () => paymentInstruction != null
                  ? _showPaymentInstructionDetails(context, paymentInstruction)
                  : _showCreatePaymentInstructionModal(context),
              isSecondary: paymentInstruction != null,
              isDisabled: !Misc.userCan(
                PRFPermissions.createPaymentInstruction,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Secondary Actions Row
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.send,
              label: l10n.requestReview,
              onPressed: () => _showRequestReviewModal(context),
              isOutlined: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisition),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.more_horiz,
              label: l10n.more,
              onPressed: () => _showMoreActionsBottomSheet(context),
              isOutlined: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisition),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildUnderReviewActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFPaymentInstruction? paymentInstruction,
  ) {
    final theme = Theme.of(context);
    final statusColor = PRFApprovalStatus.underReview.color(theme);

    return [
      BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
        builder: (context, requisitionState) {
          return requisitionState.maybeWhen(
            loaded: (requisition) {
              // Check if the logged-in user is the appointed approver
              final isAppointed =
                  loggedInMember.ulid == requisition.appointedApprover?.ulid;

              if (isAppointed) {
                // Show approval banner for the appointed approver
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fact_check,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This requisition is awaiting your approval.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Show standard under review banner for non-approvers
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PRFApprovalStatus.underReview.icon,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.requisitionUnderReviewBanner,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            orElse: () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    PRFApprovalStatus.underReview.icon,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.requisitionUnderReviewBanner,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Actions row
      BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
        builder: (context, requisitionState) {
          return requisitionState.maybeWhen(
            loaded: (requisition) {
              final isAppointed =
                  loggedInMember.ulid == requisition.appointedApprover?.ulid;

              if (isAppointed) {
                // Show approval actions for the appointed approver
                return Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.check_circle,
                        label: 'Review & Approve',
                        onPressed: () => _showApprovalModal(context),
                        isPrimary: true,
                      ),
                    ),
                    if (paymentInstruction != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.visibility,
                          label: l10n.viewPayment,
                          onPressed: () => _showPaymentInstructionDetails(
                            context,
                            paymentInstruction,
                          ),
                          isSecondary: true,
                        ),
                      ),
                    ],
                  ],
                );
              } else {
                // Show limited actions for non-approvers
                return Column(
                  children: [
                    Row(
                      children: [
                        if (paymentInstruction != null) ...[
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.visibility,
                              label: l10n.viewPayment,
                              onPressed: () => _showPaymentInstructionDetails(
                                context,
                                paymentInstruction,
                              ),
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.info_outline,
                            label: l10n.details,
                            onPressed: () =>
                                _showMoreActionsBottomSheet(context),
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                    // Show recall button for requisitors
                    if (loggedInMember.ulid == requisition.member?.ulid) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          context,
                          icon: Icons.undo,
                          label: 'Recall',
                          onPressed: () => _showRecallRequisitionModal(context),
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ],
                );
              }
            },
            orElse: () => Row(
              children: [
                if (paymentInstruction != null) ...[
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.visibility,
                      label: l10n.viewPayment,
                      onPressed: () => _showPaymentInstructionDetails(
                        context,
                        paymentInstruction,
                      ),
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.info_outline,
                    label: l10n.details,
                    onPressed: () => _showMoreActionsBottomSheet(context),
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildApprovedActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFPaymentInstruction? paymentInstruction,
  ) {
    final theme = Theme.of(context);
    final statusColor = PRFApprovalStatus.approved.color(theme);

    return [
      // Approved Banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              PRFApprovalStatus.approved.icon,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.requisitionApprovedBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      // Approved Actions
      BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
        builder: (context, requisitionState) {
          return requisitionState.maybeWhen(
            loaded: (requisition) {
              return Column(
                children: [
                  Row(
                    children: [
                      if (paymentInstruction != null) ...[
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.payment,
                            label: l10n.paymentDetails,
                            onPressed: () => _showPaymentInstructionDetails(
                              context,
                              paymentInstruction,
                            ),
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.add,
                          label: l10n.newRequisition,
                          onPressed: () => context.router.pop(),
                          isSecondary: true,
                        ),
                      ),
                    ],
                  ),
                  // Show recall button for requisitors
                  if (loggedInMember.ulid == requisition.member?.ulid) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(
                        context,
                        icon: Icons.undo,
                        label: 'Recall',
                        onPressed: () => _showRecallRequisitionModal(context),
                        isOutlined: true,
                      ),
                    ),
                  ],
                ],
              );
            },
            orElse: () => Row(
              children: [
                if (paymentInstruction != null) ...[
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.payment,
                      label: l10n.paymentDetails,
                      onPressed: () => _showPaymentInstructionDetails(
                        context,
                        paymentInstruction,
                      ),
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.add,
                    label: l10n.newRequisition,
                    onPressed: () => context.router.pop(),
                    isSecondary: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildRejectedActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final statusColor = PRFApprovalStatus.rejected.color(theme);

    return [
      // Rejected Banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              PRFApprovalStatus.rejected.icon,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.requisitionRejectedBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      // Rejected Actions
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add,
              label: l10n.newRequisition,
              onPressed: () => context.router.pop(),
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.info_outline,
              label: l10n.viewDetails,
              onPressed: () => _showMoreActionsBottomSheet(context),
              isOutlined: true,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDefaultActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add,
              label: l10n.create,
              onPressed: () => _showCreateRequisitionItemModal(context),
              isPrimary: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisitionItem),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.payment,
              label: l10n.payment,
              onPressed: () => _showCreatePaymentInstructionModal(context),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isSecondary = false,
    bool isOutlined = false,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? border;

    if (isDisabled) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      foregroundColor = theme.colorScheme.onSurfaceVariant;
      border = null;
    } else if (isPrimary) {
      backgroundColor = theme.colorScheme.primary;
      foregroundColor = theme.colorScheme.onPrimary;
      border = null;
    } else if (isSecondary) {
      backgroundColor = theme.colorScheme.tertiary;
      foregroundColor = theme.colorScheme.onTertiary;
      border = null;
    } else if (isOutlined) {
      backgroundColor = Colors.transparent;
      foregroundColor = theme.colorScheme.primary;
      border = BorderSide(color: theme.colorScheme.outline);
    } else {
      backgroundColor = theme.colorScheme.secondary;
      foregroundColor = theme.colorScheme.onSecondary;
      border = null;
    }

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDisabled
              ? theme.colorScheme.onSurfaceVariant
              : foregroundColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        side: border,
        elevation: isOutlined ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showRequestReviewModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: RequestReviewViewHandset(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the requisition after requesting review
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showMoreActionsBottomSheet(BuildContext context) {
    final l10n = context.l10n;
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            pageTitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.moreActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Status-aware Action Items
                  BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
                    builder: (context, requisitionState) {
                      return requisitionState.maybeWhen(
                        loaded: (requisition) => Column(
                          children: _buildStatusAwareBottomSheetActions(
                            context,
                            requisition,
                          ),
                        ),
                        orElse: () => Column(
                          children: _buildDefaultBottomSheetActions(context),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  List<Widget> _buildStatusAwareBottomSheetActions(
    BuildContext context,
    PRFRequisition requisition,
  ) {
    final l10n = context.l10n;
    final baseActions = <Widget>[
      if (loggedInMember.ulid == requisition.member?.ulid &&
          requisition.appointedApprover != null)
        _buildBottomSheetAction(
          context,
          icon: Icons.call,
          title: l10n.callApprover,
          subtitle: l10n.callDesc(requisition.appointedApprover!.fullName),
          onTap: () async {
            Navigator.pop(context);
            if (requisition.appointedApprover?.phoneNumber == null ||
                requisition.appointedApprover!.phoneNumber!.trim().isEmpty) {
              await _makePhoneCall(requisition.appointedApprover!.phoneNumber);
            }
          },
        ),

      if (loggedInMember.ulid == requisition.appointedApprover?.ulid)
        _buildBottomSheetAction(
          context,
          icon: Icons.call,
          title: l10n.callRequisitor,
          subtitle: l10n.callDesc(requisition.appointedApprover!.fullName),
          onTap: () async {
            Navigator.pop(context);
            if (requisition.appointedApprover?.phoneNumber == null ||
                requisition.appointedApprover!.phoneNumber!.trim().isEmpty) {
              await _makePhoneCall(requisition.appointedApprover!.phoneNumber);
            }
          },
        ),
    ];

    switch (requisition.approvalStatus) {
      case PRFApprovalStatus.pending:
        return [
          ...baseActions,
          _buildBottomSheetAction(
            context,
            icon: Icons.edit,
            title: l10n.editRequisition,
            subtitle: l10n.modifyRequisitionDetails,
            onTap: () {
              Navigator.pop(context);
              _showEditRequisitionModal(context);
            },
          ),
        ];

      case PRFApprovalStatus.underReview:
        return [
          ...baseActions,
          if (loggedInMember.ulid == requisition.member?.ulid)
            _buildBottomSheetAction(
              context,
              icon: Icons.undo,
              title: 'Recall',
              subtitle: 'Withdraw this requisition from review',
              onTap: () {
                Navigator.pop(context);
                _showRecallRequisitionModal(context);
              },
            ),
        ];

      case PRFApprovalStatus.recalled:
        return [];

      case PRFApprovalStatus.approved:
        return [
          ...baseActions,
          if (requisition.approvalNotes != null)
            _buildBottomSheetAction(
              context,
              icon: Icons.note_alt,
              title: l10n.approvalNotes,
              subtitle: requisition.approvalNotes!,
              onTap: () {
                Navigator.pop(context);
                _showApprovalNotesDialog(
                  context,
                  l10n.approvalNotes,
                  requisition.approvalNotes!,
                );
              },
            ),
        ];

      case PRFApprovalStatus.rejected:
        return [
          ...baseActions,
          if (requisition.approvalNotes != null)
            _buildBottomSheetAction(
              context,
              icon: Icons.feedback,
              title: l10n.rejectionReason,
              subtitle: requisition.approvalNotes!,
              onTap: () {
                Navigator.pop(context);
                _showApprovalNotesDialog(
                  context,
                  l10n.rejectionDetails,
                  requisition.approvalNotes!,
                );
              },
            ),
        ];
    }
  }

  List<Widget> _buildDefaultBottomSheetActions(BuildContext context) {
    final l10n = context.l10n;
    return [
      _buildBottomSheetAction(
        context,
        icon: Icons.info_outline,
        title: l10n.requisitionInfo,
        subtitle: l10n.viewGeneralInformation,
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }

  Widget _buildBottomSheetAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showCreateRequisitionItemModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: CreateRequisitionItemView(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the list after adding an item
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
        context.read<GetRequisitionItemsCubit>().getRequisitionItems(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showEditRequisitionItemModal(
    BuildContext context,
    PRFRequisitionItem item,
  ) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: EditRequisitionItemView(
              requisitionItemUlid: item.ulid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the list after editing an item
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
        context.read<GetRequisitionItemsCubit>().getRequisitionItems(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showCreatePaymentInstructionModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: CreatePaymentInstructionView(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh requisition after creating payment instruction
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showPaymentInstructionDetails(
    BuildContext context,
    PRFPaymentInstruction paymentInstruction,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            pageTitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.paymentInstructions,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Payment Method Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getPaymentMethodIcon(
                            paymentInstruction.paymentMethod,
                          ),
                          color: theme.colorScheme.onPrimary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPaymentMethodDisplayName(
                            paymentInstruction.paymentMethod,
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recipient Details
                  _buildPaymentDetailRow(
                    context,
                    l10n.recipientName,
                    paymentInstruction.recipientName,
                    Icons.person_outline,
                  ),

                  if (paymentInstruction.reference != null) ...[
                    const SizedBox(height: 12),
                    _buildPaymentDetailRow(
                      context,
                      l10n.reference,
                      paymentInstruction.reference!,
                      Icons.receipt_long_outlined,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Method-specific details
                  ..._buildPaymentMethodSpecificDetails(
                    context,
                    paymentInstruction,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  IconData _getPaymentMethodIcon(PRFPaymentMethod method) {
    switch (method) {
      case PRFPaymentMethod.mpesa:
        return Icons.phone_android;
      case PRFPaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PRFPaymentMethod.paybill:
        return Icons.receipt;
      case PRFPaymentMethod.tillNumber:
        return Icons.store;
    }
  }

  String _getPaymentMethodDisplayName(PRFPaymentMethod method) {
    switch (method) {
      case PRFPaymentMethod.mpesa:
        return 'M-PESA';
      case PRFPaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PRFPaymentMethod.paybill:
        return 'Paybill';
      case PRFPaymentMethod.tillNumber:
        return 'Till Number';
    }
  }

  List<Widget> _buildPaymentMethodSpecificDetails(
    BuildContext context,
    PRFPaymentInstruction paymentInstruction,
  ) {
    final l10n = context.l10n;
    switch (paymentInstruction.paymentMethod) {
      case PRFPaymentMethod.mpesa:
        return [
          if (paymentInstruction.mpesaPhoneNumber != null)
            _buildPaymentDetailRow(
              context,
              l10n.phoneNumber,
              '+${paymentInstruction.mpesaPhoneNumber}',
              Icons.phone,
            ),
        ];

      case PRFPaymentMethod.bankTransfer:
        return [
          if (paymentInstruction.bankName != null)
            _buildPaymentDetailRow(
              context,
              l10n.bankName,
              paymentInstruction.bankName!,
              Icons.account_balance,
            ),
          if (paymentInstruction.bankAccountNumber != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              l10n.accountNumber,
              paymentInstruction.bankAccountNumber.toString(),
              Icons.numbers,
            ),
          ],
          if (paymentInstruction.bankAccountName != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              l10n.accountName,
              paymentInstruction.bankAccountName!,
              Icons.person,
            ),
          ],
          if (paymentInstruction.bankBranch != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              l10n.branch,
              paymentInstruction.bankBranch!,
              Icons.location_on,
            ),
          ],
          if (paymentInstruction.bankSwiftCode != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              l10n.swiftCode,
              paymentInstruction.bankSwiftCode!,
              Icons.code,
            ),
          ],
        ];

      case PRFPaymentMethod.paybill:
        return [
          if (paymentInstruction.paybillNumber != null)
            _buildPaymentDetailRow(
              context,
              l10n.paybillNumber,
              paymentInstruction.paybillNumber.toString(),
              Icons.receipt,
            ),
          if (paymentInstruction.paybillAccountNumber != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              l10n.accountNumber,
              paymentInstruction.paybillAccountNumber!,
              Icons.account_box,
            ),
          ],
        ];

      case PRFPaymentMethod.tillNumber:
        return [
          if (paymentInstruction.tillNumber != null)
            _buildPaymentDetailRow(
              context,
              l10n.tillNumber,
              paymentInstruction.tillNumber.toString(),
              Icons.store,
            ),
        ];
    }
  }

  Widget _buildPaymentDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequisitionDetailsCard(
    BuildContext context,
    PRFRequisition requisition,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            requisition.approvalStatus.color(theme),
            requisition.approvalStatus.color(theme).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: requisition.approvalStatus
                .color(theme)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  requisition.approvalStatus.icon,
                  color: requisition.approvalStatus.color(theme),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.requisitionDetails,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.idLabel(
                        requisition.ulid.substring(0, 8).toUpperCase(),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(requisition.approvalStatus, theme),
            ],
          ),

          const SizedBox(height: 20),

          // Details Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.desk,
                      requisition.responsibleDesk.name,
                      Icons.work_outline,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.totalAmount,
                      NumberFormat.currency(
                        symbol: 'KES ',
                        decimalDigits: 0,
                      ).format(requisition.totalAmount),
                      Icons.attach_money,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.created,
                      DateFormat.yMMMd().format(requisition.createdAt),
                      Icons.calendar_today,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.requisitionDate,
                      DateFormat.yMMMd().format(requisition.requisitionDate),
                      Icons.event,
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Member Information
          if (requisition.member != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.surface.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: theme.colorScheme.surface,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.requestedBy,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requisition.member!.fullName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Approval Information
          if (requisition.approvalStatus != PRFApprovalStatus.pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.surface.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        requisition.approvalStatus.icon,
                        color: theme.colorScheme.surface,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        requisition.approvalStatus.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      if (requisition.approvedBy != null)
                        Expanded(
                          child: Text(
                            '${requisition.approvedBy!.firstName} '
                            '${requisition.approvedBy!.lastName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.surface,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                  if (requisition.approvalNotes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.notes}: ${requisition.approvalNotes}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.date}: ${DateFormat.yMMMd().add_Hm().format(
                      requisition.approvedAt ?? requisition.createdAt,
                    )}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().slideY(begin: -0.2).fadeIn(duration: 500.ms);
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.surface.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.surface,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PRFApprovalStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color(theme),
          ),
          const SizedBox(width: 6),
          Text(
            status.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: status.color(theme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalNotesDialog(
    BuildContext context,
    String title,
    String notes,
  ) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                title.contains('Rejection') ? Icons.cancel : Icons.check_circle,
                color: title.contains('Rejection')
                    ? PRFApprovalStatus.rejected.color(theme)
                    : PRFApprovalStatus.approved.color(theme),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Text(
              notes,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showApprovalModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: ApproveRequisitionViewHandset(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the requisition after approval/rejection
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showEditRequisitionModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: EditRequisitionViewHandset(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the requisition after editing
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  void _showRecallRequisitionModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: RecallRequisitionView(
              requisitionUlid: widget.requisitionUlid,
            ),
          ),
        ];
      },
    ).then((_) {
      // Refresh the requisition after recalling
      if (context.mounted) {
        context.read<GetRequisitionCubit>().getRequisition(
          requisitionUlid: widget.requisitionUlid,
        );
      }
    });
  }

  /// Make a phone call using the phone number
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return;
    }

    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

    final success = await Misc.openUrl(phoneUri);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to make call'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
