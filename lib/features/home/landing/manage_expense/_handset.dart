import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/manage_expense/cubit/get_expense_categories_cubit.dart';

import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
//import 'package:leadership/utils/_index.dart';
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Search and Add Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PRFTextInput(
                  hintText: 'Search Categories',
                  controller: controller,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
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

          // List Content
          Expanded(
            child: BlocBuilder<ExpenseCategoriesCubit, ExpenseCategoriesState>(
              builder: (context, state) {
                return state.when(
                  initial: () =>
                      const Center(child: PRFCircularProgressIndicator()),
                  loading: () =>
                      const Center(child: PRFCircularProgressIndicator()),
                  empty: () => const PRFEmptyView(
                    label: 'No Categories',
                    description: 'Start by adding your first expense category',
                    icon: Icons.category_outlined,
                  ),
                  error: (message) => PRFEmptyView(
                    label: 'Error',
                    description: message,
                    icon: Icons.error_outline,
                    actionLabel: 'Retry',
                    onActionPressed: _loadData,
                  ),
                  loaded: (categories) {
                    if (controller.text.isEmpty) {
                      return const PRFEmptyView(
                        label: 'Search Categories',
                        description:
                            'Enter a name above to begin filtering categories',
                        icon: Icons.search,
                      );
                    }

                    // 2. Filter the list based on the search query
                    final filteredList = categories
                        .where(
                          (c) => c.name.toLowerCase().contains(
                            controller.text.toLowerCase(),
                          ),
                        )
                        .toList();

                    // 3. Check if the filtered result is empty
                    if (filteredList.isEmpty) {
                      return const PRFEmptyView(
                        label: 'No Results Found',
                        description:
                            'Try searching for a different category name',
                        icon: Icons.search_off,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(
                          theme,
                          categories[index],
                          index,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    ThemeData theme,
    PRFExpenseCategory category,
    int index,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.folder_open, color: theme.colorScheme.primary),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
              onPressed: () => _showCategoryForm(context, category),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
  }

  void _showCategoryForm(BuildContext context, PRFExpenseCategory? category) {
    final theme = Theme.of(context);
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            category == null ? 'Add Category' : 'Edit Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                
                const SizedBox(height: 20),
                PRFPrimaryButton(
                  onPressed: () {
                    Navigator.pop(modalContext);
                    _loadData();
                  },
                  title: 'Save Category',
                  disabled: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
