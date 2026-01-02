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
import 'package:leadership/features/home/landing/expenses/actions/add_expense/_handset.dart';
import 'package:leadership/features/home/landing/expenses/actions/edit_expense/_handset.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/delete_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/edit_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/features/home/landing/expenses/widgets/reciept_preview.dart';
import 'package:leadership/features/home/landing/missions/cubit/delete_receipt_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_cubit.dart';
import 'package:leadership/features/home/landing/missions/mission_details/add_refund/_handset.dart';
import 'package:leadership/features/home/landing/missions/mission_details/add_token/_handset.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/shared_widgets/pdf_viewer.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ExpensesViewHandset extends StatefulWidget {
  const ExpensesViewHandset({
    required this.missionUlid,
    super.key,
  });

  final String missionUlid;

  @override
  State<ExpensesViewHandset> createState() => _ExpensesViewHandsetState();
}

class _ExpensesViewHandsetState extends State<ExpensesViewHandset>
    with TimezoneMixin {
  bool _showBreakdown = true;
  String get missionUlid => widget.missionUlid;

  String? accountingEventUlid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<GetMissionCubit, GetMissionState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              loaded: (mission) {
                accountingEventUlid = mission.accountingEvent!.ulid;
                context.read<GetAllocationEntriesCubit>().getAllocationEntries(
                  accountingEventUlid: mission.accountingEvent!.ulid,
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load mission: $message'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            );
          },
        ),
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
            loaded: (entries) => _buildLoadedView(context, l10n, entries),
            empty: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PRFEmptyView(
                label: 'No Expenses Yet',
                description: 'Start by adding your first expense',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            error: (message) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PRFEmptyView(
                label: 'Error',
                description: message,
                icon: Icons.error_outline,
                actionLabel: 'Retry',
                onActionPressed: _loadData,
              ),
            ),
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
          child: _buildFinancialOverview(
            context,
            l10n,
            accountingEvent,
          ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: _buildQuickActions(
            context,
            l10n,
            accountingEvent,
          ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
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
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    final spentPercentage = accountingEvent.credits > 0
        ? (accountingEvent.debits / accountingEvent.credits)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Main Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
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
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
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
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

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
              const SizedBox(width: 4),
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
              const SizedBox(width: 4),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
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
              const SizedBox(height: 12),
              Text(
                '$title\n',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 4),
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
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAddExpenseModal(context),
              icon: const Icon(Icons.receipt_long),
              label: Text(l10n.addExpense),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showDeleteConfirmation(context, entry),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.5,
                            ),
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
                  // Edit Button
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showExpenseDetails(context, entry),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
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

    return BlocListener<DeleteReceiptCubit, DeleteReceiptState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: (mediaUuid) {},
          loaded: (mediaUuid) {
            _loadData();
            context.read<GetAllocationEntriesCubit>().getAllocationEntries(
                  accountingEventUlid: accountingEventUlid!,
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt deleted successfully'),
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
      child: Container(
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
                  '${receipts.length} '
                  'Attachment${receipts.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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
                  final isPdf = receipt.temporaryURL.toLowerCase().contains(
                    '.pdf',
                  );

                  return BlocBuilder<DeleteReceiptCubit, DeleteReceiptState>(
                    builder: (context, state) {
                      final isDeleting = state.maybeWhen(
                        loading: (mediaUuid) => mediaUuid == receipt.uuid,
                        orElse: () => false,
                      );

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
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
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
                                                        Icons
                                                            .image_not_supported,
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
                                                    if (loadingProgress ==
                                                        null) {
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
                                                  borderRadius:
                                                      BorderRadius.circular(14),
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
                                        color: theme.colorScheme.shadow
                                            .withValues(alpha: 0.2),
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
                                    borderRadius: BorderRadius.circular(16),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteReceiptConfirmation(
    BuildContext context,
    String allocationEntryUlid,
    PRFMedia receipt,
  ) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Delete Receipt'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this receipt? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<DeleteReceiptCubit>().deleteReceipt(
                  allocationEntryUlid: allocationEntryUlid,
                  mediaUuid: receipt.uuid,
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        );
      },
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
                      borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12),
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
                              const SizedBox(width: 4),
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
                    const SizedBox(width: 8),
                    // Attach PDF Button
                    Material(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12),
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
                              const SizedBox(width: 4),
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
        child: accountingEventUlid != null
            ? AddExpenseViewHandset(
                accountingEventUlid: accountingEventUlid!,
              )
            : const SizedBox.shrink(),
      ),
    );
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

  void _showAddTokenModal(
    BuildContext context,
    PRFAccountingEvent accountingEvent,
  ) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.8,
              child: AddTokenViewHandset(
                accountingEventUlid: accountingEvent.ulid,
              ),
            ),
          ),
        ];
      },
    ).then((_) {
      if (context.mounted) {
        context.read<GetAllocationEntriesCubit>().getAllocationEntries(
          accountingEventUlid: accountingEvent.ulid,
        );
      }
    });
  }

  void _showAddRefundModal(
    BuildContext context,
    PRFAccountingEvent accountingEvent,
  ) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.8,
              child: AddRefundViewHandset(
                accountingEventUlid: accountingEvent.ulid,
              ),
            ),
          ),
        ];
      },
    ).then((_) {
      if (context.mounted) {
        context.read<GetAllocationEntriesCubit>().getAllocationEntries(
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: 0.1),
              theme.colorScheme.tertiary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
                    borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                      const SizedBox(width: 8),
                      Text(
                        l10n.refundDetails,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRefundDetailRow(
                    context,
                    l10n.paybillNumber,
                    '4088159',
                    Icons.numbers,
                  ),
                  const SizedBox(height: 8),
                  _buildRefundDetailRow(
                    context,
                    l10n.accountNumber,
                    'REFUND',
                    Icons.account_balance,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddRefundModal(context, accountingEvent),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (accountingEvent.refunds.isNotEmpty)
              _buildRefundEntriesList(context, theme, accountingEvent.refunds),
            if (accountingEvent.refunds.isNotEmpty) const SizedBox(height: 12),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildRefundEntriesList(
    BuildContext context,
    ThemeData theme,
    List<PRFRefund> refunds,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 8),
              Text(
                'Refund Entries',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 12),
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 8),
        _buildRefundDetailValue(
          context,
          theme,
          'Deficit Amount',
          NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(
            refund.deficitAmount,
          ),
        ),
        const SizedBox(height: 8),
        _buildRefundDetailValue(
          context,
          theme,
          'Confirmation',
          refund.confirmationMessage,
          isCopyable: true,
        ),
        const SizedBox(height: 8),
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
              const SizedBox(height: 4),
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
            padding: const EdgeInsets.all(4),
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
        const SizedBox(width: 8),
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
                const SizedBox(width: 4),
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
      padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 4),
                Text(
                  l10n.financialOverview,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<GetAllocationEntriesCubit, GetAllocationEntriesState>(
            builder: (context, state) {
              return IconButton.filled(
                onPressed: () => context
                    .read<GetAllocationEntriesCubit>()
                    .getAllocationEntries(
                      accountingEventUlid: accountingEvent.ulid,
                    ),
                icon: state.maybeWhen(
                  orElse: () => const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  loaded: (_) => const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
