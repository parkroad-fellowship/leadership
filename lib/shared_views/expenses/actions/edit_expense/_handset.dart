import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class EditExpenseViewHandset extends StatefulWidget {
  const EditExpenseViewHandset({
    required this.allocationEntry,
    super.key,
  });

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
    _initializeFields();
    context.read<SelectMediaCubit>().clearMedia();
    _unitCostController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _chargeController.addListener(_calculateTotal);
  }

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
                          Icons.edit_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Edit Expense',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Update expense details and receipts',
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
                                    loaded: (expenseCategories) =>
                                        _buildCategorySelector(
                                          expenseCategories,
                                          Theme.of(context),
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
                                controller: _narrationController,
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              PRFTextAreaInput(
                                hintText: l10n.confirmationMsg,
                                controller: _confirmationController,
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
                          if (operation != ResourceOperation.update) {
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        mutated: (items, operation, item) {
                          if (operation != ResourceOperation.update) {
                            return;
                          }
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.expenseRecorded)),
                          );
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
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
                        title: 'Update Expense',
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
        final isSelected = _selectedCategory?.ulid == category.ulid;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: AnimatedContainer(
            duration: PRFMotionTokens.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.md,
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
        PRFNumberInput(
          controller: controller,
          hintText: hint,
          prefixText: prefix,
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
    return Wrap(
      spacing: PRFSpacingTokens.sm,
      runSpacing: PRFSpacingTokens.sm,
      children: PRFChargeType.values.map((type) {
        final isSelected = _selectedChargeType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedChargeType = type),
          child: AnimatedContainer(
            duration: PRFMotionTokens.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.md,
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
                Text(
                  type.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
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
