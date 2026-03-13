import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/shared_views/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

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
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(
                            context,
                          ).colorScheme.tertiary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          'Add Token',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          'Add funds as a credit entry to the allocation',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiary.withValues(alpha: 0.9),
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
                    PRFFormSection(
                          icon: Icons.attach_money,
                          title: 'Amount',
                          isRequired: true,
                          child: _buildNumberField(
                            controller: _amountController,
                            label: 'Token Amount',
                            hint: 'Enter token amount',
                            prefix: 'KES ',
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger2)
                        .slideX(begin: -0.2)
                        .fadeIn(),

                    PRFFormSection(
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
                        )
                        .animate(delay: PRFMotionTokens.stagger4)
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
                          Navigator.of(context).pop();
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                        orElse: () {},
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
        const SizedBox(height: PRFSpacingTokens.sm),
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

  void _submitForm() {
    if (!_isFormValid) return;

    final amount = double.parse(_amountController.text).round();

    context.read<AllocationEntryResourceCubit>().addAllocationTokenEntry(
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
