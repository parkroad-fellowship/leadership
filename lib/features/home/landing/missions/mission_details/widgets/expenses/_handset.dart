import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/features/home/landing/missions/cubit/get_mission_expense_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_expense.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_mission_expense.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ExpensesViewHandset extends StatefulWidget {
  const ExpensesViewHandset({required this.missionUlid, super.key});

  final String missionUlid;

  @override
  State<ExpensesViewHandset> createState() => _ExpensesViewHandsetState();
}

class _ExpensesViewHandsetState extends State<ExpensesViewHandset>
    with TimezoneMixin {
  String get missionUlid => widget.missionUlid;
  bool _showBreakdown = false;

  @override
  void initState() {
    context.read<GetMissionExpenseCubit>().getMissionExpense(
      missionUlid: missionUlid,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<GetMissionExpenseCubit, GetMissionExpenseState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => const Center(child: CircularProgressIndicator()),
          empty: () => PRFEmptyView(
            label: l10n.noExpenses,
            description: l10n.askMissionDeskToDisburseFunds,
          ),
          loaded: (missionExpense) {
            return RefreshIndicator(
              onRefresh: () => context
                  .read<GetMissionExpenseCubit>()
                  .getMissionExpense(missionUlid: missionUlid),
              child: CustomScrollView(
                slivers: [
                  // Header with actions
                  SliverToBoxAdapter(
                    child: _buildHeader(context, l10n, missionExpense),
                  ),

                  // Financial Overview Cards
                  SliverToBoxAdapter(
                    child: _buildFinancialOverview(
                      context,
                      l10n,
                      missionExpense,
                    ),
                  ),

                  // Expenses Breakdown Toggle
                  SliverToBoxAdapter(
                    child: _buildBreakdownToggle(context, l10n),
                  ),

                  // Expenses List
                  if (_showBreakdown)
                    SliverToBoxAdapter(
                      child: _buildExpensesList(
                        context,
                        l10n,
                        missionExpense.expenses,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 64,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    PRFMissionExpense missionExpense,
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
          BlocBuilder<GetMissionExpenseCubit, GetMissionExpenseState>(
            builder: (context, state) {
              return IconButton.filled(
                onPressed: () => context
                    .read<GetMissionExpenseCubit>()
                    .getMissionExpense(missionUlid: missionUlid),
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

  Widget _buildFinancialOverview(
    BuildContext context,
    AppLocalizations l10n,
    PRFMissionExpense missionExpense,
  ) {
    final theme = Theme.of(context);
    final spentPercentage = missionExpense.amountReceived > 0
        ? (missionExpense.amountSpent / missionExpense.amountReceived)
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
                  ).format(missionExpense.balance),
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
                  ).format(missionExpense.amountReceived),
                  Icons.trending_up,
                  theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.amountSpent,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(missionExpense.amountSpent),
                  Icons.trending_down,
                  theme.colorScheme.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.tokenAmount,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(missionExpense.tokenAmount),
                  Icons.token,
                  theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.amountToRefund,
                  NumberFormat.currency(
                    locale: 'en_KE',
                    symbol: 'KES ',
                  ).format(missionExpense.amountToRefund),
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
          padding: const EdgeInsets.all(16),
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
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildBreakdownToggle(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => setState(() => _showBreakdown = !_showBreakdown),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.list_alt,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.expenseBreakdown,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _showBreakdown ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    AppLocalizations l10n,
    List<PRFExpense> expenses,
  ) {
    if (expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No expenses recorded yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: expenses
            .map((expense) => _buildExpenseCard(context, l10n, expense))
            .toList(),
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    AppLocalizations l10n,
    PRFExpense expense,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showExpenseDetails(context, expense),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.category,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.expenseCategory!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          Misc.formatCash(expense.lineTotal),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                        Text(
                          '${Misc.formatCash(expense.unitCost)} '
                          '× ${expense.quantity}',
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
                ],
              ),

              // Description Row (if exists)
              if (expense.narration.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  expense.narration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Bottom Section with Charge Type, Receipts, and Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Charge Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getChargeTypeColor(
                        expense.chargeType,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expense.chargeType.name.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getChargeTypeColor(expense.chargeType),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Receipt Count and Timestamp Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Receipt Count (if exists)
                      if (expense.receipts.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt,
                                size: 12,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${expense.receipts.length} receipt'
                                '${expense.receipts.length > 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Spacer to push timestamp to the right
                      if (expense.receipts.isEmpty) const Spacer(),

                      // Timestamp
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Misc.timestamp(expense.createdAt, timezone),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Color _getChargeTypeColor(dynamic chargeType) {
    final theme = Theme.of(context);
    // You can customize colors based on charge type
    return theme.colorScheme.tertiary;
  }

  void _showExpenseDetails(BuildContext context, PRFExpense expense) {
    final l10n = context.l10n;
    WoltModalSheet.show<dynamic>(
      context: context,
      useSafeArea: true,
      pageListBuilder: (_) => [
        WoltModalSheetPage(
          child: _buildExpenseDetailsModal(context, l10n, expense),
        ),
      ],
    );
  }

  Widget _buildExpenseDetailsModal(
    BuildContext context,
    AppLocalizations l10n,
    PRFExpense expense,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.expenseDetails,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Expense Category
          if (expense.expenseCategory != null) ...[
            _buildDetailRow(
              context,
              'Category',
              expense.expenseCategory!.name,
              Icons.category,
            ),
            const SizedBox(height: 16),
          ],

          // Charge Type
          _buildDetailRow(
            context,
            'Charge Type',
            expense.chargeType.name.toUpperCase(),
            Icons.payment,
            valueColor: _getChargeTypeColor(expense.chargeType),
          ),
          const SizedBox(height: 16),

          // Amount Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAmountRow(context, l10n.unitCost, expense.unitCost),
                const SizedBox(height: 8),
                _buildAmountRow(
                  context,
                  l10n.quantity,
                  expense.quantity,
                  isQuantity: true,
                ),
                const SizedBox(height: 8),
                _buildAmountRow(context, l10n.total, expense.lineTotal),
                const SizedBox(height: 8),
                _buildAmountRow(context, l10n.transactionCost, expense.charge),
                const Divider(height: 24),
                _buildAmountRow(
                  context,
                  'Line Total',
                  expense.lineTotal + expense.charge,
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Narration
          if (expense.narration.isNotEmpty) ...[
            _buildDetailRow(
              context,
              l10n.description,
              expense.narration,
              Icons.description,
            ),
            const SizedBox(height: 16),
          ],

          // Member
          if (expense.member != null) ...[
            _buildDetailRow(
              context,
              l10n.member,
              '${expense.member!.firstName} ${expense.member!.lastName}',
              Icons.person,
            ),
            const SizedBox(height: 16),
          ],

          // Confirmation Message
          if (expense.confirmationMessage != null &&
              expense.confirmationMessage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      expense.confirmationMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Timestamps
          _buildDetailRow(
            context,
            'Created',
            Misc.timestamp(expense.createdAt, timezone),
            Icons.access_time,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Updated',
            Misc.timestamp(expense.updatedAt, timezone),
            Icons.update,
          ),
          const SizedBox(height: 24),

          // Receipts Section
          if (expense.receipts.isNotEmpty) ...[
            Text(
              'Receipts (${expense.receipts.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: expense.receipts.length,
                itemBuilder: (context, index) {
                  final receipt = expense.receipts[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showReceiptViewer(context, receipt),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Receipt Image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Image.network(
                                  receipt.temporaryURL,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 32,
                                    );
                                  },
                                ),
                              ),
                              // Overlay with receipt info
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    receipt.fileName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No receipts attached',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    int amount, {
    bool isQuantity = false,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          isQuantity
              ? amount.toString()
              // ignore: lines_longer_than_80_chars
              : 'KES ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }



  void _showReceiptViewer(BuildContext context, PRFMedia receipt) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  receipt.temporaryURL,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  receipt.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
