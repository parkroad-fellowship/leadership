import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
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

class EditExpenseViewHandset extends StatefulWidget {
  const EditExpenseViewHandset({required this.allocationEntry, super.key});

  final PRFAllocationEntry allocationEntry;

  @override
  State<EditExpenseViewHandset> createState() => _EditExpenseViewHandsetState();
}

class _EditExpenseViewHandsetState extends State<EditExpenseViewHandset> {
  final _narrationController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final _chargeController = TextEditingController();

  bool _isLoading = false;
  PRFChargeType _selectedChargeType = PRFChargeType.cash;
  PRFExpenseCategory? _selectedCategory;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCategoriesResourceCubit>().loadAll(limit: 100);
    _initializeFields();
    context.read<SelectMediaCubit>().clearMedia();
    _unitCostController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _chargeController.addListener(_calculateTotal);
    // Keep the save button's enabled state in sync with the text fields.
    _narrationController.addListener(_onFieldChanged);
    _confirmationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  void _initializeFields() {
    final entry = widget.allocationEntry;

    // Initialize form fields with existing data
    _narrationController.text = entry.narration;
    _confirmationController.text = entry.confirmationMessage ?? '';
    _unitCostController.text = entry.unitCost.toString();
    _quantityController.text = entry.quantity.toString();
    _chargeController.text = entry.charge.toString();

    // Set selected values
    _selectedChargeType = entry.chargeType ?? PRFChargeType.cash;
    _selectedCategory = entry.expenseCategory;

    // Calculate initial total
    _calculateTotal();
  }

  void _calculateTotal() {
    final unitCost = double.tryParse(_unitCostController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final charge = double.tryParse(_chargeController.text) ?? 0;

    setState(() {
      _totalAmount = (unitCost * quantity) + charge;
    });
  }

  bool get _isFormValid {
    return _selectedCategory != null &&
        _unitCostController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _chargeController.text.isNotEmpty &&
        _narrationController.text.isNotEmpty &&
        _confirmationController.text.isNotEmpty;
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
                          Icons.edit_outlined,
                          size: PRFSizeTokens.iconXl,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          l10n.expenseEditTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          l10n.expenseEditSubtitle,
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
                                        _buildCategorySelector(
                                          expenseCategories,
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
                                    ),
                                  ),
                                  const SizedBox(width: PRFSpacingTokens.lg),
                                  Expanded(
                                    child: _buildNumberField(
                                      controller: _quantityController,
                                      label: l10n.quantity,
                                      hint: l10n.enterQuantity,
                                      prefix: 'X ',
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
                          child: _buildTransactionTypeSelector(),
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
                                controller: _narrationController,
                                type: PRFTextFieldType.textArea,
                                minLines: 3,
                                maxLines: 6,
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              PRFTextField(
                                hintText: l10n.confirmationMsg,
                                controller: _confirmationController,
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
                          if (operation != ResourceOperation.update) {
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
                            PRFSnackbar.success(context, l10n.expenseUpdated);
                            Navigator.of(context).pop();
                          }
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          PRFSnackbar.error(context, l10n.expenseUpdateFailed);
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.expenseSaveChanges,
                        disabled: !_isFormValid,
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
          selected: _selectedCategory?.ulid == category.ulid,
          onTap: () => setState(() => _selectedCategory = category),
        );
      }).toList(),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        PRFTextField(
          controller: controller,
          hintText: hint,
          prefixText: prefix,
          type: PRFTextFieldType.number,
        ),
      ],
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

  Widget _buildTransactionTypeSelector() {
    return Wrap(
      spacing: PRFSpacingTokens.sm,
      runSpacing: PRFSpacingTokens.sm,
      children: PRFChargeType.values.map((type) {
        return ExpenseChoiceChip(
          label: type.name,
          icon: _getPaymentIcon(type),
          selected: _selectedChargeType == type,
          onTap: () => setState(() => _selectedChargeType = type),
        );
      }).toList(),
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
    if (!_isFormValid) return;

    final unitCost = double.parse(_unitCostController.text).round();
    final quantity = int.parse(_quantityController.text);
    final charge = double.parse(_chargeController.text).round();

    // Get uploaded media from SelectMediaCubit
    final uploadMediaState = context.read<SelectMediaCubit>().state;
    final uploadedMedia = uploadMediaState.maybeWhen(
      orElse: () => <PRFMediaDTO>[],
      loaded: (mediaItems) => mediaItems,
    );

    await context.read<AllocationEntryResourceCubit>().updateAllocationEntry(
      allocationEntryUlid: widget.allocationEntry.ulid,
      accountingEventUlid: widget.allocationEntry.accountingEvent!.ulid,
      expenseCategoryUlid: _selectedCategory!.ulid,
      entryType: widget.allocationEntry.entryType,
      chargeType: _selectedChargeType,
      charge: charge,
      unitCost: unitCost,
      quantity: quantity,
      narration: _narrationController.text,
      confirmationMessage: _confirmationController.text,
      receiptDTOs: uploadedMedia,
    );
  }

  @override
  void dispose() {
    _narrationController.dispose();
    _confirmationController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    _chargeController.dispose();
    super.dispose();
  }
}
