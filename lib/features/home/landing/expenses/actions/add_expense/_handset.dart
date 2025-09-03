import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared_widgets/_index.dart';

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
    return selectedExpenseCategory != null &&
        selectedChargeType != null &&
        _unitCostController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _chargeController.text.isNotEmpty &&
        _narrationController.text.isNotEmpty &&
        _confirmationMessageController.text.isNotEmpty;
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
                      Icons.receipt_long,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add New Expense',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details below to record a new expense',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_totalAmount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary
                              .withValues(
                                alpha: 0.2,
                              ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total: KES ${_totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
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
                    _buildFormSection(
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
                    ).animate(delay: 100.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
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
                              const SizedBox(width: 16),
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
                          const SizedBox(height: 16),
                          _buildNumberField(
                            controller: _chargeController,
                            label: l10n.charge,
                            hint: l10n.enterCharge,
                            prefix: 'KES ',
                            fullWidth: true,
                          ),
                          if (_totalAmount > 0) ...[
                            const SizedBox(height: 16),
                            _buildCalculationSummary(Theme.of(context), l10n),
                          ],
                        ],
                      ),
                    ).animate(delay: 200.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.payment,
                      title: l10n.paymentMethod,
                      isRequired: true,
                      child: _buildTransactionTypeSelector(Theme.of(context)),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.description,
                      title: l10n.description,
                      isRequired: true,
                      child: Column(
                        children: [
                          PRFTextAreaInput(
                            hintText: l10n.paymentDesc,
                            controller: _narrationController,
                          ),
                          const SizedBox(height: 16),
                          PRFTextAreaInput(
                            hintText: l10n.confirmationMsg,
                            controller: _confirmationMessageController,
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              BlocConsumer<AddAllocationEntryCubit, AddAllocationEntryState>(
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
                        SnackBar(content: Text(l10n.expenseRecorded)),
                      );
                    },
                    error: (error) {
                      setState(() {
                        _isLoading = false;
                      });
                      Gaimon.error();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.message)));
                    },
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
              ).animate(delay: 500.ms).slideY(begin: 0.3).fadeIn(),

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

  Widget _buildCategorySelector(
    List<PRFExpenseCategory> categories,
    ThemeData theme,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedExpenseCategory?.ulid == category.ulid;
        return GestureDetector(
          onTap: () => setState(() => selectedExpenseCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildCalculationRow(l10n.subTotal, lineTotal, theme),
          const SizedBox(height: 8),
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
      spacing: 8,
      runSpacing: 8,
      children: PRFChargeType.values.map((type) {
        final isSelected = selectedChargeType == type;
        return GestureDetector(
          onTap: () => setState(() => selectedChargeType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 8),
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

    await context.read<AddAllocationEntryCubit>().addAllocationEntry(
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
