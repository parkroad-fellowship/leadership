import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/shared/expenses/cubit/allocation_entry_resource_cubit.dart';
import 'package:leadership/shared/expenses/widgets/expense_choice_chip.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class AddTokenViewHandset extends StatefulWidget {
  const AddTokenViewHandset({required this.accountingEventUlid, super.key});

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
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                      boxShadow: PRFShadowTokens.badge(
                        theme.colorScheme.tertiary,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.toll,
                          size: PRFSizeTokens.iconXl,
                          color: theme.colorScheme.onTertiary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          l10n.addToken,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          l10n.expenseTokenSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                          icon: Icons.attach_money,
                          title: l10n.amount,
                          isRequired: true,
                          child: _buildNumberField(
                            controller: _amountController,
                            label: l10n.expenseTokenAmountLabel,
                            hint: l10n.expenseTokenAmountHint,
                            prefix: 'KES ',
                          ),
                        )
                        .animate(delay: motion(PRFMotionTokens.stagger2))
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
                                hintText: l10n.confirmationMessage,
                                controller: _confirmationController,
                                minLines: 3,
                                maxLines: 6,
                                textInputAction: TextInputAction.done,
                                type: PRFTextFieldType.textArea,
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
                            Navigator.of(context).pop();
                          }
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          PRFSnackbar.error(context, l10n.expenseTokenFailed);
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.expenseTokenButton,
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
        PRFTextField(
          controller: controller,
          hintText: hint,
          prefixText: prefix,
          type: PRFTextFieldType.number,
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
