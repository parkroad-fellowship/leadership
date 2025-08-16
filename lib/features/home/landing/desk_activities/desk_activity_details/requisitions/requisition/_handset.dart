import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/get_requisition_items_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition_item/create_requisition_item.dart';
import 'package:leadership/l10n/l10n.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<GetRequisitionItemsCubit, GetRequisitionItemsState>(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        onPressed: () =>
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
                context.read<GetRequisitionItemsCubit>().getRequisitionItems(
                  requisitionUlid: widget.requisitionUlid,
                );
              }
            }),
        label: Text(l10n.create),
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
            onPressed: () =>
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
                  if (context.mounted) {
                    context
                        .read<GetRequisitionItemsCubit>()
                        .getRequisitionItems(
                          requisitionUlid: widget.requisitionUlid,
                        );
                  }
                }),
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

    return CustomScrollView(
      slivers: [
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
                      'Requisition Summary',
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
                return _buildRequisitionItemCard(context, theme, item, index);
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
}
