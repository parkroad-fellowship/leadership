// ignore_for_file: lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/shared/expenses/actions/add_expense/_handset.dart';
import 'package:leadership/shared/expenses/actions/add_refund/_handset.dart';
import 'package:leadership/shared/expenses/actions/add_token/_handset.dart';
import 'package:leadership/shared/expenses/actions/delete_expense/delete_expense_dialog.dart';
import 'package:leadership/shared/expenses/actions/edit_expense/_handset.dart';
import 'package:leadership/shared/expenses/actions/send_financial_report/_handset.dart';
import 'package:leadership/shared/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared/expenses/widgets/reciept_preview.dart';
import 'package:leadership/shared/media_upload/cubit/select_media_cubit.dart';
import 'package:leadership/shared/media_upload/cubit/upload_media_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
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
  ResourceOperation? _pendingMutationOperation;
  String get accountingEventUlid => widget.accountingEventUlid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
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
              mutating: (items, operation) {
                _pendingMutationOperation = operation;
              },
              listLoaded: (items, page, hasMore) {
                final operation = _pendingMutationOperation;
                _pendingMutationOperation = null;
                if (operation == ResourceOperation.create) {
                  _loadData();
                  PRFSnackbar.success(context, l10n.expenseEntrySaved);
                }
                if (operation == ResourceOperation.update) {
                  if (_deletingReceiptUuid != null) {
                    setState(() {
                      _deletingReceiptUuid = null;
                    });
                    _loadData();
                    PRFSnackbar.success(context, l10n.expenseReceiptDeleted);
                    return;
                  }

                  _loadData();
                  PRFSnackbar.success(context, l10n.expenseUpdated);
                }
                if (operation == ResourceOperation.delete) {
                  _loadData();
                  PRFSnackbar.success(context, l10n.expenseDeleted);
                }
              },
              error: (message, items) {
                if (_deletingReceiptUuid != null) {
                  setState(() {
                    _deletingReceiptUuid = null;
                  });
                }
                PRFSnackbar.error(context, l10n.expenseSaveFailed);
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
                PRFSnackbar.success(context, l10n.expenseReceiptUploaded);
              },
              error: (message) {
                PRFSnackbar.error(context, l10n.expenseReceiptUploadFailed);
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
                listLoading: (items) => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                  ),
                  child: PRFLinearProgressIndicator(),
                ),
                // Keep showing what we have when a refresh or change fails
                // (the listener already explains it); only an empty screen
                // becomes a full error state.
                error: (message, items) => items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                        child: PRFErrorView.inline(
                          title: l10n.expenseLoadErrorTitle,
                          message: l10n.expenseLoadErrorMessage,
                          retryLabel: l10n.tryAgain,
                          onRetry: _loadData,
                        ),
                      )
                    : _buildLoadedView(context, l10n, items),
                orElse: () {
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.lg,
                      ),
                      child: PRFEmptyView(
                        label: l10n.expenseEmptyTitle,
                        description: l10n.expenseEmptyDescription,
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
    Duration motion(Duration d) => PRFMotionTokens.resolve(context, d);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context, l10n, accountingEvent!),
        ),
        // Financial Overview Header
        SliverToBoxAdapter(
          child: _buildFinancialOverview(context, l10n, accountingEvent)
              .animate()
              .slideY(begin: -0.3, duration: motion(PRFMotionTokens.enterShort))
              .fadeIn(),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: _buildQuickActions(context, l10n, accountingEvent)
              .animate(delay: motion(PRFMotionTokens.stagger2))
              .slideY(begin: 0.3, duration: motion(PRFMotionTokens.enterShort))
              .fadeIn(),
        ),

        // Refund Information (show when balance > 0)
        SliverToBoxAdapter(
          child: _buildRefundInformation(context, l10n, accountingEvent),
        ),

        // Breakdown Toggle
        SliverToBoxAdapter(
          child: _buildBreakdownToggle(context, entries)
              .animate(delay: motion(PRFMotionTokens.stagger4))
              .slideX(begin: -0.2, duration: motion(PRFMotionTokens.enterShort))
              .fadeIn(),
        ),

        // Expenses List (if breakdown is shown)
        if (_showBreakdown && entries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildExpenseCard(context, entries[index])
                    .animate()
                    .fadeIn(
                      duration: motion(PRFMotionTokens.enterShort),
                      delay: motion((index.clamp(0, 8) * 50).ms),
                    )
                    .slideX(begin: 0.2, end: 0);
              }, childCount: entries.length),
            ),
          ),

        // Empty state when breakdown is shown but no entries
        if (_showBreakdown && entries.isEmpty)
          SliverToBoxAdapter(
            child: PRFEmptyView(
              label: l10n.expenseEmptyTitle,
              description: l10n.expenseEmptyDescription,
              icon: Icons.receipt_long_outlined,
            ).animate().fadeIn(duration: motion(PRFMotionTokens.enterShort)),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: PRFSpacingTokens.xxxl * 2),
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
    final onPrimary = theme.colorScheme.onPrimary;
    final spentPercentage = accountingEvent.credits > 0
        ? (accountingEvent.debits / accountingEvent.credits)
        : 0.0;
    Duration motion(Duration d) => PRFMotionTokens.resolve(context, d);

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
                      theme.colorScheme.primary.withValues(
                        alpha: PRFOpacities.stronger,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                  boxShadow: PRFShadowTokens.badge(theme.colorScheme.primary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.currentBalance,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: PRFSpacingTokens.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.md,
                            vertical: PRFSpacingTokens.xs,
                          ),
                          decoration: BoxDecoration(
                            color: onPrimary.withValues(
                              alpha: PRFOpacities.muted,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                          ),
                          child: Text(
                            l10n.expensePercentSpent(
                              (spentPercentage * 100).toStringAsFixed(1),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onPrimary,
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
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.lg),
                    // Share of received money already spent.
                    PRFLinearProgressIndicator(
                      value: spentPercentage.clamp(0.0, 1.0),
                      color: onPrimary,
                      backgroundColor: onPrimary.withValues(
                        alpha: PRFOpacities.glow,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: motion(PRFMotionTokens.enterShort))
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
                  context.statusColors.success.main,
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
                  NumberFormat.currency(locale: 'en_KE', symbol: 'KES ').format(
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
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: PRFOpacities.subtle),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(icon, size: PRFSizeTokens.iconSm, color: color),
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
        .fadeIn(
          delay: PRFMotionTokens.resolve(context, PRFMotionTokens.stagger2),
          duration: PRFMotionTokens.resolve(context, 400.ms),
        )
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    PRFAccountingEvent accountingEvent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      child: Row(
        children: [
          Expanded(
            child: PRFButton(
              onPressed: () => _showAddTokenModal(context, accountingEvent),
              title: l10n.addToken,
              variant: PRFButtonVariant.secondary,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: PRFButton(
              onPressed: () => _showAddExpenseModal(context),
              title: l10n.addExpense,
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
          excludeFromSemantics: true,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          child: Semantics(
            button: true,
            expanded: _showBreakdown,
            onTap: () => setState(() => _showBreakdown = !_showBreakdown),
            child: Padding(
              padding: const EdgeInsets.all(PRFSpacingTokens.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color: theme.colorScheme.onSurface,
                    size: PRFSizeTokens.iconLg,
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.expenseTransactionsTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _showBreakdown
                              ? context.l10n.expenseHideTransactions
                              : context.l10n.expenseShowTransactions(
                                  entries.length,
                                ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: PRFMotionTokens.resolve(
                      context,
                      PRFMotionTokens.standard,
                    ),
                    turns: _showBreakdown ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
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
                              alpha: PRFOpacities.glow,
                            )
                          : theme.colorScheme.errorContainer.withValues(
                              alpha: PRFOpacities.glow,
                            ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      isCredit ? Icons.trending_up : Icons.trending_down,
                      size: PRFSizeTokens.iconSm,
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
                    const SizedBox(width: PRFSpacingTokens.xs),
                    _buildCardIconButton(
                      context,
                      icon: Icons.delete_outline,
                      tooltip: l10n.expenseDeleteTooltip,
                      foreground: theme.colorScheme.error,
                      background: theme.colorScheme.errorContainer,
                      onPressed: () => _showDeleteConfirmation(context, entry),
                    ),
                  ],
                  // Edit Button
                  const SizedBox(width: PRFSpacingTokens.xs),
                  _buildCardIconButton(
                    context,
                    icon: Icons.edit_outlined,
                    tooltip: l10n.expenseEditTooltip,
                    foreground: theme.colorScheme.onPrimaryContainer,
                    background: theme.colorScheme.primaryContainer,
                    onPressed: () => _showExpenseDetails(context, entry),
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

  /// A 48dp, tooltip-labelled icon action on an expense card.
  Widget _buildCardIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color foreground,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: PRFSizeTokens.iconMd),
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        minimumSize: const Size.square(PRFSizeTokens.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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
    final l10n = context.l10n;
    const thumbSize = 76.0;
    const itemSize = thumbSize + PRFSpacingTokens.lg + PRFSpacingTokens.xs;

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(
          alpha: PRFOpacities.glow,
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: PRFOpacities.muted,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.hairline,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: PRFSizeTokens.iconSm,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.expenseAttachments(receipts.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          SizedBox(
            height: itemSize,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: receipts.length,
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                final isPdf = receipt.temporaryURL.toLowerCase().contains(
                  '.pdf',
                );

                final isDeleting = _deletingReceiptUuid == receipt.uuid;
                final thumbRadius = BorderRadius.circular(PRFRadiusTokens.lg);

                // The thumbnail sits bottom-left; the delete control's 48dp
                // hit area sits top-right, overlapping only the corner.
                return SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        width: thumbSize,
                        height: thumbSize,
                        child: Semantics(
                          button: true,
                          label: l10n.expenseOpenReceipt(index + 1),
                          excludeSemantics: true,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: thumbRadius,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
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
                              borderRadius: thumbRadius,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: thumbRadius,
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: PRFOpacities.glow,
                                    ),
                                    width: 2,
                                  ),
                                  color: isPdf
                                      ? theme.colorScheme.tertiaryContainer
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                ),
                                child: isPdf
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_present,
                                            size: PRFSizeTokens.iconXl,
                                            color: theme
                                                .colorScheme
                                                .onTertiaryContainer,
                                          ),
                                          Text(
                                            'PDF',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      )
                                    : Image.network(
                                        receipt.temporaryURL,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                size: PRFSizeTokens.iconLg,
                                              );
                                            },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              final total = loadingProgress
                                                  .expectedTotalBytes;
                                              return Center(
                                                child: PRFCircularProgressIndicator(
                                                  size: PRFSizeTokens.iconMd,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  value: total != null
                                                      ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            total
                                                      : null,
                                                ),
                                              );
                                            },
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Loading overlay during deletion
                      if (isDeleting)
                        Positioned(
                          left: 0,
                          bottom: 0,
                          width: thumbSize,
                          height: thumbSize,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.scrim.withValues(
                                alpha: PRFOpacities.half,
                              ),
                              borderRadius: thumbRadius,
                            ),
                            child: Center(
                              child: PRFCircularProgressIndicator(
                                size: PRFSizeTokens.iconMd,
                                color: theme.colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                      // Delete button (48dp hit area, 28dp visual)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Tooltip(
                          message: l10n.expenseDeleteReceiptLabel(index + 1),
                          child: Semantics(
                            button: true,
                            label: l10n.expenseDeleteReceiptLabel(index + 1),
                            excludeSemantics: true,
                            child: InkResponse(
                              onTap: isDeleting
                                  ? null
                                  : () => _showDeleteReceiptConfirmation(
                                      context,
                                      allocationEntryUlid,
                                      receipt,
                                    ),
                              radius: PRFSizeTokens.minTouchTarget / 2,
                              child: SizedBox.square(
                                dimension: PRFSizeTokens.minTouchTarget,
                                child: Center(
                                  child: Container(
                                    width:
                                        PRFSizeTokens.iconLg +
                                        PRFSpacingTokens.xs,
                                    height:
                                        PRFSizeTokens.iconLg +
                                        PRFSpacingTokens.xs,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                      boxShadow: PRFShadowTokens.card(
                                        theme.colorScheme.shadow,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: PRFSizeTokens.iconSm,
                                      color: theme.colorScheme.onError,
                                    ),
                                  ),
                                ),
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
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.expenseDeleteReceiptTitle,
      message: l10n.expenseDeleteReceiptMessage,
      confirmLabel: l10n.expenseDeleteReceiptConfirm,
      cancelLabel: l10n.cancel,
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
    final l10n = context.l10n;
    final warning = context.statusColors.warning;

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: warning.background,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: warning.main.withValues(alpha: PRFOpacities.glow),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: PRFSizeTokens.iconMd,
                color: warning.foreground,
              ),
              const SizedBox(width: PRFSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expenseReceiptMissingTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: warning.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.expenseReceiptMissingDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: warning.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          BlocBuilder<UploadMediaCubit, UploadMediaState>(
            builder: (context, uploadState) {
              return uploadState.maybeWhen(
                orElse: () => Row(
                  children: [
                    Expanded(
                      child: PRFButton(
                        onPressed: () => _attachReceiptPhoto(context, entry),
                        title: l10n.expenseAddPhoto,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Expanded(
                      child: PRFButton(
                        onPressed: () => _attachReceiptPdf(context, entry),
                        title: l10n.expenseAddPdf,
                        variant: PRFButtonVariant.secondary,
                      ),
                    ),
                  ],
                ),
                loading: () => Semantics(
                  liveRegion: true,
                  label: l10n.expenseUploadingReceipt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expenseUploadingReceipt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: warning.foreground,
                        ),
                      ),
                      const SizedBox(height: PRFSpacingTokens.xs),
                      PRFLinearProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _attachReceiptPhoto(
    BuildContext context,
    PRFAllocationEntry entry,
  ) async {
    final selectMedia = context.read<SelectMediaCubit>();
    final uploadMedia = context.read<UploadMediaCubit>();
    final failedMessage = context.l10n.expensePhotoPickFailed;
    try {
      await selectMedia.selectMediaWithSource(
        context: context,
        modelUlid: entry.ulid,
        model: PRFMediaModel.allocationEntryReceipts,
        mediaType: MediaType.image,
      );
      _uploadSelected(context, selectMedia, uploadMedia);
    } on Exception {
      if (context.mounted) PRFSnackbar.error(context, failedMessage);
    }
  }

  Future<void> _attachReceiptPdf(
    BuildContext context,
    PRFAllocationEntry entry,
  ) async {
    final selectMedia = context.read<SelectMediaCubit>();
    final uploadMedia = context.read<UploadMediaCubit>();
    final failedMessage = context.l10n.expensePdfPickFailed;
    try {
      await selectMedia.selectDocuments(
        modelUlid: entry.ulid,
        model: PRFMediaModel.allocationEntryReceipts,
      );
      _uploadSelected(context, selectMedia, uploadMedia);
    } on Exception {
      if (context.mounted) PRFSnackbar.error(context, failedMessage);
    }
  }

  /// Uploads whatever the picker left in [selectMedia] (nothing if the user
  /// cancelled).
  void _uploadSelected(
    BuildContext context,
    SelectMediaCubit selectMedia,
    UploadMediaCubit uploadMedia,
  ) {
    if (!context.mounted) return;
    selectMedia.state.maybeWhen(
      orElse: () {},
      loaded: (dtos) => uploadMedia.uploadMedia(imageDTOs: dtos),
    );
  }

  Future<void> _openPdfDocument(BuildContext context, String pdfUrl) async {
    try {
      final response = await Dio().get<List<int>>(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      if (!context.mounted) return;
      await PRFPdfViewer.show(
        context,
        bytes: bytes,
        title: context.l10n.expenseReceiptPdfTitle,
      );
    } on Exception {
      if (!context.mounted) return;
      PRFSnackbar.error(
        context,
        context.l10n.expensePdfLoadFailed,
        onRetry: () => _openPdfDocument(context, pdfUrl),
      );
    }
  }

  void _showReceiptPreview(
    BuildContext context,
    List<PRFMedia> receipts,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (context) =>
            ReceiptPreviewPage(receipts: receipts, initialIndex: initialIndex),
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
        child: EditExpenseViewHandset(allocationEntry: entry),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PRFAllocationEntry entry) {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return PRFConfirmationDialog(
          title: l10n.expenseDeleteTitle,
          isDestructive: true,
          content: ExpenseDeleteSummary(entry: entry),
          customActions: [
            BlocConsumer<
              AllocationEntryResourceCubit,
              ResourceState<PRFAllocationEntry>
            >(
              listener: (context, state) {
                state.maybeWhen(
                  mutating: (items, operation) {
                    _pendingMutationOperation = operation;
                  },
                  listLoaded: (items, page, hasMore) {
                    if (_pendingMutationOperation == ResourceOperation.delete) {
                      _pendingMutationOperation = null;
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

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PRFButton(
                      onPressed: () => context
                          .read<AllocationEntryResourceCubit>()
                          .deleteAllocationEntry(
                            allocationEntryUlid: entry.ulid,
                          ),
                      title: l10n.expenseDeleteConfirm,
                      variant: PRFButtonVariant.destructive,
                      isLoading: isDeleting,
                      disabled: isDeleting,
                    ),
                    const SizedBox(height: PRFSpacingTokens.md),
                    PRFButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      title: l10n.cancel,
                      variant: PRFButtonVariant.secondary,
                      disabled: isDeleting,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
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
        child: AddTokenViewHandset(accountingEventUlid: accountingEvent.ulid),
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
      title: context.l10n.expenseAddRefund,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: AddRefundViewHandset(accountingEventUlid: accountingEvent.ulid),
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
                      theme.colorScheme.tertiary.withValues(
                        alpha: PRFOpacities.subtle,
                      ),
                      theme.colorScheme.tertiary.withValues(
                        alpha: PRFOpacities.faint,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(
                      alpha: PRFOpacities.glow,
                    ),
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
                              alpha: PRFOpacities.muted,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.sm,
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.tertiary,
                            size: PRFSizeTokens.iconMd,
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
                            horizontal: PRFSpacingTokens.md,
                            vertical: PRFSpacingTokens.xs,
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
                              color: theme.colorScheme.onTertiary,
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
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color: theme.colorScheme.primary,
                                size: PRFSizeTokens.iconMd,
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Expanded(
                                child: Text(
                                  l10n.refundDetails,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                          alpha: PRFOpacities.glow,
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: PRFSizeTokens.iconSm,
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
                    PRFButton(
                      onPressed: () =>
                          _showAddRefundModal(context, accountingEvent),
                      title: l10n.expenseAddRefund,
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
              .fadeIn(
                duration: PRFMotionTokens.resolve(
                  context,
                  PRFMotionTokens.enterShort,
                ),
              )
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
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: theme.colorScheme.primary,
                size: PRFSizeTokens.iconMd,
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Text(
                context.l10n.expenseRefundEntries,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.sm,
                  vertical: PRFSpacingTokens.xs,
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
              color: theme.colorScheme.outlineVariant,
              height: PRFSpacingTokens.lg,
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
                horizontal: PRFSpacingTokens.sm,
                vertical: PRFSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.xs),
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
                    context.l10n.amount,
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
          context.l10n.expenseDeficitAmount,
          NumberFormat.currency(
            locale: 'en_KE',
            symbol: 'KES ',
          ).format(refund.deficitAmount),
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        _buildRefundDetailValue(
          context,
          theme,
          context.l10n.expenseConfirmation,
          refund.confirmationMessage,
          isCopyable: true,
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        _buildRefundDetailValue(
          context,
          theme,
          context.l10n.date,
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
              PRFSnackbar.info(context, context.l10n.expenseCopied);
            },
            tooltip: context.l10n.expenseCopyConfirmation,
            icon: Icon(
              Icons.copy,
              size: PRFSizeTokens.iconMd,
              color: theme.colorScheme.primary,
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
          size: PRFSizeTokens.iconSm,
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
        Semantics(
          button: true,
          label: context.l10n.expenseCopyValue(label, value),
          excludeSemantics: true,
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                PRFSnackbar.info(
                  context,
                  context.l10n.expenseCopiedValue(value),
                );
              },
              borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PRFSizeTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: PRFSpacingTokens.sm),
                      Icon(
                        Icons.copy,
                        size: PRFSizeTokens.iconSm,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
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
                listLoading: (items) => true,
                orElse: () => false,
              );

              return IconButton.filled(
                tooltip: l10n.expenseRefreshTooltip,
                onPressed: isRefreshing
                    ? null
                    : () => context
                          .read<AllocationEntryResourceCubit>()
                          .refreshForAccountingEvent(
                            accountingEventUlid: accountingEvent.ulid,
                          ),
                icon: isRefreshing
                    ? PRFCircularProgressIndicator(
                        size: PRFSizeTokens.iconMd,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  disabledBackgroundColor: theme.colorScheme.primaryContainer,
                  minimumSize: const Size.square(PRFSizeTokens.minTouchTarget),
                ),
              );
            },
          ),
          if (widget.showFinancialReport) ...[
            const SizedBox(width: PRFSpacingTokens.xs),
            IconButton.filled(
              tooltip: l10n.expenseSendReportTooltip,
              onPressed: () => _showSendReportModal(context),
              icon: const Icon(Icons.email_outlined),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                minimumSize: const Size.square(PRFSizeTokens.minTouchTarget),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSendReportModal(BuildContext context) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.expenseSendReportTitle,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: SendFinancialReportViewHandset(
          accountingEventUlid: accountingEventUlid,
        ),
      ),
    );
  }
}
