// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/cubit/upload_media_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/shared_views/expenses/actions/add_expense/_handset.dart';
import 'package:leadership/shared_views/expenses/actions/add_refund/_handset.dart';
import 'package:leadership/shared_views/expenses/actions/add_token/_handset.dart';
import 'package:leadership/shared_views/expenses/actions/edit_expense/_handset.dart';
import 'package:leadership/shared_views/expenses/actions/send_financial_report/_handset.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared_views/expenses/widgets/reciept_preview.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:prf_design/prf_design.dart';

class ExpensesViewHandset extends StatefulWidget {
  const ExpensesViewHandset({
    required this.showFinancialReport,
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;
  final bool showFinancialReport;

  @override
  State<ExpensesViewHandset> createState() => _ExpensesViewHandsetState();
}

class _ExpensesViewHandsetState extends State<ExpensesViewHandset>
    with TimezoneMixin {
  bool _showBreakdown = true;
  String? _deletingReceiptUuid;
  String get accountingEventUlid => widget.accountingEventUlid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
    context.read<AllocationEntryResourceCubit>().refreshForAccountingEvent(
      accountingEventUlid: accountingEventUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<
          AllocationEntryResourceCubit,
          ResourceState<PRFAllocationEntry>
        >(
          listener: (context, state) {
            state.maybeWhen(
              mutated: (items, operation, item) {
                if (operation == ResourceOperation.create) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entry added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (operation == ResourceOperation.update) {
                  if (_deletingReceiptUuid != null && item == null) {
                    setState(() {
                      _deletingReceiptUuid = null;
                    });
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    return;
                  }

                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (operation == ResourceOperation.delete) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              error: (message, items) {
                if (_deletingReceiptUuid != null) {
                  setState(() {
                    _deletingReceiptUuid = null;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
              orElse: () {},
            );
          },
        ),
        BlocListener<UploadMediaCubit, UploadMediaState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              loaded: () {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receipt uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to upload receipt: $message'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            );
          },
        ),
      ],
      child:
          BlocBuilder<
            AllocationEntryResourceCubit,
            ResourceState<PRFAllocationEntry>
          >(
            builder: (context, state) {
              final entries = state.maybeWhen(
                listLoaded: (items, page, hasMore) => items,
                mutating: (items, operation) => items,
                mutated: (items, operation, item) => items,
                error: (message, items) => items,
                orElse: () => <PRFAllocationEntry>[],
              );

              return state.maybeWhen(
                initial: () => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                  ),
                  child: PRFLinearProgressIndicator(),
                ),
                listLoading: () => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                  ),
                  child: PRFLinearProgressIndicator(),
                ),
                error: (message, items) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                  ),
                  child: PRFEmptyView(
                    label: 'Error',
                    description: message,
                    icon: Icons.error_outline,
                    actionLabel: 'Retry',
                    onActionPressed: _loadData,
                  ),
                ),
                orElse: () {
                  if (entries.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.lg,
                      ),
                      child: PRFEmptyView(
                        label: 'No Expenses Yet',
                        description: 'Start by adding your first expense',
                        icon: Icons.receipt_long_outlined,
                      ),
                    );
                  }

                  return _buildLoadedView(context, l10n, entries);
                },
              );
            },
          ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    AppLocalizations l10n,
    List<PRFAllocationEntry> entries,
  ) {
    final accountingEvent = entries.isNotEmpty
        ? entries.first.accountingEvent
        : null;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(
            context,
            l10n,
            accountingEvent!,
          ),
        ),
        // Financial Overview Header
        SliverToBoxAdapter(
          child:
              _buildFinancialOverview(
                    context,
                    l10n,
                    accountingEvent,
                  )
                  .animate()
                  .slideY(begin: -0.3)
                  .fadeIn(duration: PRFMotionTokens.enterShort),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child:
              _buildQuickActions(
                    context,
                    l10n,
                    accountingEvent,
                  )
                  .animate(delay: PRFMotionTokens.stagger2)
                  .slideY(begin: 0.3)
                  .fadeIn(),
        ),

        // Refund Information (show when balance > 0)
        SliverToBoxAdapter(
          child: _buildRefundInformation(
            context,
            l10n,
            accountingEvent,
          ),
        ),

        // Breakdown Toggle
        SliverToBoxAdapter(
          child:
              _buildBreakdownToggle(
                    context,
                    entries,
                  )
                  .animate(delay: PRFMotionTokens.stagger4)
                  .slideX(begin: -0.2)
                  .fadeIn(),
        ),

        // Expenses List (if breakdown is shown)
        if (_showBreakdown && entries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildExpenseCard(context, entries[index])
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: (index * 50).ms,
                      )
                      .slideX(begin: 0.2, end: 0);
                },
                childCount: entries.length,
              ),
            ),
          ),

        // Empty state when breakdown is shown but no entries
        if (_showBreakdown && entries.isEmpty)
          SliverToBoxAdapter(
            child: const PRFEmptyView(
              label: 'No Expenses Yet',
              description: 'Start by adding your first expense',
              icon: Icons.receipt_long_outlined,
            ).animate().fadeIn(duration: PRFMotionTokens.enterShort),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildFinancialOverview(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    final spentPercentage = accountingEvent.credits > 0
        ? (accountingEvent.debits / accountingEvent.credits)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
      child: Column(
        children: [
          // Main Balance Card
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.currentBalance,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                          ),
                          child: Text(
                            '${(spentPercentage * 100).toStringAsFixed(1)}% spent',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_KE',
                        symbol: 'KES ',
                      ).format(accountingEvent.balance),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.lg),
                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: spentPercentage.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: PRFMotionTokens.enterShort)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: PRFSpacingTokens.lg),

          // Financial Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.amountReceived,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(accountingEvent.credits),
                  Icons.trending_up,
                  theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.xs),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.amountSpent,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(accountingEvent.debits),
                  Icons.trending_down,
                  theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.xs),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.amountToRefund,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(
                    accountingEvent.latestRefund?.deficitAmount ??
                        accountingEvent.amountToRefund,
                  ),
                  Icons.refresh,
                  theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
          padding: const EdgeInsets.all(PRFSpacingTokens.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              Text(
                '$title\n',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: PRFSpacingTokens.xs),
              Text(
                '$value\n',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: PRFMotionTokens.stagger2, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddTokenModal(context, accountingEvent),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.addToken),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                  vertical: PRFSpacingTokens.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
              ),
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAddExpenseModal(context),
              icon: const Icon(Icons.receipt_long),
              label: Text(l10n.addExpense),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: PRFSpacingTokens.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownToggle(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        elevation: 1,
        child: InkWell(
          onTap: () => setState(() => _showBreakdown = !_showBreakdown),
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          child: Padding(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _showBreakdown
                            ? 'Tap to hide details'
                            : 'Tap to view ${entries.length} transactions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: PRFMotionTokens.standard,
                  turns: _showBreakdown ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, PRFAllocationEntry entry) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isCredit = entry.entryType == PRFEntryType.credit;
    final hasReceipts = entry.receipts.isNotEmpty;
    final missingReceipt = !isCredit && !hasReceipts;

    return Container(
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Category and Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : theme.colorScheme.errorContainer.withValues(
                              alpha: 0.3,
                            ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      isCredit ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isCredit
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.expenseCategory?.name ?? l10n.unknownCategory,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (entry.member?.fullName != null) ...[
                          const SizedBox(height: PRFSpacingTokens.xs),
                          Text(
                            entry.member!.fullName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(
                            symbol: 'KES ',
                            decimalDigits: 0,
                          ).format(entry.amount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCredit
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          DateFormat('MMM dd, yyyy').format(entry.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                  // Delete Button for Debit Entries Only
                  if (!isCredit) ...[
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showDeleteConfirmation(context, entry),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        child: Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Edit Button
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showExpenseDetails(context, entry),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      child: Container(
                        padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.md,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Description Row (if exists)
              if (entry.narration.isNotEmpty) ...[
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  entry.narration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: PRFSpacingTokens.md),

              if (hasReceipts) ...[
                _buildReceiptAttachments(context, entry.ulid, entry.receipts),
              ] else if (missingReceipt) ...[
                _buildMissingReceiptAction(context, entry),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptAttachments(
    BuildContext context,
    String allocationEntryUlid,
    List<PRFMedia> receipts,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Text(
                '${receipts.length} '
                'Attachment${receipts.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                final isPdf = receipt.temporaryURL.toLowerCase().contains(
                  '.pdf',
                );

                final isDeleting = _deletingReceiptUuid == receipt.uuid;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: isPdf
                            ? () => _openPdfDocument(
                                context,
                                receipt.temporaryURL,
                              )
                            : () => _showReceiptPreview(
                                context,
                                receipts,
                                index,
                              ),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isPdf
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary
                                        .withValues(
                                          alpha: 0.2,
                                        ),
                                    borderRadius: BorderRadius.circular(
                                      14,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.file_present,
                                        size: 28,
                                        color: theme.colorScheme.tertiary,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PDF',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        receipt.temporaryURL,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return ColoredBox(
                                                color: theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(
                                                        alpha: 0.4,
                                                      ),
                                                  size: 24,
                                                ),
                                              );
                                            },
                                        loadingBuilder:
                                            (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return ColoredBox(
                                                color: theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                      // Overlay for better tap indication
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      // Delete button
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _showDeleteReceiptConfirmation(
                            context,
                            allocationEntryUlid,
                            receipt,
                          ),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                      // Loading overlay during deletion
                      if (isDeleting)
                        Positioned.fill(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.lg,
                              ),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteReceiptConfirmation(
    BuildContext context,
    String allocationEntryUlid,
    PRFMedia receipt,
  ) async {
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: 'Delete Receipt',
      message:
          'Are you sure you want to delete this receipt? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      setState(() {
        _deletingReceiptUuid = receipt.uuid;
      });
      await context.read<AllocationEntryResourceCubit>().deleteReceipt(
        allocationEntryUlid: allocationEntryUlid,
        mediaUuid: receipt.uuid,
      );
    }
  }

  Widget _buildMissingReceiptAction(
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PRFSpacingTokens.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            ),
            child: Icon(
              Icons.receipt_outlined,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Missing',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Attach receipt or documentation',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<UploadMediaCubit, UploadMediaState>(
            builder: (context, uploadState) {
              return uploadState.maybeWhen(
                orElse: () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Attach Image Button
                    Material(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      child: InkWell(
                        onTap: () async {
                          try {
                            await context
                                .read<SelectMediaCubit>()
                                .selectMediaWithSource(
                                  context: context,
                                  modelUlid: entry.ulid,
                                  model: PRFMediaModel.allocationEntryReceipts,
                                  mediaType: MediaType.image,
                                );

                            // ignore: use_build_context_synchronously
                            final dtos = context
                                .read<SelectMediaCubit>()
                                .state
                                .maybeWhen(
                                  orElse: () => <PRFMediaDTO>[],
                                  loaded: (dtos) => dtos,
                                );

                            // Get the selected media from the cubit state
                            // ignore: use_build_context_synchronously
                            context.read<SelectMediaCubit>().state.maybeWhen(
                              orElse: () {},
                              loaded: (_) {
                                if (context.mounted) {
                                  context.read<UploadMediaCubit>().uploadMedia(
                                    imageDTOs: dtos,
                                  );
                                }
                              },
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to select image: $e'),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 16,
                                color: theme.colorScheme.onError,
                              ),
                              const SizedBox(width: PRFSpacingTokens.xs),
                              Text(
                                'Image',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    // Attach PDF Button
                    Material(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                      child: InkWell(
                        onTap: () async {
                          try {
                            await context
                                .read<SelectMediaCubit>()
                                .selectDocuments(
                                  modelUlid: entry.ulid,
                                  model: PRFMediaModel.allocationEntryReceipts,
                                );

                            // ignore: use_build_context_synchronously
                            final dtos = context
                                .read<SelectMediaCubit>()
                                .state
                                .maybeWhen(
                                  orElse: () => <PRFMediaDTO>[],
                                  loaded: (dtos) => dtos,
                                );

                            // Get the selected documents from the cubit state
                            // ignore: use_build_context_synchronously
                            context.read<SelectMediaCubit>().state.maybeWhen(
                              orElse: () {},
                              loaded: (_) {
                                if (context.mounted) {
                                  context.read<UploadMediaCubit>().uploadMedia(
                                    imageDTOs: dtos,
                                  );
                                }
                              },
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to select PDF: $e'),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.file_present_outlined,
                                size: 16,
                                color: theme.colorScheme.onTertiary,
                              ),
                              const SizedBox(width: PRFSpacingTokens.xs),
                              Text(
                                'PDF',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onTertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => SizedBox(
                  width: 16,
                  height: 16,
                  child: PRFCircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openPdfDocument(BuildContext context, String pdfUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (context) => PDFViewerPage(
          pdfUrl: pdfUrl,
          title: 'Receipt PDF',
        ),
      ),
    );
  }

  void _showReceiptPreview(
    BuildContext context,
    List<PRFMedia> receipts,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (context) => ReceiptPreviewPage(
          receipts: receipts,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    context.read<SelectMediaCubit>().clearMedia();
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.addExpense,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: AddExpenseViewHandset(accountingEventUlid: accountingEventUlid),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, PRFAllocationEntry entry) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.edit,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: EditExpenseViewHandset(
          allocationEntry: entry,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return PRFConfirmationDialog(
          title: 'Delete Expense',
          isDestructive: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this expense?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.expenseCategory?.name ?? 'Unknown Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.sm),
                    Text(
                      NumberFormat.currency(
                        symbol: 'KES ',
                        decimalDigits: 0,
                      ).format(entry.amount),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    if (entry.narration.isNotEmpty) ...[
                      const SizedBox(height: PRFSpacingTokens.sm),
                      Text(
                        entry.narration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          customActions: [
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
              AllocationEntryResourceCubit,
              ResourceState<PRFAllocationEntry>
            >(
              listener: (context, state) {
                state.maybeWhen(
                  mutated: (items, operation, item) {
                    if (operation == ResourceOperation.delete) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  error: (message, items) {
                    Navigator.of(dialogContext).pop();
                  },
                  orElse: () {},
                );
              },
              builder: (context, state) {
                final isDeleting = state.maybeWhen(
                  mutating: (items, operation) =>
                      operation == ResourceOperation.delete,
                  orElse: () => false,
                );

                if (isDeleting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: PRFSpacingTokens.lg,
                      vertical: PRFSpacingTokens.sm,
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return _buildDeleteButton(theme, context, entry);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteButton(
    ThemeData theme,
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<AllocationEntryResourceCubit>().deleteAllocationEntry(
          allocationEntryUlid: entry.ulid,
        );
      },
      icon: const Icon(Icons.delete_outline, size: 18),
      label: const Text('Delete'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.lg,
          vertical: PRFSpacingTokens.sm,
        ),
      ),
    );
  }

  void _showAddTokenModal(
    BuildContext context,
    PRFAccountingEvent accountingEvent,
  ) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.addToken,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: AddTokenViewHandset(
          accountingEventUlid: accountingEvent.ulid,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<AllocationEntryResourceCubit>().refreshForAccountingEvent(
          accountingEventUlid: accountingEvent.ulid,
        );
      }
    });
  }

  void _showAddRefundModal(
    BuildContext context,
    PRFAccountingEvent accountingEvent,
  ) {
    PRFBottomSheet.show<void>(
      context,
      title: 'Add Refund',
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: AddRefundViewHandset(
          accountingEventUlid: accountingEvent.ulid,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<AllocationEntryResourceCubit>().refreshForAccountingEvent(
          accountingEventUlid: accountingEvent.ulid,
        );
      }
    });
  }

  Widget _buildRefundInformation(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
      child:
          Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.tertiary.withValues(alpha: 0.1),
                      theme.colorScheme.tertiary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.sm,
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.tertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: PRFSpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.refundInformation,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                              Text(
                                l10n.refundDesc,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                          ),
                          child: Text(
                            NumberFormat.currency(
                              locale: 'en_KE',
                              symbol: 'KES ',
                            ).format(
                              accountingEvent.latestRefund?.deficitAmount ??
                                  accountingEvent.amountToRefund,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PRFSpacingTokens.lg),
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Text(
                                l10n.refundDetails,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: PRFSpacingTokens.md),
                          _buildRefundDetailRow(
                            context,
                            l10n.paybillNumber,
                            '4088159',
                            Icons.numbers,
                          ),
                          const SizedBox(height: PRFSpacingTokens.sm),
                          _buildRefundDetailRow(
                            context,
                            l10n.accountNumber,
                            'REFUND',
                            Icons.account_balance,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: PRFSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              l10n.refundText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddRefundModal(context, accountingEvent),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Add Refund'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: theme.colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.md,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    if (accountingEvent.refunds.isNotEmpty)
                      _buildRefundEntriesList(
                        context,
                        theme,
                        accountingEvent.refunds,
                      ),
                    if (accountingEvent.refunds.isNotEmpty)
                      const SizedBox(height: PRFSpacingTokens.md),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: PRFMotionTokens.enterShort)
              .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildRefundEntriesList(
    BuildContext context,
    ThemeData theme,
    List<PRFRefund> refunds,
  ) {
    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Text(
                'Refund Entries',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Text(
                  '${refunds.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: refunds.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final refund = refunds.reversed.elementAt(index);
              return _buildRefundEntryItem(context, theme, refund, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRefundEntryItem(
    BuildContext context,
    ThemeData theme,
    PRFRefund refund,
    int entryNumber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '#$entryNumber',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_KE',
                      symbol: 'KES ',
                    ).format(refund.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        _buildRefundDetailValue(
          context,
          theme,
          'Deficit Amount',
          NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(
            refund.deficitAmount,
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        _buildRefundDetailValue(
          context,
          theme,
          'Confirmation',
          refund.confirmationMessage,
          isCopyable: true,
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        _buildRefundDetailValue(
          context,
          theme,
          'Date',
          Misc.formatDateTime(refund.createdAt, timezone),
        ),
      ],
    );
  }

  Widget _buildRefundDetailValue(
    BuildContext context,
    ThemeData theme,
    String label,
    String value, {
    bool isCopyable = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xs),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isCopyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            padding: const EdgeInsets.all(PRFSpacingTokens.xs),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildRefundDetailRow(
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
        const SizedBox(width: PRFSpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied "$value" to clipboard'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.xs),
                Icon(
                  Icons.copy,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expenseTracking,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  l10n.financialOverview,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<
            AllocationEntryResourceCubit,
            ResourceState<PRFAllocationEntry>
          >(
            builder: (context, state) {
              final isRefreshing = state.maybeWhen(
                listLoading: () => true,
                orElse: () => false,
              );

              return IconButton.filled(
                onPressed: () => context
                    .read<AllocationEntryResourceCubit>()
                    .refreshForAccountingEvent(
                      accountingEventUlid: accountingEvent.ulid,
                    ),
                icon: isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              );
            },
          ),
          if (widget.showFinancialReport)
            IconButton.filled(
              onPressed: () => _showSendReportModal(context),
              icon: const Icon(
                Icons.email,
                color: Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  void _showSendReportModal(
    BuildContext context,
  ) {
    PRFBottomSheet.show<void>(
      context,
      title: 'Send Financial Report',
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: SendFinancialReportViewHandset(
          accountingEventUlid: accountingEventUlid,
        ),
      ),
    );
  }
}
