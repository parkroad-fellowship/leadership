import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class DeleteExpenseDialog extends StatelessWidget {
  const DeleteExpenseDialog({
    required this.entry,
    super.key,
  });

  final PRFAllocationEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return PRFConfirmationDialog(
      title: entry.entryType == PRFEntryType.credit
          ? 'Delete Token'
          : 'Delete Expense',
      isDestructive: true,
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
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
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
      customActions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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

            if (isDeleting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            return _buildDeleteButton(theme, context);
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton(ThemeData theme, BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
