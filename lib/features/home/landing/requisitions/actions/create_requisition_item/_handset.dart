import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_requisition_item_cubit.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/shared_widgets/_index.dart';

class CreateRequisitionItemViewHandset extends StatefulWidget {
  const CreateRequisitionItemViewHandset({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  State<CreateRequisitionItemViewHandset> createState() =>
      _CreateRequisitionItemViewHandsetState();
}

class _CreateRequisitionItemViewHandsetState
    extends State<CreateRequisitionItemViewHandset> {
  final _itemNameController = TextEditingController();
  final _narrationController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;
  PRFExpenseCategory? selectedExpenseCategory;
  int _totalPrice = 0;

  bool get _isFormValid {
    return selectedExpenseCategory != null &&
        _itemNameController.text.isNotEmpty &&
        _unitPriceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Get expense categories when widget initializes
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();

    // Add listeners to calculate total
    _unitPriceController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _itemNameController.addListener(() => setState(() {}));
    _narrationController.addListener(() => setState(() {}));
  }

  void _calculateTotal() {
    final unitPrice = int.tryParse(_unitPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = unitPrice * quantity;
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _narrationController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Requisition Item',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a new item to this requisition',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Expense Category Selector
                    _buildFormSection(
                      icon: Icons.category_outlined,
                      title: 'Expense Category',
                      isRequired: true,
                      child:
                          BlocBuilder<
                            GetExpenseCategoriesCubit,
                            GetExpenseCategoriesState
                          >(
                            builder: (context, state) {
                              return state.when(
                                initial: () =>
                                    const PRFCircularProgressIndicator(),
                                loading: () =>
                                    const PRFCircularProgressIndicator(),
                                loaded: _buildCategorySelector,
                                error: (message) => Text(
                                  'Error loading categories: $message',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              );
                            },
                          ),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),

                    // Item Name
                    _buildFormSection(
                      icon: Icons.inventory_2_outlined,
                      title: 'Item Name',
                      isRequired: true,
                      child: PRFTextInput(
                        hintText: 'Enter item name',
                        controller: _itemNameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),

                    // Unit Price and Quantity Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormSection(
                            icon: Icons.attach_money,
                            title: 'Unit Price',
                            isRequired: true,
                            child: PRFNumberInput(
                              hintText: 'Unit price',
                              controller: _unitPriceController,
                              prefixText: 'KES ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormSection(
                            icon: Icons.numbers,
                            title: 'Quantity',
                            isRequired: true,
                            child: PRFNumberInput(
                              hintText: 'Quantity',
                              controller: _quantityController,
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 500.ms).slideX(begin: -0.2).fadeIn(),

                    // Total Price Display
                    if (_totalPrice > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'KES $_totalPrice',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ).animate(delay: 600.ms).slideY(begin: 0.2).fadeIn(),
                    const SizedBox(height: 16),
                    // Narration
                    _buildFormSection(
                      icon: Icons.note_outlined,
                      title: 'Narration',
                      child: PRFTextAreaInput(
                        hintText: 'Enter narration (optional)',
                        controller: _narrationController,
                      ),
                    ).animate(delay: 450.ms).slideX(begin: -0.2).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              BlocConsumer<
                    CreateRequisitionItemCubit,
                    CreateRequisitionItemState
                  >(
                    listener: (context, state) {
                      state.mapOrNull(
                        loading: (_) {
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        loaded: (_) {
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.success();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Requisition item created successfully',
                              ),
                            ),
                          );
                        },
                        error: (error) {
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.error();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        },
                      );
                    },
                    builder: (context, state) {
                      return PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: 'Add Item',
                        disabled: !_isFormValid,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .animate(delay: 700.ms)
                  .slideY(begin: 0.3)
                  .fadeIn(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required Widget child,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              FormFieldLabel(label: title, isRequired: isRequired),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildCategorySelector(List<PRFExpenseCategory> categories) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedExpenseCategory?.ulid == category.ulid;
        return GestureDetector(
          onTap: () => setState(() => selectedExpenseCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitForm() async {
    if (!_isFormValid) return;

    final unitPrice = int.tryParse(_unitPriceController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (unitPrice == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for price and quantity'),
        ),
      );
      Gaimon.warning();
      return;
    }

    await context.read<CreateRequisitionItemCubit>().createRequisitionItem(
      requisitionUlid: widget.requisitionUlid,
      expenseCategoryUlid: selectedExpenseCategory!.ulid,
      itemName: _itemNameController.text.trim(),
      narration: _narrationController.text.trim(),
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }
}
