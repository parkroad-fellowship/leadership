import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/cubit/create_payment_instruction_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/shared_widgets/input/phone/phone.dart';
import 'package:phone_form_field/phone_form_field.dart';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Method'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentPage >= 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                _buildStepIndicator(1, 'Details'),
              ],
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildPaymentMethodSelector() {
    final theme = Theme.of(context);
    final paymentMethods = <Map<String, dynamic>>[
      {
        'method': PRFPaymentMethod.mpesa,
        'name': 'M-PESA',
        'icon': Icons.phone_android,
      },
      {
        'method': PRFPaymentMethod.bankTransfer,
        'name': 'Bank Transfer',
        'icon': Icons.account_balance,
      },
      {
        'method': PRFPaymentMethod.paybill,
        'name': 'Paybill',
        'icon': Icons.receipt,
      },
      {
        'method': PRFPaymentMethod.tillNumber,
        'name': 'Till Number',
        'icon': Icons.store,
      },
    ];

    return Column(
      children: paymentMethods.map((methodData) {
        final method = methodData['method'] as PRFPaymentMethod;
        final name = methodData['name'] as String;
        final icon = methodData['icon'] as IconData;
        final isSelected = selectedPaymentMethod == method;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => selectedPaymentMethod = method),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
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
        _buildFormSection(
          icon: Icons.phone,
          title: 'M-PESA Phone Number',
          isRequired: true,
          child: PRFPhoneInput(
            hintText: 'Enter phone number (e.g., 254712345678)',
            controller: _mpesaPhoneController,
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferFields() {
    return Column(
      children: [
        _buildFormSection(
          icon: Icons.account_balance,
          title: 'Bank Name',
          isRequired: true,
          child: PRFTextInput(
            hintText: 'Enter bank name',
            controller: _bankNameController,
          ),
        ),
        _buildFormSection(
          icon: Icons.numbers,
          title: 'Account Number',
          isRequired: true,
          child: PRFNumberInput(
            hintText: 'Account number',
            controller: _bankAccountNumberController,
          ),
        ),

        _buildFormSection(
          icon: Icons.person,
          title: 'Account Name',
          isRequired: true,
          child: PRFTextInput(
            hintText: 'Account name',
            controller: _bankAccountNameController,
          ),
        ),

        _buildFormSection(
          icon: Icons.location_on,
          title: 'Branch',
          child: PRFTextInput(
            hintText: 'Branch (optional)',
            controller: _bankBranchController,
          ),
        ),
        _buildFormSection(
          icon: Icons.code,
          title: 'SWIFT Code',
          child: PRFTextInput(
            hintText: 'SWIFT code (optional)',
            controller: _bankSwiftCodeController,
          ),
        ),
      ],
    );
  }

  Widget _buildPaybillFields() {
    return Column(
      children: [
        _buildFormSection(
          icon: Icons.receipt,
          title: 'Paybill Number',
          isRequired: true,
          child: PRFNumberInput(
            hintText: 'Paybill number',
            controller: _paybillNumberController,
          ),
        ),

        _buildFormSection(
          icon: Icons.account_box,
          title: 'Account Number',
          isRequired: true,
          child: PRFTextInput(
            hintText: 'Account number',
            controller: _paybillAccountNumberController,
          ),
        ),
      ],
    );
  }

  Widget _buildTillNumberFields() {
    return Column(
      children: [
        _buildFormSection(
          icon: Icons.store,
          title: 'Till Number',
          isRequired: true,
          child: PRFNumberInput(
            hintText: 'Enter till number',
            controller: _tillNumberController,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_isFormValid) return;

    await context
        .read<CreatePaymentInstructionCubit>()
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : Text(
                      '${step + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
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
    return Padding(
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
                    Icons.payment,
                    size: 32,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose payment method and recipient details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

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
                  // Payment Method Selector
                  _buildFormSection(
                    icon: Icons.payment_outlined,
                    title: 'Payment Method',
                    isRequired: true,
                    child: _buildPaymentMethodSelector(),
                  ),

                  // Recipient Name
                  _buildFormSection(
                    icon: Icons.person_outline,
                    title: 'Recipient Name',
                    isRequired: true,
                    child: PRFTextInput(
                      hintText: 'Enter recipient name',
                      controller: _recipientNameController,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Next Button
            PRFPrimaryButton(
              onPressed: _goToStep2,
              title: 'Next',
              disabled: !_isStep1Valid,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
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
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedPaymentMethod != null
                        ? 'Enter specific details '
                              'for ${_getPaymentMethodName()}'
                        : 'Enter payment details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

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
                  // Dynamic fields based on payment method
                  if (selectedPaymentMethod != null)
                    _buildPaymentMethodFields(),

                  // Reference (Optional)
                  _buildFormSection(
                    icon: Icons.receipt_long_outlined,
                    title: 'Reference',
                    child: PRFTextInput(
                      hintText: 'Enter reference (optional)',
                      controller: _referenceController,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PRFSecondaryButton(
                    onPressed: _goToStep1,
                    title: 'Back',
                    disabled: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child:
                      BlocConsumer<
                        CreatePaymentInstructionCubit,
                        CreatePaymentInstructionState
                      >(
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
                                const SnackBar(
                                  content: Text(
                                    'Payment instructions created successfully',
                                  ),
                                ),
                              );
                            },
                            error: (errorState) {
                              setState(() {
                                _isLoading = false;
                              });
                              Gaimon.error();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorState.message)),
                              );
                            },
                          );
                        },
                        builder: (context, state) {
                          return PRFPrimaryButton(
                            onPressed: _submitForm,
                            title: 'Create instruction',
                            disabled: !_isFormValid,
                            isLoading: _isLoading,
                          );
                        },
                      ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _goToStep2() {
    if (_isStep1Valid) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep1() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getPaymentMethodName() {
    if (selectedPaymentMethod == null) return '';

    switch (selectedPaymentMethod!) {
      case PRFPaymentMethod.mpesa:
        return 'M-PESA';
      case PRFPaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PRFPaymentMethod.paybill:
        return 'Paybill';
      case PRFPaymentMethod.tillNumber:
        return 'Till Number';
    }
  }
}
