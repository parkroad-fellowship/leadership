import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared/expenses/cubit/expense_categories_resource_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCategories();

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

  void _loadCategories() {
    context.read<ExpenseCategoriesResourceCubit>().loadAll(limit: 100);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),

              requisitionActionHeader(
                context,
                icon: Icons.add_shopping_cart,
                title: l10n.requisitionActionAddItemTitle,
                subtitle: l10n.requisitionActionAddItemSubtitle,
              ).entrance(context, slide: const Offset(0, -0.3)),

              const SizedBox(height: PRFSpacingTokens.xxl),

              requisitionFormCard(
                context,
                child: Column(
                  children: [
                    PRFFormSection(
                      icon: Icons.category_outlined,
                      title: l10n.expenseCategory,
                      isRequired: true,
                      child:
                          BlocBuilder<
                            ExpenseCategoriesResourceCubit,
                            ResourceState<PRFExpenseCategory>
                          >(
                            builder: (context, state) {
                              return state.maybeWhen(
                                orElse: () => const Center(
                                  child: PRFCircularProgressIndicator(),
                                ),
                                listLoaded: (expenseCategories, _, _) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCategorySelector(expenseCategories),
                                    if (_showValidation &&
                                        _categoryError != null) ...[
                                      const SizedBox(
                                        height: PRFSpacingTokens.xs,
                                      ),
                                      Text(
                                        _categoryError!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                                error: (_, _) => PRFErrorView.inline(
                                  title: l10n.expenseCategoriesLoadFailed,
                                  message:
                                      l10n.requisitionDetailLoadErrorMessage,
                                  retryLabel: l10n.tryAgain,
                                  onRetry: _loadCategories,
                                ),
                              );
                            },
                          ),
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger3,
                      slide: const Offset(-0.2, 0),
                    ),

                    PRFFormSection(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.requisitionActionItemName,
                      isRequired: true,
                      child: PRFTextField(
                        hintText: l10n.requisitionActionItemNameHint,
                        controller: _itemNameController,
                        enabled: !_isLoading,
                        errorText: _showValidation ? _itemNameError : null,
                      ),
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger4,
                      slide: const Offset(-0.2, 0),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PRFFormSection(
                            icon: Icons.attach_money,
                            title: l10n.unitPrice,
                            isRequired: true,
                            child: PRFTextField(
                              hintText: l10n.requisitionActionUnitPriceHint,
                              controller: _unitPriceController,
                              prefixText: 'KES ',
                              enabled: !_isLoading,
                              isLoading: _isLoading,
                              errorText: _showValidation
                                  ? _unitPriceError
                                  : null,
                              type: PRFTextFieldType.number,
                            ),
                          ),
                        ),
                        const SizedBox(width: PRFSpacingTokens.lg),
                        Expanded(
                          child: PRFFormSection(
                            icon: Icons.numbers,
                            title: l10n.quantity,
                            isRequired: true,
                            child: PRFTextField(
                              hintText: l10n.enterQuantity,
                              controller: _quantityController,
                              enabled: !_isLoading,
                              isLoading: _isLoading,
                              errorText: _showValidation
                                  ? _quantityError
                                  : null,
                              type: PRFTextFieldType.number,
                            ),
                          ),
                        ),
                      ],
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(-0.2, 0),
                    ),

                    if (_totalPrice > 0)
                      _buildTotal(
                        context,
                      ).entrance(context, slide: const Offset(0, 0.2)),
                    const SizedBox(height: PRFSpacingTokens.lg),
                    PRFFormSection(
                      icon: Icons.note_outlined,
                      title: l10n.requisitionActionNarration,
                      isRequired: true,
                      child: PRFTextField(
                        hintText: l10n.requisitionActionNarrationHint,
                        controller: _narrationController,
                        enabled: !_isLoading,
                        errorText: _showValidation ? _narrationError : null,
                        type: PRFTextFieldType.textArea,
                        minLines: 3,
                        maxLines: 6,
                      ),
                    ).entrance(
                      context,
                      delay: PRFMotionTokens.stagger5,
                      slide: const Offset(-0.2, 0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              BlocConsumer<
                    RequisitionItemResourceCubit,
                    ResourceState<PRFRequisitionItem>
                  >(
                    listener: (context, state) {
                      switch (state) {
                        case ResourceMutating<PRFRequisitionItem>(
                              :final operation,
                            )
                            when operation == ResourceOperation.create:
                          setState(() => _isLoading = true);
                        case ResourceListLoaded<PRFRequisitionItem>()
                            when _isLoading:
                          setState(() => _isLoading = false);
                          Gaimon.success();
                          Navigator.of(context).pop();
                          PRFSnackbar.success(
                            context,
                            l10n.requisitionActionItemAdded,
                          );
                        case ResourceError<PRFRequisitionItem>()
                            when _isLoading:
                          setState(() => _isLoading = false);
                          Gaimon.error();
                          PRFSnackbar.error(
                            context,
                            l10n.requisitionActionItemAddFailed,
                            onRetry: _submitForm,
                          );
                        default:
                          break;
                      }
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.addItem,
                        disabled: _isLoading,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .entrance(
                    context,
                    delay: PRFMotionTokens.stagger5,
                    slide: const Offset(0, 0.3),
                  ),

              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotal(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: PRFSpacingTokens.lg),
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.totalPrice,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            formatKes(_totalPrice),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(List<PRFExpenseCategory> categories) {
    return Wrap(
      spacing: PRFSpacingTokens.sm,
      runSpacing: PRFSpacingTokens.sm,
      children: categories.map((category) {
        return RequisitionSelectableTile(
          label: category.name,
          selected: selectedExpenseCategory?.ulid == category.ulid,
          onTap: _isLoading
              ? null
              : () => setState(() => selectedExpenseCategory = category),
        );
      }).toList(),
    );
  }

  bool _validateForm({bool showSnackbar = true}) {
    final l10n = context.l10n;
    _itemNameError = null;
    _categoryError = null;
    _unitPriceError = null;
    _quantityError = null;
    _narrationError = null;

    final unitPrice = int.tryParse(_unitPriceController.text.trim());
    final quantity = int.tryParse(_quantityController.text.trim());

    if (selectedExpenseCategory == null) {
      _categoryError = l10n.expenseCategoryRequired;
    }

    if (_itemNameController.text.trim().isEmpty) {
      _itemNameError = l10n.requisitionActionItemNameRequired;
    }

    if (_unitPriceController.text.trim().isEmpty) {
      _unitPriceError = l10n.requisitionActionUnitPriceRequired;
    } else if (unitPrice == null || unitPrice <= 0) {
      _unitPriceError = l10n.requisitionActionUnitPriceInvalid;
    }

    if (_quantityController.text.trim().isEmpty) {
      _quantityError = l10n.expenseQuantityRequired;
    } else if (quantity == null || quantity <= 0) {
      _quantityError = l10n.expenseQuantityInvalid;
    }

    if (_narrationController.text.trim().isEmpty) {
      _narrationError = l10n.requisitionActionNarrationRequired;
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
      PRFSnackbar.warning(context, l10n.expenseFixFields);
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
      PRFSnackbar.warning(
        context,
        context.l10n.requisitionActionNumbersInvalid,
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
