import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/expenses/actions/add_expense/_handset.dart';
import 'package:leadership/features/home/landing/expenses/actions/add_token/_handset.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocations_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AccountingEventExpensesViewHandset extends StatefulWidget {
  const AccountingEventExpensesViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  State<AccountingEventExpensesViewHandset> createState() =>
      _AccountingEventExpensesViewHandsetState();
}

class _AccountingEventExpensesViewHandsetState
    extends State<AccountingEventExpensesViewHandset> {
  bool _showBreakdown = false;
  String get accountingEventUlid => widget.accountingEventUlid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GetAllocationEntriesCubit>().getAllocationEntries(
      accountingEventUlid: accountingEventUlid,
    );
    context.read<GetMembersCubit>().getMembers();
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
    context.read<GetAllocationsCubit>().getAllocations(
      accountingEventUlid: accountingEventUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddAllocationEntryCubit, AddAllocationEntryState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              success: () {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Close any open modal
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            );
          },
        ),
      ],
      child: BlocBuilder<GetAllocationEntriesCubit, GetAllocationEntriesState>(
        builder: (context, state) {
          return state.when(
            initial: () => const PRFLinearProgressIndicator(),
            loading: () => const PRFLinearProgressIndicator(),
            loaded: (entries) => _buildLoadedView(context, entries),
            empty: () => const PRFEmptyView(
              label: 'No Expenses Yet',
              description: 'Start by adding your first expense or token',
              icon: Icons.receipt_long_outlined,
            ),
            error: (message) => PRFEmptyView(
              label: 'Error',
              description: message,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    // Calculate totals
    final totalCredits = entries
        .where((e) => e.entryType == PRFEntryType.credit)
        .fold<double>(0, (sum, entry) => sum + (entry.amount / 100));

    final totalDebits = entries
        .where((e) => e.entryType == PRFEntryType.debit)
        .fold<double>(0, (sum, entry) => sum + (entry.amount / 100));

    final balance = totalCredits - totalDebits;

    return CustomScrollView(
      slivers: [
        // Financial Overview Header
        SliverToBoxAdapter(
          child: _buildFinancialOverview(
            context,
            totalCredits,
            totalDebits,
            balance,
            entries.length,
          ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: _buildQuickActions(
            context,
            entries,
          ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
        ),

        // Breakdown Toggle
        SliverToBoxAdapter(
          child: _buildBreakdownToggle(
            context,
            entries,
          ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),
        ),

        // Expenses List (if breakdown is shown)
        if (_showBreakdown && entries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = entries[index];
                  return _buildExpenseCard(context, entry)
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
              description: 'Start by adding your first expense or token',
              icon: Icons.receipt_long_outlined,
            ).animate().fadeIn(duration: 600.ms),
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
    double totalCredits,
    double totalDebits,
    double balance,
    int entryCount,
  ) {
    final theme = Theme.of(context);
    final spentPercentage = totalCredits > 0 ? (totalDebits / totalCredits) : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
                Icons.account_balance_wallet,
                color: theme.colorScheme.onPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$entryCount entries total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  context,
                  'Credits',
                  totalCredits,
                  Icons.add_circle,
                  theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                  theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceCard(
                  context,
                  'Debits',
                  totalDebits,
                  Icons.remove_circle,
                  theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                  theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        symbol: 'KES ',
                        decimalDigits: 0,
                      ).format(balance),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (totalCredits > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        '${(spentPercentage * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              symbol: 'KES ',
              decimalDigits: 0,
            ).format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context: context,
              label: 'Add Expense',
              icon: Icons.receipt_long,
              onTap: () => _showAddExpenseModal(context),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context: context,
              label: 'Add Token',
              icon: Icons.toll,
              onTap: () => _showAddTokenModal(context, entries),
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownToggle(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () => setState(() => _showBreakdown = !_showBreakdown),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
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
                  duration: const Duration(milliseconds: 200),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showExpenseDetails(context, entry),
        borderRadius: BorderRadius.circular(12),
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
                      color: isCredit
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.add : Icons.remove,
                      color: isCredit
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.expenseCategory?.name ?? l10n.unknownCategory,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.member?.fullName ?? l10n.unknownMember,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
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
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(entry.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.narration.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.narration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        _buildAddExpenseModalPage(context),
      ],
    );
  }

  WoltModalSheetPage _buildAddExpenseModalPage(BuildContext context) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: Text(context.l10n.addExpense),
      isTopBarLayerAlwaysVisible: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: AddExpenseViewHandset(
          accountingEventUlid: accountingEventUlid,
        ),
      ),
    );
  }

  void _showAddTokenModal(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            hasTopBarLayer: true,
            topBarTitle: const Text('Add Token'),
            isTopBarLayerAlwaysVisible: true,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: AddTokenViewHandset(
                accountingEventUlid: accountingEventUlid,
              ),
            ),
          ),
        ];
      },
    ).then((_) {
      if (context.mounted) {
        _loadData();
      }
    });
  }

  void _showExpenseDetails(BuildContext context, PRFAllocationEntry entry) {
    // Implementation would go here for showing detailed view
    // This is a placeholder for the expense details modal
  }
}
