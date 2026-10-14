import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/shared/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class DeleteExpenseDialog extends StatelessWidget {
  const DeleteExpenseDialog({required this.entry, super.key});

  final PRFAllocationEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isToken = entry.entryType == PRFEntryType.credit;
    var deleteInProgress = false;

    return PRFConfirmationDialog(
      title: isToken ? l10n.expenseDeleteTokenTitle : l10n.expenseDeleteTitle,
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
                deleteInProgress = operation == ResourceOperation.delete;
              },
              listLoaded: (items, page, hasMore) {
                if (deleteInProgress) {
                  deleteInProgress = false;
                  Navigator.of(context).pop(true);
                }
              },
              error: (message, items) => Navigator.of(context).pop(false),
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
                      .deleteAllocationEntry(allocationEntryUlid: entry.ulid),
                  title: isToken
                      ? l10n.expenseDeleteTokenConfirm
                      : l10n.expenseDeleteConfirm,
                  variant: PRFButtonVariant.destructive,
                  isLoading: isDeleting,
                  disabled: isDeleting,
                ),
                const SizedBox(height: PRFSpacingTokens.md),
                PRFButton(
                  onPressed: () => Navigator.of(context).pop(),
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
  }
}

/// The body of an expense delete confirmation: what will be deleted (category,
/// amount, description) and that it cannot be undone.
class ExpenseDeleteSummary extends StatelessWidget {
  const ExpenseDeleteSummary({required this.entry, super.key});

  final PRFAllocationEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(PRFSpacingTokens.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(
              alpha: PRFOpacities.glow,
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            border: Border.all(
              color: theme.colorScheme.error.withValues(
                alpha: PRFOpacities.glow,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.expenseCategory?.name ?? l10n.unknownCategory,
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        Text(
          l10n.expenseDeleteMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
