import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class AddExpenseViewHandset extends StatefulWidget {
  const AddExpenseViewHandset({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  State<AddExpenseViewHandset> createState() => _AddExpenseViewHandsetState();
}

class _AddExpenseViewHandsetState extends State<AddExpenseViewHandset> {
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final _chargeController = TextEditingController();
  final _narrationController = TextEditingController();
  final _confirmationMessageController = TextEditingController();

  bool _isLoading = false;
  PRFExpenseCategory? selectedExpenseCategory;
  PRFChargeType? selectedChargeType;
  double _totalAmount = 0;

  bool _showValidation = false;
  String? _categoryError;
  String? _chargeTypeError;
  String? _unitCostError;
  String? _quantityError;
  String? _chargeError;
  String? _narrationError;
  String? _confirmationMessageError;

  @override
  void initState() {
    super.initState();
    _unitCostController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _chargeController.addListener(_calculateTotal);
    _confirmationMessageController.addListener(() => setState(() {}));
    _narrationController.addListener(() => setState(() {}));
  }

  void _calculateTotal() {
    final unitCost = double.tryParse(_unitCostController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final charge = double.tryParse(_chargeController.text) ?? 0;
    final lineTotal = unitCost * quantity;

    setState(() {
      _totalAmount = lineTotal + charge;
    });
  }

  bool get _isFormValid {
    final unitCost = double.tryParse(_unitCostController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());
    final charge = double.tryParse(_chargeController.text.trim());

    return selectedExpenseCategory != null &&
        selectedChargeType != null &&
        unitCost != null &&
        unitCost > 0 &&
        quantity != null &&
        quantity > 0 &&
        charge != null &&
        charge >= 0 &&
        _narrationController.text.trim().isNotEmpty &&
        _confirmationMessageController.text.trim().isNotEmpty;
  }

  bool _validateForm({bool showSnackbar = true}) {
    _categoryError = null;
    _chargeTypeError = null;
    _unitCostError = null;
    _quantityError = null;
    _chargeError = null;
    _narrationError = null;
    _confirmationMessageError = null;

    final unitCost = double.tryParse(_unitCostController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());
    final charge = double.tryParse(_chargeController.text.trim());

    if (selectedExpenseCategory == null) {
      _categoryError = 'Please select an expense category';
    }

    if (selectedChargeType == null) {
      _chargeTypeError = 'Please select a payment method';
    }

    if (_unitCostController.text.trim().isEmpty) {
      _unitCostError = 'Unit cost is required';
    } else if (unitCost == null || unitCost <= 0) {
      _unitCostError = 'Enter a valid unit cost';
    }

    if (_quantityController.text.trim().isEmpty) {
      _quantityError = 'Quantity is required';
    } else if (quantity == null || quantity <= 0) {
      _quantityError = 'Enter a valid quantity';
    }

    if (_chargeController.text.trim().isEmpty) {
      _chargeError = 'Charge is required';
    } else if (charge == null || charge < 0) {
      _chargeError = 'Enter a valid charge';
    }

    if (_narrationController.text.trim().isEmpty) {
      _narrationError = 'Description is required';
    }

    if (_confirmationMessageController.text.trim().isEmpty) {
      _confirmationMessageError = 'Confirmation message is required';
    }

    final isValid = [
      _categoryError,
      _chargeTypeError,
      _unitCostError,
      _quantityError,
      _chargeError,
      _narrationError,
      _confirmationMessageError,
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                          Icons.receipt_long,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Add New Expense',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Fill in the details below to record a new expense',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (_totalAmount > 0) ...[
                          const SizedBox(height: PRFSpacingTokens.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PRFSpacingTokens.lg,
                              vertical: PRFSpacingTokens.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary
                                  .withValues(
                                    alpha: 0.2,
                                  ),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.xl,
                              ),
                            ),
                            child: Text(
                              'Total: KES ${_totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
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
                    PRFFormSection(
                          icon: Icons.category,
                          title: l10n.expenseDetails,
                          isRequired: true,
                          child:
                              BlocBuilder<
                                GetExpenseCategoriesCubit,
                                GetExpenseCategoriesState
                              >(
                                builder: (context, state) {
                                  return state.maybeWhen(
                                    orElse: () => const SizedBox.shrink(),
                                    loading: () =>
                                        const PRFLinearProgressIndicator(),
                                    loaded: (expenseCategories) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildCategorySelector(
                                          expenseCategories,
                                          Theme.of(context),
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
                                  );
                                },
                              ),
                        )
                        .animate(delay: PRFMotionTokens.stagger1)
                        .slideX(begin: -0.2)
                        .fadeIn(),

                    PRFFormSection(
                          icon: Icons.payments,
                          title: l10n.amountDetails,
                          isRequired: true,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNumberField(
                                      controller: _unitCostController,
                                      label: l10n.unitCost,
                                      hint: l10n.unitCostDesc,
                                      prefix: 'KES ',
                                      errorText: _showValidation
                                          ? _unitCostError
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: PRFSpacingTokens.lg),
                                  Expanded(
                                    child: _buildNumberField(
                                      controller: _quantityController,
                                      label: l10n.quantity,
                                      hint: l10n.enterQuantity,
                                      prefix: 'X ',
                                      errorText: _showValidation
                                          ? _quantityError
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              _buildNumberField(
                                controller: _chargeController,
                                label: l10n.charge,
                                hint: l10n.enterCharge,
                                prefix: 'KES ',
                                fullWidth: true,
                                errorText: _showValidation
                                    ? _chargeError
                                    : null,
                              ),
                              if (_totalAmount > 0) ...[
                                const SizedBox(height: PRFSpacingTokens.lg),
                                _buildCalculationSummary(
                                  Theme.of(context),
                                  l10n,
                                ),
                              ],
                            ],
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger2)
                        .slideX(begin: -0.2)
                        .fadeIn(),

                    PRFFormSection(
                          icon: Icons.payment,
                          title: l10n.paymentMethod,
                          isRequired: true,
                          child: _buildTransactionTypeSelector(
                            Theme.of(context),
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger3)
                        .slideX(begin: -0.2)
                        .fadeIn(),

                    PRFFormSection(
                          icon: Icons.description,
                          title: l10n.description,
                          isRequired: true,
                          child: Column(
                            children: [
                              PRFTextAreaInput(
                                hintText: l10n.paymentDesc,
                                labelText: '${l10n.description} *',
                                helperText: 'Required',
                                controller: _narrationController,
                                enabled: !_isLoading,
                                errorText: _showValidation
                                    ? _narrationError
                                    : null,
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              PRFTextAreaInput(
                                hintText: l10n.confirmationMsg,
                                labelText: '${l10n.confirmationMsg} *',
                                helperText: 'Required',
                                controller: _confirmationMessageController,
                                enabled: !_isLoading,
                                errorText: _showValidation
                                    ? _confirmationMessageError
                                    : null,
                              ),
                            ],
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger4)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: PRFSpacingTokens.xxl),

              // Submit Button
              BlocConsumer<
                    AllocationEntryResourceCubit,
                    ResourceState<PRFAllocationEntry>
                  >(
                    listener: (context, state) {
                      state.maybeWhen(
                        mutating: (items, operation) {
                          if (operation != ResourceOperation.create) {
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        mutated: (items, operation, item) {
                          if (operation != ResourceOperation.create) {
                            return;
                          }
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.success();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.expenseRecorded)),
                          );
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.error();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: l10n.recordExpense,
                        disabled: !_isFormValid,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .animate(delay: PRFMotionTokens.stagger5)
                  .slideY(begin: 0.3)
                  .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(
    List<PRFExpenseCategory> categories,
    ThemeData theme,
  ) {
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
              vertical: PRFSpacingTokens.md,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    String? errorText,
    bool fullWidth = false,
  }) {
    return PRFNumberInput(
      controller: controller,
      hintText: hint,
      labelText: '$label *',
      helperText: 'Required',
      prefixText: prefix,
      enabled: !_isLoading,
      isLoading: _isLoading,
      errorText: errorText,
    );
  }

  Widget _buildCalculationSummary(ThemeData theme, AppLocalizations l10n) {
    final unitCost = double.tryParse(_unitCostController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final charge = double.tryParse(_chargeController.text) ?? 0;
    final lineTotal = unitCost * quantity;

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildCalculationRow(l10n.subTotal, lineTotal, theme),
          const SizedBox(height: PRFSpacingTokens.sm),
          _buildCalculationRow(l10n.charge, charge, theme),
          const Divider(),
          _buildCalculationRow(
            l10n.totalAmount,
            _totalAmount,
            theme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isTotal
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: PRFSpacingTokens.sm,
          runSpacing: PRFSpacingTokens.sm,
          children: PRFChargeType.values.map((type) {
            final isSelected = selectedChargeType == type;
            return GestureDetector(
              onTap: () => setState(() {
                selectedChargeType = type;
                _chargeTypeError = null;
              }),
              child: AnimatedContainer(
                duration: PRFMotionTokens.standard,
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.md,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentIcon(type),
                      size: 16,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Flexible(
                      child: Text(
                        type.name,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_showValidation && _chargeTypeError != null) ...[
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _chargeTypeError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getPaymentIcon(PRFChargeType type) {
    switch (type) {
      case PRFChargeType.cash:
        return Icons.payments;
      case PRFChargeType.mpesaATMWithdrawal:
        return Icons.atm;
      case PRFChargeType.mpesaAgentWithdrawal:
      case PRFChargeType.mpesaDefault:
      case PRFChargeType.mpesaOtherRegisteredUser:
        return Icons.phone_android;
    }
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) {
      return;
    }

    final unitCost = double.parse(_unitCostController.text).round();
    final quantity = int.parse(_quantityController.text);
    final charge = double.parse(_chargeController.text).round();

    // Get uploaded media from SelectMediaCubit
    final uploadMediaState = context.read<SelectMediaCubit>().state;
    final uploadedMedia = uploadMediaState.maybeWhen(
      orElse: () => <PRFMediaDTO>[],
      loaded: (mediaItems) => mediaItems,
    );

    await context.read<AllocationEntryResourceCubit>().addAllocationEntry(
      accountingEventUlid: widget.accountingEventUlid,
      expenseCategoryUlid: selectedExpenseCategory!.ulid,
      entryType: PRFEntryType.debit, // Always debit for expenses
      chargeType: selectedChargeType!,
      charge: charge,
      unitCost: unitCost,
      quantity: quantity,
      narration: _narrationController.text,
      confirmationMessage: _confirmationMessageController.text,
      receiptDTOs: uploadedMedia,
    );
  }

  @override
  void dispose() {
    _unitCostController.dispose();
    _quantityController.dispose();
    _chargeController.dispose();
    _narrationController.dispose();
    _confirmationMessageController.dispose();
    super.dispose();
  }
}
