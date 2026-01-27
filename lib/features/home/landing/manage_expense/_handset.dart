import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/manage_expense/actions/expense_categories/add_expense_category/_handset.dart';
import 'package:leadership/features/home/landing/manage_expense/actions/expense_categories/update_expense_category/_handset.dart';

import 'package:leadership/features/home/landing/manage_expense/cubit/get_expense_categories_cubit.dart';

import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class ExpenseCategoriesPageHandsetView extends StatefulWidget {
  const ExpenseCategoriesPageHandsetView({super.key});

  @override
  State<ExpenseCategoriesPageHandsetView> createState() =>
      _ExpenseCategoriesPageHandsetViewState();
}

class _ExpenseCategoriesPageHandsetViewState
    extends State<ExpenseCategoriesPageHandsetView> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ExpenseCategoriesCubit>().getExpenseCategories();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: PRFAppBar(
        title: 'Expense Categories',
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: _loadData,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ExpenseCategoriesCubit, ExpenseCategoriesState>(
        listener: (context, state) {
          state.maybeWhen(
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
            loading: () => const Center(child: PRFCircularProgressIndicator()),
            empty: () => const PRFEmptyView(
              label: 'No Categories',
              description: 'Start by adding your first expense category',
              icon: Icons.category_outlined,
            ),
            loaded: (categories) {
              if (categories.isEmpty) {
                return PRFEmptyView(
                  label: 'No Categories',
                  description: 'Start by adding your first expense category',
                  icon: Icons.category_outlined,
                  actionLabel: 'Add Category',
                  onActionPressed: () => _showCategoryForm(context, null),
                );
              }
              return _buildCategoryList(theme, categories);
            },
            error: (message) => PRFEmptyView(
              label: 'Error Loading Categories',
              description: message,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(
    ThemeData theme,
    List<PRFExpenseCategory> categories,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PRFTextInput(
                hintText: 'Search Categories',
                controller: controller,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                child: PRFPrimaryButton(
                  onPressed: () => _showCategoryForm(context, null),
                  title: 'Add new category',
                  disabled: false,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...List.generate(categories.length, (index) {
                    final category = categories[index];
                    final searchQuery = controller.text.toLowerCase();
                    if (searchQuery.isNotEmpty &&
                        !category.name.toLowerCase().contains(searchQuery)) {
                      return const SizedBox.shrink();
                    }
                    return _buildCategoryCard(theme, category);
                  }),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ThemeData theme, PRFExpenseCategory category) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      child: InkWell(
        onTap: () => _showCategoryForm(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            theme.colorScheme.primary.withValues(
                              alpha: 0.05,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                            child: Text(
                              category.description,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //edit button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showCategoryForm(context, category),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
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
                    const SizedBox(width: 8),

                    //delete button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            _showDeleteCategoryDialog(context, category),
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
                ),
                const SizedBox(height: 14),
                Divider(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  height: 0,
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryForm(BuildContext context, PRFExpenseCategory? category) {
    final theme = Theme.of(context);
    final isEditing = category != null;
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            isEditing ? 'Edit Category' : 'Add Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(modalContext),
          ),

          child: isEditing
              ? EditExpenseCategoryHandsetView(
                  onExpenseCategoryUpdated: _loadData,
                  category: category,
                )
              : AddExpenseCategoryHandsetView(
                  onExpenseCategoryCreated: _loadData,
                ),
        ),
      ],
    );
  }
}

void _showDeleteCategoryDialog(
  BuildContext context,
  PRFExpenseCategory category,
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
                'Delete Category',
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
              'Are you sure you want to delete this category?',
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
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Call the original delete dialog to handle the deletion
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
