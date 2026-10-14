import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/shared/expenses/cubit/refund_resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class AddRefundViewHandset extends StatefulWidget {
  const AddRefundViewHandset({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  State<AddRefundViewHandset> createState() => _AddRefundViewHandsetState();
}

class _AddRefundViewHandsetState extends State<AddRefundViewHandset> {
  final _amountController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _isLoading = false;

  bool get _isFormValid {
    return _amountController.text.isNotEmpty &&
        _confirmationController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFormChange);
    _confirmationController.addListener(_onFormChange);
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
            theme.colorScheme.tertiary.withValues(alpha: PRFOpacities.faint),
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
                          Icons.account_balance_wallet,
                          size: PRFSizeTokens.iconXl,
                          color: theme.colorScheme.onTertiary,
                        ),
                        const SizedBox(height: PRFSpacingTokens.sm),
                        Text(
                          l10n.expenseRefundTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          l10n.expenseRefundSubtitle,
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
                          title: l10n.expenseRefundAmountSection,
                          isRequired: true,
                          child: _buildNumberField(
                            controller: _amountController,
                            label: l10n.amount,
                            hint: l10n.expenseRefundAmountHint,
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
                          title: l10n.confirmationMessage,
                          isRequired: true,
                          child: Column(
                            children: [
                              PRFTextField(
                                hintText: l10n.expenseRefundConfirmationHint,
                                controller: _confirmationController,
                                maxLines: 6,
                                textInputAction: TextInputAction.done,
                                type: PRFTextFieldType.textArea,
                                minLines: 3,
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
              BlocConsumer<RefundResourceCubit, ResourceState<PRFRefund>>(
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
                            PRFSnackbar.success(
                              context,
                              l10n.expenseRefundRecorded,
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                        error: (message, items) {
                          setState(() {
                            _isLoading = false;
                          });
                          PRFSnackbar.error(context, l10n.expenseRefundFailed);
                        },
                        orElse: () {},
                      );
                    },
                    builder: (context, state) {
                      return PRFButton(
                        onPressed: _submitForm,
                        title: l10n.expenseAddRefund,
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

  void _submitForm() {
    if (!_isFormValid) return;

    final amount = double.parse(_amountController.text).round();
    final confirmationMessage = _confirmationController.text.trim();

    context.read<RefundResourceCubit>().addMissionRefund(
      accountingEventUlid: widget.accountingEventUlid,
      amount: amount,
      confirmationMessage: confirmationMessage,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }
}
