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
  bool _showValidation = false;

  String? _itemNameError;
  String? _categoryError;
  String? _unitPriceError;
  String? _quantityError;
  String? _narrationError;

  bool get _isFormValid {
    final unitPrice = int.tryParse(_unitPriceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());

    return selectedExpenseCategory != null &&
        _itemNameController.text.trim().isNotEmpty &&
        unitPrice != null &&
        unitPrice > 0 &&
        quantity != null &&
        quantity > 0 &&
        _narrationController.text.trim().isNotEmpty;
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
                          Icons.add_shopping_cart,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Add Requisition Item',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Add a new item to this requisition',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.9),
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
                                    loaded: (expenseCategories) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildCategorySelector(
                                          expenseCategories,
                                        ),
                                        if (_showValidation &&
                                            _categoryError != null) ...[
                                          const SizedBox(
                                            height: PRFSpacingTokens.xs,
                                          ),
                                          Text(
                                            _categoryError!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    error: (message) => Text(
                                      'Error loading categories: $message',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
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
                            labelText: 'Item Name *',
                            helperText: 'Required',
                            controller: _itemNameController,
                            enabled: !_isLoading,
                            errorText: _showValidation ? _itemNameError : null,
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
                                  labelText: 'Unit Price *',
                                  helperText: 'Required',
                                  controller: _unitPriceController,
                                  prefixText: 'KES ',
                                  enabled: !_isLoading,
                                  isLoading: _isLoading,
                                  errorText: _showValidation
                                      ? _unitPriceError
                                      : null,
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
                                  labelText: 'Quantity *',
                                  helperText: 'Required',
                                  controller: _quantityController,
                                  enabled: !_isLoading,
                                  isLoading: _isLoading,
                                  errorText: _showValidation
                                      ? _quantityError
                                      : null,
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
                            margin: const EdgeInsets.only(
                              top: PRFSpacingTokens.lg,
                            ),
                            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.md,
                              ),
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
                        labelText: 'Narration/Justification *',
                        helperText: 'Required',
                        controller: _narrationController,
                        enabled: !_isLoading,
                        errorText: _showValidation ? _narrationError : null,
                      ),
                    ).animate(delay: 450.ms).slideX(begin: -0.2).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              // Submit Button
              BlocConsumer<
                    RequisitionItemResourceCubit,
                    ResourceState<PRFRequisitionItem>
                  >(
                    listener: (context, state) {
                      switch (state) {
                        case ResourceMutating<PRFRequisitionItem>(
                          :final operation,
                        ):
                          if (operation == ResourceOperation.create) {
                            setState(() => _isLoading = true);
                          }
                        case ResourceMutated<PRFRequisitionItem>(
                          :final operation,
                        ):
                          if (operation == ResourceOperation.create) {
                            setState(() => _isLoading = false);
                            Gaimon.success();
                            Navigator.of(context).pop();
                            PRFSnackbar.success(
                              context,
                              'Requisition item created successfully',
                            );
                          }
                        case ResourceError<PRFRequisitionItem>(:final message):
                          setState(() => _isLoading = false);
                          Gaimon.error();
                          PRFSnackbar.error(context, message);
                        default:
                          break;
                      }
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
                  .animate(delay: PRFMotionTokens.enterMedium)
                  .slideY(begin: 0.3)
                  .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
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
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
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
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
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

  bool _validateForm({bool showSnackbar = true}) {
    _itemNameError = null;
    _categoryError = null;
    _unitPriceError = null;
    _quantityError = null;
    _narrationError = null;

    final unitPrice = int.tryParse(_unitPriceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());

    if (selectedExpenseCategory == null) {
      _categoryError = 'Please select an expense category';
    }

    if (_itemNameController.text.trim().isEmpty) {
      _itemNameError = 'Item name is required';
    }

    if (_unitPriceController.text.trim().isEmpty) {
      _unitPriceError = 'Unit price is required';
    } else if (unitPrice == null || unitPrice <= 0) {
      _unitPriceError = 'Enter a valid unit price';
    }

    if (_quantityController.text.trim().isEmpty) {
      _quantityError = 'Quantity is required';
    } else if (quantity == null || quantity <= 0) {
      _quantityError = 'Enter a valid quantity';
    }

    if (_narrationController.text.trim().isEmpty) {
      _narrationError = 'Narration/justification is required';
    }

    final isValid = [
      _itemNameError,
      _categoryError,
      _unitPriceError,
      _quantityError,
      _narrationError,
    ].every((error) => error == null);

    setState(() {
      _showValidation = true;
    });

    if (!isValid && showSnackbar) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fix the highlighted fields and try again.',
      );
    }

    return isValid;
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) {
      return;
    }

    final unitPrice = int.tryParse(_unitPriceController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (unitPrice == null || quantity == null) {
      PRFSnackbar.error(
        context,
        'Please enter valid numbers for price and quantity',
      );
      Gaimon.warning();
      return;
    }

    await context.read<RequisitionItemResourceCubit>().createRequisitionItem(
      requisitionUlid: widget.requisitionUlid,
      expenseCategoryUlid: selectedExpenseCategory!.ulid,
      itemName: _itemNameController.text.trim(),
      narration: _narrationController.text.trim(),
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }
}
