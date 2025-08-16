import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_items_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_payment_instruction/create_payment_instruction.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition_item/create_requisition_item.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/shared_widgets/progress/circular_progress_indicator.dart';
import 'package:leadership/utils/_index.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class RequisitionPageHandset extends StatefulWidget {
  const RequisitionPageHandset({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  State<RequisitionPageHandset> createState() => _RequisitionPageHandsetState();
}

class _RequisitionPageHandsetState extends State<RequisitionPageHandset> {
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

    return Scaffold(
      appBar: PRFAppBar(
        title: l10n.requisitionDetails,
        onBack: () => context.router.popUntilRouteWithPath(
          PRFLeadershipRouter.deskActivityDetailsRoute,
        ),
      ),
      body: BlocBuilder<GetRequisitionItemsCubit, GetRequisitionItemsState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            loaded: (requisitionItems) => _buildRequisitionItemsList(
              context,
              l10n,
              requisitionItems,
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
                    'Error: $message',
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<GetRequisitionCubit, GetRequisitionState>(
            builder: (context, requisitionState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  requisitionState.maybeWhen(
                    loaded: (requisition) => FloatingActionButton.extended(
                      heroTag: 'payment_instruction',
                      icon: Icon(
                        requisition.paymentInstruction != null
                            ? Icons.visibility
                            : Icons.payment,
                      ),
                      onPressed: () => requisition.paymentInstruction != null
                          ? _showPaymentInstructionDetails(
                              context,
                              requisition.paymentInstruction!,
                            )
                          : _showCreatePaymentInstructionModal(context),
                      label: Text(
                        requisition.paymentInstruction != null
                            ? 'View Payment'
                            : 'Payment',
                      ),
                      backgroundColor: requisition.paymentInstruction != null
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.secondary,
                      foregroundColor: requisition.paymentInstruction != null
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                    orElse: () => FloatingActionButton.extended(
                      heroTag: 'payment_instruction',
                      icon: const Icon(Icons.payment),
                      onPressed: () =>
                          _showCreatePaymentInstructionModal(context),
                      label: const Text('Payment'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    heroTag: 'requisition_item',
                    icon: const Icon(Icons.add),
                    onPressed: () => _showCreateRequisitionItemModal(context),
                    label: Text(l10n.create),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Requisition Items',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No items have been added to this requisition yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRequisitionItemModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequisitionItemsList(
    BuildContext context,
    AppLocalizations l10n,
    List<PRFRequisitionItem> items,
  ) {
    final theme = Theme.of(context);
    final totalAmount = items.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

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

            // Summary header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Items Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Items',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              '${items.length}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                symbol: 'KES ',
                                decimalDigits: 0,
                              ).format(totalAmount),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),
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
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),

            // Bottom spacing for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
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
  ) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showItemDetails(context, item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.expenseCategory != null)
                              Text(
                                item.expenseCategory!.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: 'KES ',
                          decimalDigits: 0,
                        ).format(item.totalPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetailChip(
                        context,
                        'Qty: ${item.quantity}',
                        Icons.numbers,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        context,
                        'Unit: ${NumberFormat.currency(
                          symbol: 'KES ',
                          decimalDigits: 0,
                        ).format(item.unitPrice)}',
                        Icons.attach_money,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.3)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildDetailChip(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, PRFRequisitionItem item) {
    final theme = Theme.of(context);

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
                      'Category',
                      item.expenseCategory!.name,
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildDetailRow(
                    context,
                    'Unit Price',
                    NumberFormat.currency(
                      symbol: 'KES ',
                      decimalDigits: 0,
                    ).format(item.unitPrice),
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Quantity',
                    '${item.quantity}',
                    Icons.numbers,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Total Price',
                    NumberFormat.currency(
                      symbol: 'KES ',
                      decimalDigits: 0,
                    ).format(item.totalPrice),
                    Icons.calculate,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Created',
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
                      'Payment Instructions',
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
                    'Recipient Name',
                    paymentInstruction.recipientName,
                    Icons.person_outline,
                  ),

                  if (paymentInstruction.reference != null) ...[
                    const SizedBox(height: 12),
                    _buildPaymentDetailRow(
                      context,
                      'Reference',
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
    switch (paymentInstruction.paymentMethod) {
      case PRFPaymentMethod.mpesa:
        return [
          if (paymentInstruction.mpesaPhoneNumber != null)
            _buildPaymentDetailRow(
              context,
              'Phone Number',
              '+${paymentInstruction.mpesaPhoneNumber}',
              Icons.phone,
            ),
        ];

      case PRFPaymentMethod.bankTransfer:
        return [
          if (paymentInstruction.bankName != null)
            _buildPaymentDetailRow(
              context,
              'Bank Name',
              paymentInstruction.bankName!,
              Icons.account_balance,
            ),
          if (paymentInstruction.bankAccountNumber != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'Account Number',
              paymentInstruction.bankAccountNumber.toString(),
              Icons.numbers,
            ),
          ],
          if (paymentInstruction.bankAccountName != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'Account Name',
              paymentInstruction.bankAccountName!,
              Icons.person,
            ),
          ],
          if (paymentInstruction.bankBranch != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'Branch',
              paymentInstruction.bankBranch!,
              Icons.location_on,
            ),
          ],
          if (paymentInstruction.bankSwiftCode != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'SWIFT Code',
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
              'Paybill Number',
              paymentInstruction.paybillNumber.toString(),
              Icons.receipt,
            ),
          if (paymentInstruction.paybillAccountNumber != null) ...[
            const SizedBox(height: 12),
            _buildPaymentDetailRow(
              context,
              'Account Number',
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
              'Till Number',
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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(requisition.approvalStatus, theme),
            _getStatusColor(
              requisition.approvalStatus,
              theme,
            ).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(
              requisition.approvalStatus,
              theme,
            ).withValues(alpha: 0.3),
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
                  _getStatusIcon(requisition.approvalStatus),
                  color: _getStatusColor(requisition.approvalStatus, theme),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requisition Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${requisition.ulid.substring(0, 8).toUpperCase()}',
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
                      'Desk',
                      requisition.responsibleDesk.name,
                      Icons.work_outline,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Total Amount',
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
                      'Created',
                      DateFormat.yMMMd().format(requisition.createdAt),
                      Icons.calendar_today,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Requisition Date',
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
                    'Requested by: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${requisition.member!.firstName} '
                      '${requisition.member!.lastName}',
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
                        requisition.approvalStatus == PRFApprovalStatus.approved
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: theme.colorScheme.surface,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        requisition.approvalStatus == PRFApprovalStatus.approved
                            ? 'Approved by: '
                            : 'Rejected by: ',
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
                          ),
                        ),
                    ],
                  ),
                  if (requisition.approvalNotes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Notes: ${requisition.approvalNotes}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat.yMMMd().add_Hm().format(
                      // ignore: lines_longer_than_80_chars
                      requisition.approvedAt ?? requisition.rejectedAt ?? DateTime.now(),
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
            _getStatusIcon(status),
            size: 14,
            color: _getStatusColor(status, theme),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusDisplayName(status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(status, theme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PRFApprovalStatus status, ThemeData theme) {
    switch (status) {
      case PRFApprovalStatus.pending:
        return theme.colorScheme.secondary;
      case PRFApprovalStatus.approved:
        return Colors.green;
      case PRFApprovalStatus.rejected:
        return theme.colorScheme.error;
    }
  }

  IconData _getStatusIcon(PRFApprovalStatus status) {
    switch (status) {
      case PRFApprovalStatus.pending:
        return Icons.hourglass_empty;
      case PRFApprovalStatus.approved:
        return Icons.check_circle;
      case PRFApprovalStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusDisplayName(PRFApprovalStatus status) {
    switch (status) {
      case PRFApprovalStatus.pending:
        return 'Pending';
      case PRFApprovalStatus.approved:
        return 'Approved';
      case PRFApprovalStatus.rejected:
        return 'Rejected';
    }
  }
}
