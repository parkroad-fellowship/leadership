import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/features/events/desk_activity_details/cubit/payment_instruction_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/shared/requisitions/requisition_details/widgets/action_sheet_parts.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:prf_design/prf_design.dart';

class CreatePaymentInstructionViewHandset extends StatefulWidget {
  const CreatePaymentInstructionViewHandset({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  State<CreatePaymentInstructionViewHandset> createState() =>
      _CreatePaymentInstructionViewHandsetState();
}

class _CreatePaymentInstructionViewHandsetState
    extends State<CreatePaymentInstructionViewHandset> {
  // Common fields
  final _recipientNameController = TextEditingController();
  final _referenceController = TextEditingController();

  // MPESA fields
  final _mpesaPhoneController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
  );

  // Bank fields
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankSwiftCodeController = TextEditingController();

  // Paybill fields
  final _paybillNumberController = TextEditingController();
  final _paybillAccountNumberController = TextEditingController();

  // Till fields
  final _tillNumberController = TextEditingController();

  // Page controller
  final _pageController = PageController();

  PRFPaymentMethod? selectedPaymentMethod;
  bool _isLoading = false;
  int _currentPage = 0;

  bool get _isFormValid {
    if (selectedPaymentMethod == null ||
        _recipientNameController.text.trim().isEmpty) {
      return false;
    }

    switch (selectedPaymentMethod!) {
      case PRFPaymentMethod.mpesa:
        return _mpesaPhoneController.value.nsn.isNotEmpty;
      case PRFPaymentMethod.bankTransfer:
        return _bankNameController.text.isNotEmpty &&
            _bankAccountNumberController.text.isNotEmpty &&
            _bankAccountNameController.text.isNotEmpty;
      case PRFPaymentMethod.paybill:
        return _paybillNumberController.text.isNotEmpty &&
            _paybillAccountNumberController.text.isNotEmpty;
      case PRFPaymentMethod.tillNumber:
        return _tillNumberController.text.isNotEmpty;
    }
  }

  bool get _isStep1Valid {
    return selectedPaymentMethod != null &&
        _recipientNameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Make sure the cubit is subscribed to Hive DB updates so a successful
    // create emits ResourceState.listLoaded (which closes this sheet).
    context.read<PaymentInstructionResourceCubit>().subscribeToDbUpdates();
    // Add listeners to update form validation
    _recipientNameController.addListener(() => setState(() {}));
    _mpesaPhoneController.addListener(() => setState(() {}));
    _bankNameController.addListener(() => setState(() {}));
    _bankAccountNumberController.addListener(() => setState(() {}));
    _bankAccountNameController.addListener(() => setState(() {}));
    _paybillNumberController.addListener(() => setState(() {}));
    _paybillAccountNumberController.addListener(() => setState(() {}));
    _tillNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _recipientNameController.dispose();
    _referenceController.dispose();
    _mpesaPhoneController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    _bankBranchController.dispose();
    _bankSwiftCodeController.dispose();
    _paybillNumberController.dispose();
    _paybillAccountNumberController.dispose();
    _tillNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: requisitionSheetBackground(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            child: Row(
              children: [
                _buildStepIndicator(0, l10n.requisitionActionStepMethod),
                Expanded(
                  child: Container(
                    height: PRFSizeTokens.progressBarHeight / 2,
                    color: _currentPage >= 1
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
                _buildStepIndicator(1, l10n.details),
              ],
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
              ),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [_buildStep1(), _buildStep2()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _methodName(PRFPaymentMethod method) {
    final l10n = context.l10n;
    return switch (method) {
      PRFPaymentMethod.mpesa => l10n.requisitionDetailPaymentMpesa,
      PRFPaymentMethod.bankTransfer =>
        l10n.requisitionDetailPaymentBankTransfer,
      PRFPaymentMethod.paybill => l10n.requisitionDetailPaymentPaybill,
      PRFPaymentMethod.tillNumber => l10n.requisitionDetailPaymentTill,
    };
  }

  IconData _methodIcon(PRFPaymentMethod method) => switch (method) {
    PRFPaymentMethod.mpesa => Icons.phone_android,
    PRFPaymentMethod.bankTransfer => Icons.account_balance,
    PRFPaymentMethod.paybill => Icons.receipt,
    PRFPaymentMethod.tillNumber => Icons.store,
  };

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: PRFPaymentMethod.values.map((method) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
          child: RequisitionSelectableTile(
            label: _methodName(method),
            icon: _methodIcon(method),
            selected: selectedPaymentMethod == method,
            expand: true,
            onTap: () => setState(() => selectedPaymentMethod = method),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodFields() {
    switch (selectedPaymentMethod!) {
      case PRFPaymentMethod.mpesa:
        return _buildMpesaFields();
      case PRFPaymentMethod.bankTransfer:
        return _buildBankTransferFields();
      case PRFPaymentMethod.paybill:
        return _buildPaybillFields();
      case PRFPaymentMethod.tillNumber:
        return _buildTillNumberFields();
    }
  }

  Widget _buildMpesaFields() {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.phone,
          title: context.l10n.requisitionActionMpesaPhone,
          isRequired: true,
          child: PRFPhoneInput(
            hintText: context.l10n.requisitionActionMpesaPhoneHint,
            controller: _mpesaPhoneController,
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferFields() {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.account_balance,
          title: context.l10n.bankName,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.requisitionActionBankNameHint,
            controller: _bankNameController,
          ),
        ),
        PRFFormSection(
          icon: Icons.numbers,
          title: context.l10n.accountNumber,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.accountNumber,
            controller: _bankAccountNumberController,
            type: PRFTextFieldType.number,
          ),
        ),

        PRFFormSection(
          icon: Icons.person,
          title: context.l10n.accountName,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.accountName,
            controller: _bankAccountNameController,
          ),
        ),

        PRFFormSection(
          icon: Icons.location_on,
          title: context.l10n.branch,
          child: PRFTextField(
            hintText: context.l10n.requisitionActionOptional,
            controller: _bankBranchController,
          ),
        ),
        PRFFormSection(
          icon: Icons.code,
          title: context.l10n.swiftCode,
          child: PRFTextField(
            hintText: context.l10n.requisitionActionOptional,
            controller: _bankSwiftCodeController,
          ),
        ),
      ],
    );
  }

  Widget _buildPaybillFields() {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.receipt,
          title: context.l10n.paybillNumber,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.paybillNumber,
            controller: _paybillNumberController,
            type: PRFTextFieldType.number,
          ),
        ),

        PRFFormSection(
          icon: Icons.account_box,
          title: context.l10n.accountNumber,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.accountNumber,
            controller: _paybillAccountNumberController,
          ),
        ),
      ],
    );
  }

  Widget _buildTillNumberFields() {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.store,
          title: context.l10n.tillNumber,
          isRequired: true,
          child: PRFTextField(
            hintText: context.l10n.tillNumber,
            controller: _tillNumberController,
            type: PRFTextFieldType.number,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_isFormValid) {
      PRFSnackbar.warning(context, context.l10n.expenseFixFields);
      Gaimon.warning();
      return;
    }

    await context
        .read<PaymentInstructionResourceCubit>()
        .createPaymentInstruction(
          requisitionUlid: widget.requisitionUlid,
          paymentMethod: selectedPaymentMethod!,
          recipientName: _recipientNameController.text.trim(),
          reference: _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          mpesaPhoneNumber: selectedPaymentMethod == PRFPaymentMethod.mpesa
              ? _mpesaPhoneController.value.international
              : null,
          bankName: selectedPaymentMethod == PRFPaymentMethod.bankTransfer
              ? _bankNameController.text.trim()
              : null,
          bankAccountNumber:
              selectedPaymentMethod == PRFPaymentMethod.bankTransfer
              ? _bankAccountNumberController.text.trim()
              : null,
          bankAccountName:
              selectedPaymentMethod == PRFPaymentMethod.bankTransfer
              ? _bankAccountNameController.text.trim()
              : null,
          bankBranch:
              selectedPaymentMethod == PRFPaymentMethod.bankTransfer &&
                  _bankBranchController.text.trim().isNotEmpty
              ? _bankBranchController.text.trim()
              : null,
          bankSwiftCode:
              selectedPaymentMethod == PRFPaymentMethod.bankTransfer &&
                  _bankSwiftCodeController.text.trim().isNotEmpty
              ? _bankSwiftCodeController.text.trim()
              : null,
          paybillNumber: selectedPaymentMethod == PRFPaymentMethod.paybill
              ? _paybillNumberController.text.trim()
              : null,
          paybillAccountNumber:
              selectedPaymentMethod == PRFPaymentMethod.paybill
              ? _paybillAccountNumberController.text.trim()
              : null,
          tillNumber: selectedPaymentMethod == PRFPaymentMethod.tillNumber
              ? _tillNumberController.text.trim()
              : null,
        );
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = _currentPage >= step;
    final isCompleted = _currentPage > step;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.lg,
        vertical: PRFSpacingTokens.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: PRFSizeTokens.iconLg,
            height: PRFSizeTokens.iconLg,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: PRFSizeTokens.iconSm,
                      color: theme.colorScheme.onPrimary,
                    )
                  : Text(
                      '${step + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),
            requisitionActionHeader(
              context,
              icon: Icons.payment,
              title: l10n.paymentMethod,
              subtitle: l10n.requisitionActionPaymentStep1Subtitle,
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            requisitionFormCard(
              context,
              child: Column(
                children: [
                  PRFFormSection(
                    icon: Icons.payment_outlined,
                    title: l10n.paymentMethod,
                    isRequired: true,
                    child: _buildPaymentMethodSelector(),
                  ),
                  PRFFormSection(
                    icon: Icons.person_outline,
                    title: l10n.recipientName,
                    isRequired: true,
                    child: PRFTextField(
                      hintText: l10n.requisitionActionRecipientHint,
                      controller: _recipientNameController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            PRFButton(
              onPressed: _goToStep2,
              title: l10n.requisitionActionNext,
              disabled: !_isStep1Valid,
            ),
            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final method = selectedPaymentMethod;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),
            requisitionActionHeader(
              context,
              icon: Icons.info_outline,
              title: l10n.paymentDetails,
              subtitle: method != null
                  ? l10n.requisitionActionPaymentStep2Subtitle(
                      _methodName(method),
                    )
                  : null,
              background: scheme.secondary,
              foreground: scheme.onSecondary,
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            requisitionFormCard(
              context,
              child: Column(
                children: [
                  if (selectedPaymentMethod != null)
                    _buildPaymentMethodFields(),
                  PRFFormSection(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.reference,
                    child: PRFTextField(
                      hintText: l10n.requisitionActionOptional,
                      controller: _referenceController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            Row(
              children: [
                Expanded(
                  child: PRFButton(
                    onPressed: _goToStep1,
                    title: l10n.requisitionActionBack,
                    variant: PRFButtonVariant.secondary,
                    disabled: _isLoading,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.lg),
                Expanded(
                  flex: 2,
                  child:
                      BlocConsumer<
                        PaymentInstructionResourceCubit,
                        ResourceState<PRFPaymentInstruction>
                      >(
                        listener: (context, state) {
                          state.maybeWhen(
                            mutating: (items, operation) {
                              if (operation != ResourceOperation.create) {
                                return;
                              }
                              setState(() => _isLoading = true);
                            },
                            listLoaded: (items, page, hasMore) {
                              if (!_isLoading) return;
                              setState(() => _isLoading = false);
                              Gaimon.success();
                              Navigator.of(context).pop(true);
                              PRFSnackbar.success(
                                context,
                                l10n.requisitionActionPaymentSaved,
                              );
                            },
                            error: (_, _) {
                              if (!_isLoading) return;
                              setState(() => _isLoading = false);
                              Gaimon.error();
                              PRFSnackbar.error(
                                context,
                                l10n.requisitionActionPaymentSaveFailed,
                                onRetry: _submitForm,
                              );
                            },
                            orElse: () {},
                          );
                        },
                        builder: (context, state) {
                          return PRFButton(
                            onPressed: _submitForm,
                            title: l10n.requisitionActionSavePaymentDetails,
                            disabled: _isLoading,
                            isLoading: _isLoading,
                          );
                        },
                      ),
                ),
              ],
            ),
            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
    );
  }

  void _goToStep2() {
    if (_isStep1Valid) {
      _pageController.nextPage(
        duration: PRFMotionTokens.resolve(context, PRFMotionTokens.slow),
        curve: PRFMotionTokens.standardCurve,
      );
    }
  }

  void _goToStep1() {
    _pageController.previousPage(
      duration: PRFMotionTokens.resolve(context, PRFMotionTokens.slow),
      curve: PRFMotionTokens.standardCurve,
    );
  }
}
