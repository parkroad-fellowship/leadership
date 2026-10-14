import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/shared/expenses/cubit/expense_categories_resource_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_detail_cubit.dart';
import 'package:leadership/shared/requisitions/cubit/requisition_item_resource_cubit.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
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
    _loadCategories();
    _loadItem();

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

  void _loadCategories() {
    context.read<ExpenseCategoriesResourceCubit>().loadAll(limit: 100);
  }

  void _loadItem() {
    context.read<RequisitionItemDetailCubit>().loadOne(
      id: widget.requisitionItemUlid,
      matchById: (item) => item.ulid == widget.requisitionItemUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<
      RequisitionItemDetailCubit,
      ResourceState<PRFRequisitionItem>
    >(
      listener: (context, state) {
        state.maybeWhen(
          itemLoaded: (item, _) {
            _populateForm(item);
          },
          orElse: () {},
        );
      },
      child:
          BlocListener<
            RequisitionItemResourceCubit,
            ResourceState<PRFRequisitionItem>
          >(
            listener: (context, state) {
              state.maybeWhen(
                mutating: (_, operation) {
                  if (operation == ResourceOperation.update) {
                    setState(() => _isLoading = true);
                  }
                },
                itemLoaded: (item, items) {
                  setState(() => _isLoading = false);
                  _populateForm(item);
                  Gaimon.success();
                  Navigator.of(context).pop();
                  PRFSnackbar.success(
                    context,
                    l10n.requisitionActionItemUpdated,
                  );
                },
                error: (_, _) {
                  if (_isLoading) {
                    setState(() => _isLoading = false);
                    Gaimon.error();
                    PRFSnackbar.error(
                      context,
                      l10n.requisitionActionItemUpdateFailed,
                      onRetry: _submitForm,
                    );
                  }
                },
                orElse: () {},
              );
            },
            child: DecoratedBox(
              decoration: requisitionSheetBackground(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: PRFSpacingTokens.lg),

                      requisitionActionHeader(
                        context,
                        icon: Icons.edit_outlined,
                        title: l10n.requisitionActionEditItemTitle,
                        subtitle: l10n.requisitionActionEditItemSubtitle,
                      ).entrance(context, slide: const Offset(0, -0.3)),

                      const SizedBox(height: PRFSpacingTokens.xxl),

                      BlocBuilder<
                        RequisitionItemDetailCubit,
                        ResourceState<PRFRequisitionItem>
                      >(
                        builder: (context, state) {
                          return switch (state) {
                            ResourceItemLoaded<PRFRequisitionItem>() =>
                              _buildFormContent(),
                            ResourceItemError<PRFRequisitionItem>(:final item)
                                when item != null =>
                              _buildFormContent(),
                            ResourceItemError<PRFRequisitionItem>() =>
                              PRFErrorView.inline(
                                title: l10n.requisitionActionItemLoadFailed,
                                message: l10n.requisitionDetailLoadErrorMessage,
                                retryLabel: l10n.tryAgain,
                                onRetry: _loadItem,
                              ),
                            _ => const Center(
                              child: PRFCircularProgressIndicator(),
                            ),
                          };
                        },
                      ),

                      const SizedBox(height: PRFSpacingTokens.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFormContent() {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
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
                          listLoaded: (expenseCategories, _, _) =>
                              _buildCategorySelector(expenseCategories),
                          error: (_, _) => PRFErrorView.inline(
                            title: l10n.expenseCategoriesLoadFailed,
                            message: l10n.requisitionDetailLoadErrorMessage,
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
                Container(
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
                          l10n.totalPrice,
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
                ).entrance(context, slide: const Offset(0, 0.2)),

              const SizedBox(height: PRFSpacingTokens.lg),
              PRFFormSection(
                icon: Icons.note_outlined,
                title: l10n.requisitionActionNarration,
                isRequired: true,
                child: PRFTextField(
                  hintText: l10n.requisitionActionNarrationHint,
                  controller: _narrationController,
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

        PRFButton(
          onPressed: _submitForm,
          title: l10n.requisitionActionSaveChanges,
          disabled: _isLoading,
          isLoading: _isLoading,
        ).entrance(
          context,
          delay: PRFMotionTokens.stagger5,
          slide: const Offset(0, 0.3),
        ),
      ],
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
          onTap: () => setState(() => selectedExpenseCategory = category),
        );
      }).toList(),
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (!_isFormValid) {
      PRFSnackbar.warning(context, l10n.expenseFixFields);
      Gaimon.warning();
      return;
    }

    final unitPrice = int.tryParse(_unitPriceController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (unitPrice == null || quantity == null) {
      PRFSnackbar.warning(context, l10n.requisitionActionNumbersInvalid);
      Gaimon.warning();
      return;
    }

    if (_narrationController.text.trim().isEmpty) {
      PRFSnackbar.warning(context, l10n.requisitionActionNarrationRequired);
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
