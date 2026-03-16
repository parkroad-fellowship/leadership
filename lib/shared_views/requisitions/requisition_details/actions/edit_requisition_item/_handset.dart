import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared_views/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class EditRequisitionItemViewHandset extends StatefulWidget {
  const EditRequisitionItemViewHandset({
    required this.requisitionItemUlid,
    super.key,
  });

  final String requisitionItemUlid;

  @override
  State<EditRequisitionItemViewHandset> createState() =>
      _EditRequisitionItemViewHandsetState();
}

class _EditRequisitionItemViewHandsetState
    extends State<EditRequisitionItemViewHandset> {
  final _itemNameController = TextEditingController();
  final _narrationController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;
  PRFExpenseCategory? selectedExpenseCategory;
  PRFRequisitionItem? currentRequisitionItem;
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
    // Get expense categories and requisition item when widget initializes
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
    context.read<RequisitionItemResourceCubit>().loadRequisitionItem(
      requisitionItemUlid: widget.requisitionItemUlid,
    );

    // Add listeners to calculate total
    _unitPriceController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _itemNameController.addListener(() => setState(() {}));
    _narrationController.addListener(() => setState(() {}));
  }

  void _populateForm(PRFRequisitionItem requisitionItem) {
    setState(() {
      currentRequisitionItem = requisitionItem;
      selectedExpenseCategory = requisitionItem.expenseCategory;
      _itemNameController.text = requisitionItem.itemName;
      _narrationController.text = requisitionItem.narration ?? '';
      _unitPriceController.text = requisitionItem.unitPrice.toString();
      _quantityController.text = requisitionItem.quantity.toString();
    });
    _calculateTotal();
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
    return BlocListener<
      RequisitionItemResourceCubit,
      ResourceState<PRFRequisitionItem>
    >(
      listener: (context, state) {
        state.maybeWhen(
          listLoaded: (items, _, _) {
            if (items.isNotEmpty) {
              _populateForm(items.first);
            }
          },
          mutating: (_, operation) {
            if (operation == ResourceOperation.update) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          mutated: (_, operation, item) {
            if (operation == ResourceOperation.update) {
              setState(() {
                _isLoading = false;
              });
              if (item != null) {
                _populateForm(item);
              }
              Gaimon.success();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Requisition item updated successfully'),
                ),
              );
            }
          },
          error: (message, _) {
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
              Gaimon.error();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          orElse: () {},
        );
      },
      child: Container(
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
          padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: PRFSpacingTokens.lg),

                // Header Card
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
                            Icons.edit_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(height: PRFSpacingTokens.sm),
                          Text(
                            'Edit Requisition Item',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: PRFSpacingTokens.xs),
                          Text(
                            'Update the details of this requisition item',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withValues(
                                        alpha: 0.9,
                                      ),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(duration: PRFMotionTokens.enterShort),

                const SizedBox(height: PRFSpacingTokens.xxl),

                // Loading state for requisition item
                BlocBuilder<
                  RequisitionItemResourceCubit,
                  ResourceState<PRFRequisitionItem>
                >(
                  builder: (context, state) {
                    return switch (state) {
                      ResourceInitial<PRFRequisitionItem>() ||
                      ResourceListLoading<PRFRequisitionItem>() =>
                        const PRFCircularProgressIndicator(),
                      ResourceListLoaded<PRFRequisitionItem>() ||
                      ResourceMutating<PRFRequisitionItem>() ||
                      ResourceMutated<PRFRequisitionItem>() =>
                        _buildFormContent(),
                      ResourceError<PRFRequisitionItem>(
                        :final message,
                        :final items,
                      ) =>
                        items.isNotEmpty
                            ? _buildFormContent()
                            : Center(
                                child: Text(
                                  'Error loading requisition item: $message',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                      _ => const PRFCircularProgressIndicator(),
                    };
                  },
                ),

                const SizedBox(height: PRFSpacingTokens.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        // Form Card
        Container(
          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
              PRFFormSection(
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
                  )
                  .animate(delay: PRFMotionTokens.stagger3)
                  .slideX(begin: -0.2)
                  .fadeIn(),

              // Item Name
              PRFFormSection(
                    icon: Icons.inventory_2_outlined,
                    title: 'Item Name',
                    isRequired: true,
                    child: PRFTextInput(
                      hintText: 'Enter item name',
                      controller: _itemNameController,
                    ),
                  )
                  .animate(delay: PRFMotionTokens.stagger4)
                  .slideX(begin: -0.2)
                  .fadeIn(),

              // Unit Price and Quantity Row
              Row(
                    children: [
                      Expanded(
                        child: PRFFormSection(
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
                      const SizedBox(width: PRFSpacingTokens.lg),
                      Expanded(
                        child: PRFFormSection(
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
                  )
                  .animate(delay: PRFMotionTokens.stagger5)
                  .slideX(begin: -0.2)
                  .fadeIn(),

              // Total Price Display
              if (_totalPrice > 0)
                Container(
                      margin: const EdgeInsets.only(top: PRFSpacingTokens.lg),
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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
                    )
                    .animate(delay: PRFMotionTokens.enterShort)
                    .slideY(begin: 0.2)
                    .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.lg),
              // Narration
              PRFFormSection(
                icon: Icons.note_outlined,
                title: 'Narration/Justification',
                isRequired: true,
                child: PRFTextAreaInput(
                  hintText: 'Enter narration',
                  controller: _narrationController,
                ),
              ).animate(delay: 450.ms).slideX(begin: -0.2).fadeIn(),
            ],
          ),
        ),

        const SizedBox(height: PRFSpacingTokens.xxl),

        // Submit Button
        PRFPrimaryButton(
              onPressed: _submitForm,
              title: 'Update Item',
              disabled: !_isFormValid,
              isLoading: _isLoading,
            )
            .animate(delay: PRFMotionTokens.enterMedium)
            .slideY(begin: 0.3)
            .fadeIn(),
      ],
    );
  }

  Widget _buildCategorySelector(List<PRFExpenseCategory> categories) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: PRFSpacingTokens.sm,
      runSpacing: PRFSpacingTokens.sm,
      children: categories.map((category) {
        final isSelected = selectedExpenseCategory?.ulid == category.ulid;
        return GestureDetector(
          onTap: () => setState(() => selectedExpenseCategory = category),
          child: AnimatedContainer(
            duration: PRFMotionTokens.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
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

    if (_narrationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please provide a narration/justification for this item',
          ),
        ),
      );
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionItemResourceCubit>().updateRequisitionItem(
      requisitionUlid: currentRequisitionItem!.requisition!.ulid,
      requisitionItemUlid: widget.requisitionItemUlid,
      expenseCategoryUlid: selectedExpenseCategory!.ulid,
      itemName: _itemNameController.text.trim(),
      narration: _narrationController.text.trim(),
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }
}
