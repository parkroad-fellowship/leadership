import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_detail_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/approval_requisition/_handset.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_payment_instruction/create_payment_instruction.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_requisition_item/create_requisition_item.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/edit_requisition/_handset.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/edit_requisition_item/edit_requisition_item.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/recall_requisition/recall_requisition.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/request_review/_handset.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
import 'package:leadership/shared/requisitions/widgets/approval_status_style.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/mixins/current_member_mixin.dart';
import 'package:prf_design/prf_design.dart';

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
  String? _deletingRequisitionItemUlid;

  @override
  void initState() {
    super.initState();

    context.read<RequisitionDetailCubit>().loadOne(
      id: widget.requisitionUlid,
      matchById: (item) => item.ulid == widget.requisitionUlid,
    );

    _reloadItems();
  }

  PRFRequisition? _currentRequisitionFromState(
    ResourceState<PRFRequisition> state,
  ) {
    // Keep showing the last known requisition while it refreshes or after a
    // failed action, so the page and its actions don't disappear.
    return switch (state) {
      ResourceItemLoaded<PRFRequisition>(:final item) => item,
      ResourceItemLoading<PRFRequisition>(:final item?) => item,
      ResourceItemError<PRFRequisition>(:final item?) => item,
      ResourceMutating<PRFRequisition>(:final items) when items.isNotEmpty =>
        items.first,
      _ => null,
    };
  }

  void _reloadRequisition() {
    context.read<RequisitionDetailCubit>().loadOne(
      id: widget.requisitionUlid,
      matchById: (item) => item.ulid == widget.requisitionUlid,
      refresh: true,
    );
  }

  void _reloadItems() {
    context.read<RequisitionItemResourceCubit>().loadForRequisition(
      requisitionUlid: widget.requisitionUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
      builder: (context, requisitionState) {
        final requisition = _currentRequisitionFromState(requisitionState);
        final requisitionFailed =
            requisition == null &&
            requisitionState is ResourceItemError<PRFRequisition>;
        return Scaffold(
          body: Column(
            children: [
              ColoredBox(
                color: theme.colorScheme.primary,
                child: PRFBrandedNavBar(
                  title: l10n.requisitionDetails,
                  onBack: context.router.maybePop,
                  actions: requisition != null
                      ? [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: PRFSpacingTokens.lg,
                            ),
                            child: PRFStatusBadge(
                              label: requisition.approvalStatus.label(l10n),
                              color: requisition.approvalStatus
                                  .statusSet(context)
                                  .main,
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: requisitionFailed
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                          child: PRFErrorView.inline(
                            title: l10n.requisitionDetailLoadErrorTitle,
                            message: l10n.requisitionDetailLoadErrorMessage,
                            retryLabel: l10n.tryAgain,
                            onRetry: () {
                              context
                                  .read<RequisitionItemResourceCubit>()
                                  .invalidate();
                              _reloadRequisition();
                              _reloadItems();
                            },
                          ),
                        ),
                      )
                    : BlocBuilder<
                        RequisitionItemResourceCubit,
                        ResourceState<PRFRequisitionItem>
                      >(
                        builder: (context, state) {
                          return switch (state) {
                            ResourceListLoaded<PRFRequisitionItem>(:final items)
                                when items.isEmpty =>
                              _buildEmptyState(context, l10n),
                            ResourceListLoaded<PRFRequisitionItem>(
                              :final items,
                            ) =>
                              _buildRequisitionItemsList(
                                context,
                                l10n,
                                items,
                                requisition,
                              ),
                            ResourceMutating<PRFRequisitionItem>(:final items)
                                when items.isEmpty =>
                              _buildEmptyState(context, l10n),
                            ResourceMutating<PRFRequisitionItem>(
                              :final items,
                            ) =>
                              _buildRequisitionItemsList(
                                context,
                                l10n,
                                items,
                                requisition,
                              ),
                            // A failed action (e.g. delete) keeps the list.
                            ResourceError<PRFRequisitionItem>(:final items)
                                when items.isNotEmpty =>
                              _buildRequisitionItemsList(
                                context,
                                l10n,
                                items,
                                requisition,
                              ),
                            ResourceError<PRFRequisitionItem>() => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  PRFSpacingTokens.xl,
                                ),
                                child: PRFErrorView.inline(
                                  title:
                                      l10n.requisitionDetailItemsLoadErrorTitle,
                                  message:
                                      l10n.requisitionDetailLoadErrorMessage,
                                  retryLabel: l10n.tryAgain,
                                  onRetry: _reloadItems,
                                ),
                              ),
                            ),
                            _ => const Center(
                              child: PRFCircularProgressIndicator(),
                            ),
                          };
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: requisitionFailed
              ? null
              : _buildBottomActionBar(context, l10n),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
      builder: (context, requisitionState) {
        final requisition = _currentRequisitionFromState(requisitionState);
        return _buildEmptyStateContent(
          context,
          theme,
          requisition?.approvalStatus ?? PRFApprovalStatus.pending,
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
    final statusColors = status.statusSet(context);

    final (
      IconData emptyStateIcon,
      String title,
      String subtitle,
    ) = switch (status) {
      PRFApprovalStatus.pending => (
        Icons.receipt_long_outlined,
        l10n.noRequisitionItems,
        l10n.noItemsAddedYet,
      ),
      PRFApprovalStatus.underReview => (
        Icons.hourglass_empty,
        l10n.underReview,
        l10n.requisitionUnderReviewDesc,
      ),
      PRFApprovalStatus.approved => (
        Icons.check_circle_outline,
        l10n.requisitionApproved,
        l10n.requisitionApprovedDesc,
      ),
      PRFApprovalStatus.rejected => (
        Icons.cancel_outlined,
        l10n.requisitionRejected,
        l10n.requisitionRejectedDesc,
      ),
      PRFApprovalStatus.recalled => (
        Icons.undo_outlined,
        l10n.requisitionDetailRecalledTitle,
        l10n.requisitionRecalledDesc,
      ),
      PRFApprovalStatus.ghost => (
        Icons.help_outline,
        l10n.zeroBasedRequisition,
        l10n.zeroBasedRequisitionDesc,
      ),
    };

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequisitionItemResourceCubit>().invalidate();
        _reloadRequisition();
        _reloadItems();
      },
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        emptyStateIcon,
                        size: PRFSizeTokens.iconHero,
                        color: statusColors.main,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.sm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    if (isEditable)
                      PRFButton(
                        onPressed: () =>
                            _showCreateRequisitionItemModal(context),
                        title: l10n.addItem,
                        disabled: !Misc.userCan(
                          PRFPermissions.createRequisitionItem,
                        ),
                      )
                    else if (isUnderReview)
                      requisitionStatusBanner(
                        context,
                        colors: statusColors,
                        icon: Icons.info_outline,
                        message: l10n.reviewInProgress,
                      )
                    else
                      PRFButton(
                        onPressed: () => context.router.pop(),
                        title: l10n.createNewRequisition,
                        variant: PRFButtonVariant.secondary,
                      ),
                  ],
                ),
              ),
            ),
          ),
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

    return CustomScrollView(
      slivers: [
        // Requisition Details Header
        SliverToBoxAdapter(
          child: requisition != null
              ? _buildRequisitionDetailsCard(context, requisition)
              : const SizedBox.shrink(),
        ),

        // Items list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return _buildRequisitionItemCard(
                context,
                theme,
                item,
                index,
                requisition,
              );
            }, childCount: items.length),
          ),
        ),

        // Bottom spacing for bottom action bar
        const SliverToBoxAdapter(
          child: SizedBox(height: PRFSpacingTokens.xxxl),
        ),
      ],
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
    final scheme = theme.colorScheme;
    final isEditable = requisition?.approvalStatus == PRFApprovalStatus.pending;
    final isDeletable =
        isEditable && Misc.userCan(PRFPermissions.deleteRequisitionItem);
    final cardRadius = BorderRadius.circular(PRFRadiusTokens.lg);

    return BlocListener<
          RequisitionItemResourceCubit,
          ResourceState<PRFRequisitionItem>
        >(
          listener: (context, state) {
            if (_deletingRequisitionItemUlid != item.ulid) return;

            state.maybeWhen(
              itemLoaded: (item, items) {
                setState(() => _deletingRequisitionItemUlid = null);
                _reloadRequisition();
                PRFSnackbar.success(context, l10n.requisitionDetailItemDeleted);
              },
              error: (_, _) {
                setState(() => _deletingRequisitionItemUlid = null);
                PRFSnackbar.error(
                  context,
                  l10n.requisitionDetailItemDeleteFailed,
                );
              },
              orElse: () {},
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: cardRadius,
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: PRFShadowTokens.card(scheme.shadow),
            ),
            child: Stack(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEditable
                        ? () => _showEditRequisitionItemModal(context, item)
                        : () => _showItemDetails(context, item),
                    borderRadius: cardRadius,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        PRFSpacingTokens.lg,
                        PRFSpacingTokens.lg,
                        isDeletable
                            ? PRFSpacingTokens.sm + PRFSizeTokens.minTouchTarget
                            : PRFSpacingTokens.lg,
                        PRFSpacingTokens.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  PRFSpacingTokens.md,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.smd,
                                  ),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: PRFSizeTokens.iconLg,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: PRFSpacingTokens.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: PRFSpacingTokens.xs),
                                    Wrap(
                                      spacing: PRFSpacingTokens.sm,
                                      runSpacing: PRFSpacingTokens.xs,
                                      children: [
                                        if (item.expenseCategory != null)
                                          _buildPill(
                                            context,
                                            label: item.expenseCategory!.name,
                                            background:
                                                scheme.secondaryContainer,
                                            foreground:
                                                scheme.onSecondaryContainer,
                                          ),
                                        _buildPill(
                                          context,
                                          label: DateFormat.MMMd().format(
                                            item.createdAt,
                                          ),
                                          icon: Icons.event_note,
                                          background:
                                              scheme.surfaceContainerHighest,
                                          foreground: scheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildPill(
                                    context,
                                    label: formatKes(item.totalPrice),
                                    background: scheme.primaryContainer,
                                    foreground: scheme.onPrimaryContainer,
                                    emphasise: true,
                                  ),
                                  const SizedBox(height: PRFSpacingTokens.xs),
                                  Text(
                                    l10n.total,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          if (item.narration != null) ...[
                            const SizedBox(height: PRFSpacingTokens.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                PRFSpacingTokens.md,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(
                                  PRFRadiusTokens.md,
                                ),
                                border: Border.all(
                                  color: scheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.notes,
                                    size: PRFSizeTokens.iconSm,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: PRFSpacingTokens.sm),
                                  Expanded(
                                    child: Text(
                                      item.narration!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
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

                          const SizedBox(height: PRFSpacingTokens.md),
                          Row(
                            children: [
                              _buildDetailChip(
                                context,
                                '${item.quantity}',
                                Icons.numbers,
                                l10n.quantity,
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              _buildDetailChip(
                                context,
                                formatKes(item.unitPrice),
                                Icons.attach_money,
                                l10n.unitPrice,
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              _buildDetailChip(
                                context,
                                DateFormat.yMMMd().format(item.createdAt),
                                Icons.calendar_today,
                                l10n.date,
                              ),
                            ],
                          ),

                          if (isEditable) ...[
                            const SizedBox(height: PRFSpacingTokens.sm),
                            Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: PRFSizeTokens.iconSm,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: PRFSpacingTokens.xs),
                                Flexible(
                                  child: Text(
                                    l10n.requisitionDetailTapToEdit,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                if (isDeletable)
                  Positioned(
                    right: PRFSpacingTokens.xs,
                    top: PRFSpacingTokens.xs,
                    child:
                        BlocBuilder<
                          RequisitionItemResourceCubit,
                          ResourceState<PRFRequisitionItem>
                        >(
                          builder: (context, state) {
                            final isLoading =
                                _deletingRequisitionItemUlid == item.ulid &&
                                state.maybeWhen(
                                  mutating: (_, operation) =>
                                      operation == ResourceOperation.delete,
                                  orElse: () => false,
                                );
                            final canDelete =
                                !isLoading &&
                                _deletingRequisitionItemUlid == null;
                            return IconButton(
                              tooltip: l10n.requisitionDetailDeleteItemTooltip(
                                item.itemName,
                              ),
                              onPressed: canDelete
                                  ? () => _showDeleteConfirmationDialog(
                                      context,
                                      item,
                                      theme,
                                      l10n,
                                    )
                                  : null,
                              style: IconButton.styleFrom(
                                minimumSize: const Size.square(
                                  PRFSizeTokens.minTouchTarget,
                                ),
                                backgroundColor: scheme.errorContainer,
                                foregroundColor: scheme.onErrorContainer,
                              ),
                              icon: isLoading
                                  ? const PRFCircularProgressIndicator(
                                      size: PRFSizeTokens.iconMd,
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      size: PRFSizeTokens.iconMd,
                                    ),
                            );
                          },
                        ),
                  ),
              ],
            ),
          ),
        )
        .entrance(
          context,
          delay: PRFMotionTokens.stagger2 * math.min(index, 8),
          slide: const Offset(0, 0.25),
        );
  }

  Widget _buildPill(
    BuildContext context, {
    required String label,
    required Color background,
    required Color foreground,
    IconData? icon,
    bool emphasise = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: emphasise ? PRFSpacingTokens.md : PRFSpacingTokens.sm,
        vertical: PRFSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: PRFSizeTokens.iconXs, color: foreground),
            const SizedBox(width: PRFSpacingTokens.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (emphasise
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.labelSmall)
                      ?.copyWith(
                        color: foreground,
                        fontWeight: emphasise
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.sm,
          vertical: PRFSpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: PRFSizeTokens.iconSm,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: PRFSpacingTokens.xs),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PRFSpacingTokens.xs),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
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
    final l10n = context.l10n;

    PRFBottomSheet.show<void>(
      context,
      title: item.itemName,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),
            if (item.expenseCategory != null) ...[
              _buildDetailRow(
                context,
                l10n.category,
                item.expenseCategory!.name,
                Icons.category_outlined,
              ),
              const SizedBox(height: PRFSpacingTokens.md),
            ],
            _buildDetailRow(
              context,
              l10n.unitPrice,
              formatKes(item.unitPrice),
              Icons.attach_money,
            ),
            const SizedBox(height: PRFSpacingTokens.md),
            _buildDetailRow(
              context,
              l10n.quantity,
              '${item.quantity}',
              Icons.numbers,
            ),
            const SizedBox(height: PRFSpacingTokens.md),
            _buildDetailRow(
              context,
              l10n.totalPrice,
              formatKes(item.totalPrice),
              Icons.calculate,
            ),
            const SizedBox(height: PRFSpacingTokens.md),
            _buildDetailRow(
              context,
              l10n.created,
              DateFormat.yMMMd().add_Hm().format(item.createdAt),
              Icons.schedule,
            ),
            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    PRFRequisitionItem item,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final scheme = theme.colorScheme;
    PRFConfirmationDialog.show(
      context,
      title: l10n.requisitionDetailDeleteItemTitle,
      isDestructive: true,
      confirmLabel: l10n.requisitionDetailDeleteItemConfirm,
      cancelLabel: l10n.cancel,
      onConfirm: () {
        setState(() => _deletingRequisitionItemUlid = item.ulid);
        context.read<RequisitionItemResourceCubit>().deleteRequisitionItem(
          requisitionItemUlid: item.ulid,
        );
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.requisitionDetailDeleteItemMessage,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PRFSpacingTokens.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
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
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  l10n.requisitionDetailItemSummary(
                    formatKes(item.totalPrice),
                    '${item.quantity}',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          Text(
            l10n.requisitionDetailCannotUndo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          size: PRFSizeTokens.iconSm,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
      builder: (context, requisitionState) {
        final requisition = _currentRequisitionFromState(requisitionState);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
                vertical: PRFSpacingTokens.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...(requisition != null
                      ? _buildStatusAwareActions(
                          context,
                          l10n,
                          requisition.approvalStatus,
                          requisition.paymentInstruction,
                        )
                      : _buildDefaultActions(context, l10n)),
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
      case PRFApprovalStatus.ghost:
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
              label: l10n.addItem,
              onPressed: () => _showCreateRequisitionItemModal(context),
              isPrimary: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisitionItem),
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          // Payment Action
          Expanded(
            child: _buildActionButton(
              context,
              icon: paymentInstruction != null
                  ? Icons.visibility
                  : Icons.payment,
              label: paymentInstruction != null
                  ? l10n.viewPayment
                  : l10n.requisitionDetailAddPayment,
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
      const SizedBox(height: PRFSpacingTokens.sm),
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
          const SizedBox(width: PRFSpacingTokens.md),
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
    return [
      BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
        builder: (context, requisitionState) {
          final requisition = _currentRequisitionFromState(requisitionState);
          final isAppointed =
              requisition != null &&
              loggedInMember.ulid == requisition.appointedApprover?.ulid;

          if (isAppointed) {
            return requisitionStatusBanner(
              context,
              colors: context.statusColors.success,
              icon: Icons.fact_check,
              message: l10n.requisitionDetailAwaitingYourApproval,
              margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
            );
          }

          return requisitionStatusBanner(
            context,
            colors: PRFApprovalStatus.underReview.statusSet(context),
            icon: PRFApprovalStatus.underReview.icon,
            message: l10n.requisitionUnderReviewBanner,
            margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          );
        },
      ),
      BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
        builder: (context, requisitionState) {
          final requisition = _currentRequisitionFromState(requisitionState);
          final isAppointed =
              requisition != null &&
              loggedInMember.ulid == requisition.appointedApprover?.ulid;

          if (isAppointed) {
            return Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.check_circle,
                    label: l10n.requisitionDetailReviewAndApprove,
                    onPressed: () => _showApprovalModal(context),
                    isPrimary: true,
                  ),
                ),
                if (paymentInstruction != null) ...[
                  const SizedBox(width: PRFSpacingTokens.md),
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
          }

          if (requisition != null) {
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
                      const SizedBox(width: PRFSpacingTokens.md),
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
                if (loggedInMember.ulid == requisition.member?.ulid) ...[
                  const SizedBox(height: PRFSpacingTokens.sm),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context,
                      icon: Icons.undo,
                      label: l10n.recallRequisition,
                      onPressed: () => _showRecallRequisitionModal(context),
                      isOutlined: true,
                    ),
                  ),
                ],
              ],
            );
          }

          return Row(
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
                const SizedBox(width: PRFSpacingTokens.md),
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
    return [
      requisitionStatusBanner(
        context,
        colors: PRFApprovalStatus.approved.statusSet(context),
        icon: PRFApprovalStatus.approved.icon,
        message: l10n.requisitionApprovedBanner,
        margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      ),
      // Approved Actions
      BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
        builder: (context, requisitionState) {
          final requisition = _currentRequisitionFromState(requisitionState);
          if (requisition != null) {
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
                      const SizedBox(width: PRFSpacingTokens.md),
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
                  const SizedBox(height: PRFSpacingTokens.sm),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context,
                      icon: Icons.undo,
                      label: l10n.recallRequisition,
                      onPressed: () => _showRecallRequisitionModal(context),
                      isOutlined: true,
                    ),
                  ),
                ],
              ],
            );
          }

          return Row(
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
                const SizedBox(width: PRFSpacingTokens.md),
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
          );
        },
      ),
    ];
  }

  List<Widget> _buildRejectedActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      requisitionStatusBanner(
        context,
        colors: PRFApprovalStatus.rejected.statusSet(context),
        icon: PRFApprovalStatus.rejected.icon,
        message: l10n.requisitionRejectedBanner,
        margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
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
          const SizedBox(width: PRFSpacingTokens.md),
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
              label: l10n.addItem,
              onPressed: () => _showCreateRequisitionItemModal(context),
              isPrimary: true,
              isDisabled: !Misc.userCan(PRFPermissions.createRequisitionItem),
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.payment,
              label: l10n.requisitionDetailAddPayment,
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
    if (!isOutlined) {
      return PRFButton(
        onPressed: onPressed,
        title: label,
        variant: isPrimary
            ? PRFButtonVariant.primary
            : PRFButtonVariant.secondary,
        disabled: isDisabled,
      );
    }

    // Lower-emphasis action. PRFButton has no outlined variant yet, so this
    // stays a themed OutlinedButton with a full 48 dp target.
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(icon, size: PRFSizeTokens.iconMd),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        minimumSize: const Size(double.infinity, PRFSizeTokens.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          vertical: PRFSpacingTokens.md,
          horizontal: PRFSpacingTokens.lg,
        ),
        side: BorderSide(color: theme.colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        ),
      ),
    );
  }

  void _showRequestReviewModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.requestReview,
      child: RequestReviewViewHandset(requisitionUlid: widget.requisitionUlid),
    );
  }

  void _showMoreActionsBottomSheet(BuildContext context) {
    final l10n = context.l10n;
    PRFBottomSheet.show<void>(
      context,
      title: l10n.moreActions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),
            // Status-aware Action Items
            BlocBuilder<RequisitionDetailCubit, ResourceState<PRFRequisition>>(
              builder: (context, requisitionState) {
                final requisition = _currentRequisitionFromState(
                  requisitionState,
                );
                return Column(
                  children: requisition != null
                      ? _buildStatusAwareBottomSheetActions(
                          context,
                          requisition,
                        )
                      : _buildDefaultBottomSheetActions(context),
                );
              },
            ),
            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
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
            await _makePhoneCall(
              requisition.appointedApprover!.phoneNumber,
              requisition.appointedApprover!.fullName,
            );
          },
        ),

      if (loggedInMember.ulid == requisition.appointedApprover?.ulid &&
          requisition.member != null)
        _buildBottomSheetAction(
          context,
          icon: Icons.call,
          title: l10n.callRequisitor,
          subtitle: l10n.callDesc(requisition.member!.fullName),
          onTap: () async {
            Navigator.pop(context);
            await _makePhoneCall(
              requisition.member!.phoneNumber,
              requisition.member!.fullName,
            );
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
              title: l10n.recallRequisition,
              subtitle: l10n.recallRequisitionDesc,
              onTap: () {
                Navigator.pop(context);
                _showRecallRequisitionModal(context);
              },
            ),
        ];

      case PRFApprovalStatus.recalled:
      case PRFApprovalStatus.ghost:
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
                  isRejection: true,
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
        padding: const EdgeInsets.all(PRFSpacingTokens.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.onPrimaryContainer,
          size: PRFSizeTokens.iconMd,
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
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
      ),
    );
  }

  void _showCreateRequisitionItemModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.addItem,
      child: CreateRequisitionItemView(requisitionUlid: widget.requisitionUlid),
    );
  }

  void _showEditRequisitionItemModal(
    BuildContext context,
    PRFRequisitionItem item,
  ) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.edit,
      child: EditRequisitionItemView(requisitionItemUlid: item.ulid),
    );
  }

  void _showCreatePaymentInstructionModal(BuildContext context) {
    PRFBottomSheet.show<bool>(
      context,
      title: context.l10n.paymentInstructions,
      child: CreatePaymentInstructionView(
        requisitionUlid: widget.requisitionUlid,
      ),
    ).then((saved) {
      // The payment instruction lives in its own Hive box, so the requisition
      // that embeds it has to be refetched, but only after a successful save.
      if ((saved ?? false) && context.mounted) {
        _reloadRequisition();
      }
    });
  }

  void _showPaymentInstructionDetails(
    BuildContext context,
    PRFPaymentInstruction paymentInstruction,
  ) {
    final l10n = context.l10n;

    PRFBottomSheet.show<void>(
      context,
      title: l10n.paymentInstructions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),

            // Payment Method Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PRFSpacingTokens.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              ),
              child: Column(
                children: [
                  Icon(
                    _getPaymentMethodIcon(paymentInstruction.paymentMethod),
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: PRFSizeTokens.iconXl,
                  ),
                  const SizedBox(height: PRFSpacingTokens.sm),
                  Text(
                    _getPaymentMethodDisplayName(
                      paymentInstruction.paymentMethod,
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: PRFSpacingTokens.xl),

            // Recipient Details
            _buildPaymentDetailRow(
              context,
              l10n.recipientName,
              paymentInstruction.recipientName,
              Icons.person_outline,
            ),

            if (paymentInstruction.reference != null) ...[
              const SizedBox(height: PRFSpacingTokens.md),
              _buildPaymentDetailRow(
                context,
                l10n.reference,
                paymentInstruction.reference!,
                Icons.receipt_long_outlined,
              ),
            ],

            const SizedBox(height: PRFSpacingTokens.xl),

            // Method-specific details
            ..._buildPaymentMethodSpecificDetails(context, paymentInstruction),

            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
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
    final l10n = context.l10n;
    return switch (method) {
      PRFPaymentMethod.mpesa => l10n.requisitionDetailPaymentMpesa,
      PRFPaymentMethod.bankTransfer =>
        l10n.requisitionDetailPaymentBankTransfer,
      PRFPaymentMethod.paybill => l10n.requisitionDetailPaymentPaybill,
      PRFPaymentMethod.tillNumber => l10n.requisitionDetailPaymentTill,
    };
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
            const SizedBox(height: PRFSpacingTokens.md),
            _buildPaymentDetailRow(
              context,
              l10n.accountNumber,
              paymentInstruction.bankAccountNumber.toString(),
              Icons.numbers,
            ),
          ],
          if (paymentInstruction.bankAccountName != null) ...[
            const SizedBox(height: PRFSpacingTokens.md),
            _buildPaymentDetailRow(
              context,
              l10n.accountName,
              paymentInstruction.bankAccountName!,
              Icons.person,
            ),
          ],
          if (paymentInstruction.bankBranch != null) ...[
            const SizedBox(height: PRFSpacingTokens.md),
            _buildPaymentDetailRow(
              context,
              l10n.branch,
              paymentInstruction.bankBranch!,
              Icons.location_on,
            ),
          ],
          if (paymentInstruction.bankSwiftCode != null) ...[
            const SizedBox(height: PRFSpacingTokens.md),
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
            const SizedBox(height: PRFSpacingTokens.md),
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
      padding: const EdgeInsets.all(PRFSpacingTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: PRFSizeTokens.iconMd,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: PRFSpacingTokens.md),
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
            child: SelectableText(
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
    final status = requisition.approvalStatus.statusSet(context);
    final onStatus = status.onColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.sm,
      ),
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        color: status.main,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: onStatus.withValues(alpha: PRFOpacities.muted),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Icon(
                  requisition.approvalStatus.icon,
                  color: onStatus,
                  size: PRFSizeTokens.iconLg,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.requisitionDetails,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: onStatus,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.idLabel(
                        requisition.ulid.substring(0, 8).toUpperCase(),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onStatus,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              _buildStatusChip(context, requisition.approvalStatus, status),
            ],
          ),

          const SizedBox(height: PRFSpacingTokens.xl),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.desk,
                      requisition.responsibleDesk.name,
                      Icons.work_outline,
                      onStatus,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.totalAmount,
                      formatKes(requisition.totalAmount),
                      Icons.attach_money,
                      onStatus,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.created,
                      DateFormat.yMMMd().format(requisition.createdAt),
                      Icons.calendar_today,
                      onStatus,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      l10n.requisitionDate,
                      DateFormat.yMMMd().format(requisition.requisitionDate),
                      Icons.event,
                      onStatus,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (requisition.member != null) ...[
            const SizedBox(height: PRFSpacingTokens.lg),
            Container(
              padding: const EdgeInsets.all(PRFSpacingTokens.md),
              decoration: _onStatusBoxDecoration(onStatus),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: onStatus,
                    size: PRFSizeTokens.iconSm,
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Text(
                    l10n.requestedBy,
                    style: theme.textTheme.bodySmall?.copyWith(color: onStatus),
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      requisition.member!.fullName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onStatus,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (requisition.approvalStatus != PRFApprovalStatus.pending) ...[
            const SizedBox(height: PRFSpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(PRFSpacingTokens.md),
              decoration: _onStatusBoxDecoration(onStatus),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        requisition.approvalStatus.icon,
                        color: onStatus,
                        size: PRFSizeTokens.iconSm,
                      ),
                      const SizedBox(width: PRFSpacingTokens.sm),
                      Text(
                        requisition.approvalStatus.label(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onStatus,
                        ),
                      ),
                      if (requisition.approvedBy != null) ...[
                        const SizedBox(width: PRFSpacingTokens.sm),
                        Expanded(
                          child: Text(
                            '${requisition.approvedBy!.firstName} '
                            '${requisition.approvedBy!.lastName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onStatus,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (requisition.approvalNotes != null) ...[
                    const SizedBox(height: PRFSpacingTokens.sm),
                    Text(
                      l10n.requisitionDetailNotesValue(
                        requisition.approvalNotes!,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onStatus,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: PRFSpacingTokens.xs),
                  Text(
                    l10n.requisitionDetailDateValue(
                      DateFormat.yMMMd().add_Hm().format(
                        requisition.approvedAt ?? requisition.createdAt,
                      ),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(color: onStatus),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).entrance(context, slide: const Offset(0, -0.2));
  }

  BoxDecoration _onStatusBoxDecoration(Color onStatus) => BoxDecoration(
    color: onStatus.withValues(alpha: PRFOpacities.subtle),
    borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
    border: Border.all(color: onStatus.withValues(alpha: PRFOpacities.muted)),
  );

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color onStatus,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.md),
      decoration: _onStatusBoxDecoration(onStatus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: onStatus, size: PRFSizeTokens.iconSm),
              const SizedBox(width: PRFSpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: onStatus),
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onStatus,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Status label on the coloured details card. Drawn in the status set's
  /// `onColor` (outlined) so it always contrasts with the card fill.
  Widget _buildStatusChip(
    BuildContext context,
    PRFApprovalStatus status,
    StatusColorSet colors,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.md,
        vertical: PRFSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(color: colors.onColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: PRFSizeTokens.iconSm, color: colors.onColor),
          const SizedBox(width: PRFSpacingTokens.xs),
          Text(
            status.label(context.l10n),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onColor,
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
    String notes, {
    bool isRejection = false,
  }) {
    final l10n = context.l10n;
    PRFConfirmationDialog.show(
      context,
      title: title,
      message: notes,
      confirmLabel: l10n.okButtonText,
      cancelLabel: l10n.cancel,
      isDestructive: isRejection,
    );
  }

  void _showApprovalModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.requisitionActionReviewTitle,
      child: ApproveRequisitionViewHandset(
        requisitionUlid: widget.requisitionUlid,
      ),
    );
  }

  void _showEditRequisitionModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.editRequisition,
      child: EditRequisitionViewHandset(
        requisitionUlid: widget.requisitionUlid,
      ),
    );
  }

  void _showRecallRequisitionModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.recallRequisition,
      child: RecallRequisitionView(requisitionUlid: widget.requisitionUlid),
    );
  }

  /// Calls [phoneNumber], telling the user when there is no number saved or
  /// the call can't be started.
  Future<void> _makePhoneCall(String? phoneNumber, String name) async {
    final l10n = context.l10n;
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      PRFSnackbar.info(context, l10n.requisitionDetailNoPhoneNumber(name));
      return;
    }

    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

    final success = await Misc.openUrl(phoneUri);
    if (!success && mounted) {
      PRFSnackbar.error(context, l10n.requisitionDetailCallFailed);
    }
  }
}
