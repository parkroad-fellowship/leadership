import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared/expenses/cubit/expense_categories_resource_cubit.dart';
import 'package:leadership/shared/expenses/widgets/expense_choice_chip.dart';
import 'package:leadership/shared/media_upload/cubit/select_media_cubit.dart';
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
    context.read<ExpenseCategoriesResourceCubit>().loadAll(limit: 100);
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

  bool _validateForm({bool showSnackbar = true}) {
    _categoryError = null;
    _chargeTypeError = null;
    _unitCostError = null;
    _quantityError = null;
    _chargeError = null;
    _narrationError = null;
    _confirmationMessageError = null;

    final l10n = context.l10n;
    final unitCost = double.tryParse(_unitCostController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());
    final charge = double.tryParse(_chargeController.text.trim());

    if (selectedExpenseCategory == null) {
      _categoryError = l10n.expenseCategoryRequired;
    }

    if (selectedChargeType == null) {
      _chargeTypeError = l10n.expensePaymentMethodRequired;
    }

    if (_unitCostController.text.trim().isEmpty) {
      _unitCostError = l10n.expenseUnitCostRequired;
    } else if (unitCost == null || unitCost <= 0) {
      _unitCostError = l10n.expenseUnitCostInvalid;
    }

    if (_quantityController.text.trim().isEmpty) {
      _quantityError = l10n.expenseQuantityRequired;
    } else if (quantity == null || quantity <= 0) {
      _quantityError = l10n.expenseQuantityInvalid;
    }

    if (_chargeController.text.trim().isEmpty) {
      _chargeError = l10n.expenseChargeRequired;
    } else if (charge == null || charge < 0) {
      _chargeError = l10n.expenseChargeInvalid;
    }

    if (_narrationController.text.trim().isEmpty) {
      _narrationError = l10n.expenseDescriptionRequired;
    }

    if (_confirmationMessageController.text.trim().isEmpty) {
      _confirmationMessageError = l10n.expenseConfirmationRequired;
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
      PRFSnackbar.error(context, l10n.expenseFixFields);
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Duration motion(Duration d) => PRFMotionTokens.resolve(context, d);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.faint),
            theme.colorScheme.surface,
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
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                      boxShadow: PRFShadowTokens.badge(
                        theme.colorScheme.primary,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: PRFSizeTokens.iconXl,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          l10n.expenseAddTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          l10n.expenseAddSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
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
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: PRFOpacities.muted,
                              ),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.xl,
                              ),
                            ),
                            child: Text(
                              l10n.expenseTotal(
                                'KES ${_totalAmount.toStringAsFixed(2)}',
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: -0.3,
                    duration: motion(PRFMotionTokens.enterShort),
                  )
                  .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.xxl),

              // Form Card
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
                ),
                child: Column(
                  children: [
                    PRFFormSection(
                          icon: Icons.category,
                          title: l10n.expenseDetails,
                          isRequired: true,
                          child:
                              BlocBuilder<
                                ExpenseCategoriesResourceCubit,
                                ResourceState<PRFExpenseCategory>
                              >(
                                builder: (context, state) {
                                  return state.maybeWhen(
                                    orElse: () => const SizedBox.shrink(),
                                    error: (message, items) =>
                                        PRFErrorView.inline(
                                          title:
                                              l10n.expenseCategoriesLoadFailed,
                                          message: l10n.expenseLoadErrorMessage,
                                          retryLabel: l10n.tryAgain,
                                          onRetry: () => context
                                              .read<
                                                ExpenseCategoriesResourceCubit
                                              >()
                                              .loadAll(limit: 100),
                                        ),
                                    listLoading: (items) =>
                                        const PRFLinearProgressIndicator(),
                                    listLoaded: (expenseCategories, _, _) =>
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (expenseCategories.isEmpty)
                                              Text(
                                                l10n.noCategoriesFound,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              )
                                            else
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
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .error,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                  );
                                },
                              ),
                        )
                        .animate(delay: motion(PRFMotionTokens.stagger1))
                        .slideX(
                          begin: -0.2,
                          duration: motion(PRFMotionTokens.enterShort),
                        )
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
                        .animate(delay: motion(PRFMotionTokens.stagger2))
                        .slideX(
                          begin: -0.2,
                          duration: motion(PRFMotionTokens.enterShort),
                        )
                        .fadeIn(),

                    PRFFormSection(
                          icon: Icons.payment,
                          title: l10n.paymentMethod,
                          isRequired: true,
                          child: _buildTransactionTypeSelector(theme),
                        )
                        .animate(delay: motion(PRFMotionTokens.stagger3))
                        .slideX(
                          begin: -0.2,
                          duration: motion(PRFMotionTokens.enterShort),
                        )
                        .fadeIn(),

                    PRFFormSection(
                          icon: Icons.description,
                          title: l10n.description,
                          isRequired: true,
                          child: Column(
                            children: [
                              PRFTextField(
                                hintText: l10n.paymentDesc,
                                labelText: '${l10n.description} *',
                                helperText: l10n.expenseRequired,
                                controller: _narrationController,
                                enabled: !_isLoading,
                                errorText: _showValidation
                                    ? _narrationError
                                    : null,
                                type: PRFTextFieldType.textArea,
                                minLines: 3,
                                maxLines: 6,
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              PRFTextField(
                                hintText: l10n.confirmationMsg,
                                labelText: '${l10n.confirmationMsg} *',
                                helperText: l10n.expenseRequired,
                                controller: _confirmationMessageController,
                                enabled: !_isLoading,
                                errorText: _showValidation
                                    ? _confirmationMessageError
                                    : null,
                                type: PRFTextFieldType.textArea,
                                minLines: 3,
                                maxLines: 6,
                              ),
                            ],
                          ),
                        )
                        .animate(delay: motion(PRFMotionTokens.stagger4))
                        .slideX(
                          begin: -0.2,
                          duration: motion(PRFMotionTokens.enterShort),
                        )
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
                        listLoaded: (items, page, hasMore) {
                          if (_isLoading) {
                            setState(() {
                              _isLoading = false;
                            });
                            Gaimon.success();
                            PRFSnackbar.success(context, l10n.expenseRecorded);
                            Navigator.of(context).pop();
                          }
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          Gaimon.error();
                          PRFSnackbar.error(context, l10n.expenseAddFailed);
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.recordExpense,
                        // Always tappable: tapping with missing details
                        // highlights exactly what still needs filling in.
                        disabled: _isLoading,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .animate(delay: motion(PRFMotionTokens.stagger5))
                  .slideY(
                    begin: 0.3,
                    duration: motion(PRFMotionTokens.enterShort),
                  )
                  .fadeIn(),

              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<PRFExpenseCategory> categories) {
    return Wrap(
      spacing: PRFSpacingTokens.sm,
      runSpacing: PRFSpacingTokens.sm,
      children: categories.map((category) {
        return ExpenseChoiceChip(
          label: category.name,
          selected: selectedExpenseCategory?.ulid == category.ulid,
          enabled: !_isLoading,
          onTap: () => setState(() {
            selectedExpenseCategory = category;
            _categoryError = null;
          }),
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
    return PRFTextField(
      controller: controller,
      hintText: hint,
      labelText: '$label *',
      helperText: context.l10n.expenseRequired,
      prefixText: prefix,
      enabled: !_isLoading,
      isLoading: _isLoading,
      errorText: errorText,
      type: PRFTextFieldType.number,
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: PRFOpacities.half,
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
            return ExpenseChoiceChip(
              label: type.name,
              icon: _getPaymentIcon(type),
              selected: selectedChargeType == type,
              enabled: !_isLoading,
              onTap: () => setState(() {
                selectedChargeType = type;
                _chargeTypeError = null;
              }),
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
