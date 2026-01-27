import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/manage_expense/cubit/delete_expense_category_cubit.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/shared_widgets/progress/circular_progress_indicator.dart';

class DeleteExpenseCategoryDialog extends StatelessWidget {
  const DeleteExpenseCategoryDialog({
    required this.category,
    required this.onExpenseCategoryDeleted,
    super.key,
  });
  final PRFExpenseCategory category;
  final VoidCallback onExpenseCategoryDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: context.read<DeleteExpenseCategoryCubit>(),
      child: AlertDialog(
        title: const Text('Delete Expense Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocConsumer<DeleteExpenseCategoryCubit, DeleteExpenseCategoryState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${category.name} deleted successfully'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  onExpenseCategoryDeleted();
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const PRFCircularProgressIndicator(),
                orElse: () => TextButton(
                  onPressed: () {
                    context
                        .read<DeleteExpenseCategoryCubit>()
                        .deleteExpenseCategory(
                          ulid: category.ulid,
                        );
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
