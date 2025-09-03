import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/cubit/upload_media_cubit.dart';
import 'package:leadership/features/home/landing/expenses/actions/add_expense/_handset.dart';
import 'package:leadership/features/home/landing/expenses/actions/edit_expense/_handset.dart';
import 'package:leadership/features/home/landing/expenses/actions/send_financial_report/_handset.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/delete_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/edit_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
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

class _ReceiptPreviewPage extends StatefulWidget {
  const _ReceiptPreviewPage({
    required this.receipts,
    required this.initialIndex,
  });

  final List<PRFMedia> receipts;
  final int initialIndex;

  @override
  State<_ReceiptPreviewPage> createState() => _ReceiptPreviewPageState();
}

class _ReceiptPreviewPageState extends State<_ReceiptPreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Receipt ${_currentIndex + 1} of ${widget.receipts.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.receipts.length,
        itemBuilder: (context, index) {
          final receipt = widget.receipts[index];
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                receipt.temporaryURL,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountingEventExpensesViewHandsetState
    extends State<AccountingEventExpensesViewHandset> {
  bool _showBreakdown = true;
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
    context.read<GetMembersCubit>().getMembers(
      group: PRFLeadershipGroup.executiveCommittee,
    );
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
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
              loaded: () {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
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
        BlocListener<EditAllocationEntryCubit, EditAllocationEntryState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              loaded: () {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
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
        BlocListener<DeleteAllocationEntryCubit, DeleteAllocationEntryState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              loaded: () {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
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
      child: BlocBuilder<GetAllocationEntriesCubit, GetAllocationEntriesState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PRFLinearProgressIndicator(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PRFLinearProgressIndicator(),
            ),
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
        .fold<double>(0, (sum, entry) => sum + (entry.amount));

    final totalDebits = entries
        .where((e) => e.entryType == PRFEntryType.debit)
        .fold<double>(0, (sum, entry) => sum + (entry.amount));

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
    final isPositiveBalance = balance >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Main Balance Card with Enhanced Visual Hierarchy
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                  theme.colorScheme.secondary.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Overview',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$entryCount '
                            'transaction${entryCount == 1 ? '' : 's'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.85,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Current Balance - Prominent Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Balance',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            NumberFormat.currency(
                              symbol: 'KES ',
                              decimalDigits: 0,
                            ).format(balance.abs()),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          if (!isPositiveBalance)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'DEFICIT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (totalCredits > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: spentPercentage
                                .clamp(0.0, 1.0)
                                .toDouble(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: spentPercentage > 0.8
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(spentPercentage * 100).toStringAsFixed(1)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.8,
                                ),
                                fontWeight: FontWeight.w600,
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
          ),

          const SizedBox(height: 16),

          // Credits and Debits Cards - Side by Side
          Row(
            children: [
              Expanded(
                child: _buildEnhancedBalanceCard(
                  context,
                  'Allocation',
                  totalCredits,
                  Icons.trending_up_rounded,
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.onPrimaryContainer,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedBalanceCard(
                  context,
                  'Expenses',
                  totalDebits,
                  Icons.trending_down_rounded,
                  theme.colorScheme.errorContainer,
                  theme.colorScheme.onErrorContainer,
                  theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBalanceCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: textColor.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              symbol: 'KES ',
              decimalDigits: 0,
            ).format(amount),
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
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
      child: Column(
        children: [
          // Primary Actions Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildEnhancedActionButton(
                  context: context,
                  label: 'Add Expense',
                  subtitle: 'Quick entry',
                  icon: Icons.add_circle_outline,
                  onTap: () => _showAddExpenseModal(context),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedActionButton(
                  context: context,
                  label: 'Report',
                  subtitle: 'Email',
                  icon: Icons.email_outlined,
                  onTap: () => _showSendReportModal(context, entries),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      elevation: isPrimary ? 4 : 2,
      shadowColor: backgroundColor.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(
                    alpha: isPrimary ? 0.15 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: isPrimary ? 28 : 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
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
    final hasReceipts = entry.receipts.isNotEmpty;
    final missingReceipt = !isCredit && !hasReceipts;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
        child: InkWell(
          onTap: () => _showExpenseDetails(context, entry),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Category and Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.3,
                              )
                            : theme.colorScheme.errorContainer.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCredit ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isCredit
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            const SizedBox(height: 4),
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
                    const SizedBox(width: 8),
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
                          const SizedBox(height: 4),
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
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteConfirmation(context, entry),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
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
                  ],
                ),

                // Description Row (if exists)
                if (entry.narration.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.narration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                if (hasReceipts) ...[
                  _buildReceiptAttachments(context, entry.receipts),
                ] else if (missingReceipt) ...[
                  _buildMissingReceiptAction(context, entry),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptAttachments(
    BuildContext context,
    List<PRFMedia> receipts,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${receipts.length} Receipt${receipts.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Tap to view',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return GestureDetector(
                  onTap: () => _showReceiptPreview(context, receipts, index),
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Image.network(
                            receipt.temporaryURL,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                  size: 24,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingReceiptAction(
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_outlined,
              size: 20,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 12),
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
                  'Attach receipt for this expense',
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
                orElse: () => Material(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () async {
                      try {
                        await context.read<SelectMediaCubit>().selectMedia(
                          context: context,
                          modelUlid: entry.ulid,
                          model: PRFMediaModel.allocationEntryReceipts,
                          mediaType: RequestType.image,
                        );

                        // Get the selected media from the cubit state
                        // ignore: use_build_context_synchronously
                        context.read<SelectMediaCubit>().state.maybeWhen(
                          orElse: () {},
                          loaded: (imageDTOs) {
                            if (imageDTOs.isNotEmpty && context.mounted) {
                              context.read<UploadMediaCubit>().uploadMedia(
                                imageDTOs: imageDTOs,
                              );
                            }
                          },
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to select media: $e'),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 16,
                            color: theme.colorScheme.onError,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Attach',
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

  void _showReceiptPreview(
    BuildContext context,
    List<PRFMedia> receipts,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (context) => _ReceiptPreviewPage(
          receipts: receipts,
          initialIndex: initialIndex,
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
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: AddExpenseViewHandset(
          accountingEventUlid: accountingEventUlid,
        ),
      ),
    );
  }

  void _showSendReportModal(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SendFinancialReportViewHandset(
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
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        _buildExpenseDetailsModalPage(context, entry),
      ],
    );
  }

  WoltModalSheetPage _buildExpenseDetailsModalPage(
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    return WoltModalSheetPage(
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Delete Expense',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
                'Are you sure you want to delete this expense?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
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
              const SizedBox(height: 16),
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
              DeleteAllocationEntryCubit,
              DeleteAllocationEntryState
            >(
              listener: (context, state) {
                state.when(
                  initial: () {},
                  loading: () {},
                  loaded: () {
                    Navigator.of(dialogContext).pop();
                  },
                  error: (message) {
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  initial: () => _buildDeleteButton(theme, context, entry),
                  loaded: () => _buildDeleteButton(theme, context, entry),
                  error: (message) => _buildDeleteButton(theme, context, entry),
                );
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
        context.read<DeleteAllocationEntryCubit>().deleteAllocationEntry(
          allocationEntryUlid: entry.ulid,
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
}
