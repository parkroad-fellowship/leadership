import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared_views/expenses/cubit/add_allocation_token_entry_cubit.dart';
import 'package:leadership/shared_widgets/buttons/primary/primary.dart';
import 'package:leadership/shared_widgets/input/number/number.dart';
import 'package:leadership/shared_widgets/input/text_area/text_area.dart';

class AddTokenViewHandset extends StatefulWidget {
  const AddTokenViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  State<AddTokenViewHandset> createState() => _AddTokenViewHandsetState();
}

class _AddTokenViewHandsetState extends State<AddTokenViewHandset> {
  final _amountController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _isLoading = false;
  PRFChargeType _selectedChargeType = PRFChargeType.cash;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFormChange);
    _confirmationController.addListener(_onFormChange);
  }

  bool get _isFormValid {
    return _amountController.text.isNotEmpty &&
        _confirmationController.text.isNotEmpty;
  }

  void _onFormChange() {
    setState(() {});
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
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.toll,
                      size: 32,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Token',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add funds as a credit entry to the allocation',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiary.withValues(alpha: 0.9),
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
                    _buildFormSection(
                      icon: Icons.attach_money,
                      title: 'Amount',
                      isRequired: true,
                      child: _buildNumberField(
                        controller: _amountController,
                        label: 'Token Amount',
                        hint: 'Enter token amount',
                        prefix: 'KES ',
                      ),
                    ).animate(delay: 200.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.description,
                      title: l10n.description,
                      isRequired: true,
                      child: Column(
                        children: [
                          PRFTextAreaInput(
                            hintText: l10n.confirmationMessage,
                            controller: _confirmationController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.payment,
                      title: l10n.paymentMethod,
                      isRequired: true,
                      child: _buildTransactionTypeSelector(Theme.of(context)),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              BlocConsumer<
                    AddAllocationTokenEntryCubit,
                    AddAllocationTokenEntryState
                  >(
                    listener: (context, state) {
                      state.when(
                        initial: () {},
                        loading: () {
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        loaded: () {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        },
                        error: (message) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                      );
                    },
                    builder: (context, state) {
                      return PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: 'Add Token',
                        disabled: !_isFormValid,
                        isLoading: _isLoading,
                      );
                    },
                  )
                  .animate(delay: 500.ms)
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
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

  Widget _buildTransactionTypeSelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PRFChargeType.values.map((type) {
        final isSelected = _selectedChargeType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedChargeType = type),
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

  void _submitForm() {
    if (!_isFormValid) return;

    final amount = double.parse(_amountController.text).round();

    context.read<AddAllocationTokenEntryCubit>().addAllocationEntry(
      accountingEventUlid: widget.accountingEventUlid,
      entryType: PRFEntryType.credit, // Always credit for tokens
      unitCost: amount, // Use amount as unit cost
      narration: 'Token from the school',
      confirmationMessage: _confirmationController.text.trim(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }
}
