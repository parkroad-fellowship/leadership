import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/cubit/upload_media_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddExpenseViewHandset extends StatefulWidget {
  const AddExpenseViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  State<AddExpenseViewHandset> createState() => _AddExpenseViewHandsetState();
}

class _AddExpenseViewHandsetState extends State<AddExpenseViewHandset> {
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
    context.read<SelectMediaCubit>().clearMedia();
    _unitCostController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
    _chargeController.addListener(_calculateTotal);
    _confirmationController.addListener(() => setState(() {}));
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.03),
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Enhanced Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 32,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add New Expense',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Record your business expense with receipt attachment',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.9,
                        ),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_totalAmount > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total: KES ${_totalAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Enhanced Form Cards
              _buildEnhancedFormCard(
                icon: Icons.category_rounded,
                title: l10n.expenseDetails,
                isRequired: true,
                delay: 100,
                child: Column(
                  children: [
                    _buildCategoryDropdown(context, l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildEnhancedFormCard(
                icon: Icons.payments_rounded,
                title: l10n.amountDetails,
                isRequired: true,
                delay: 200,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildEnhancedNumberField(
                            controller: _unitCostController,
                            label: l10n.unitCost,
                            hint: 'Enter unit cost',
                            prefix: 'KES ',
                            icon: Icons.monetization_on_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildEnhancedNumberField(
                            controller: _quantityController,
                            label: l10n.quantity,
                            hint: 'Enter quantity',
                            prefix: 'Qty ',
                            icon: Icons.inventory_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildEnhancedNumberField(
                      controller: _chargeController,
                      label: l10n.charge,
                      hint: 'Enter additional charges',
                      prefix: 'KES ',
                      icon: Icons.add_circle_outline_rounded,
                      fullWidth: true,
                    ),
                    if (_totalAmount > 0) ...[
                      const SizedBox(height: 20),
                      _buildEnhancedCalculationSummary(theme, l10n),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildEnhancedFormCard(
                icon: Icons.payment_rounded,
                title: l10n.paymentMethod,
                isRequired: true,
                delay: 300,
                child: _buildEnhancedTransactionTypeSelector(theme),
              ),

              const SizedBox(height: 16),

              _buildEnhancedFormCard(
                icon: Icons.receipt_rounded,
                title: 'Receipt Attachment',
                delay: 350,
                child: _buildEnhancedReceiptAttachmentSection(),
              ),

              const SizedBox(height: 16),

              _buildEnhancedFormCard(
                icon: Icons.description_rounded,
                title: l10n.description,
                isRequired: true,
                delay: 400,
                child: Column(
                  children: [
                    _buildEnhancedTextArea(
                      controller: _narrationController,
                      label: l10n.description,
                      hint: 'Describe the expense purpose and details',
                      icon: Icons.notes_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildEnhancedTextArea(
                      controller: _confirmationController,
                      label: l10n.confirmationMessage,
                      hint: 'Add any confirmation or reference details',
                      icon: Icons.verified_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              BlocConsumer<AddAllocationEntryCubit, AddAllocationEntryState>(
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
                    title: l10n.addExpense,
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

  Widget _buildEnhancedFormCard({
    required IconData icon,
    required String title,
    required Widget child,
    bool isRequired = false,
    int delay = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildEnhancedNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    required IconData icon,
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: PRFNumberInput(
            controller: controller,
            hintText: hint,
            prefixText: prefix,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCalculationSummary(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final unitCost = double.tryParse(_unitCostController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final charge = double.tryParse(_chargeController.text) ?? 0;
    final lineTotal = unitCost * quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculation Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalculationRow('Sub Total', lineTotal, theme),
          const SizedBox(height: 8),
          _buildCalculationRow('Charge', charge, theme),
          const Divider(height: 24),
          _buildCalculationRow(
            'Total Amount',
            _totalAmount,
            theme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTransactionTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: PRFChargeType.values.map((type) {
            final isSelected = _selectedChargeType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedChargeType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentIcon(type),
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      type.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedReceiptAttachmentSection() {
    return BlocBuilder<SelectMediaCubit, SelectMediaState>(
      builder: (context, selectState) {
        return BlocBuilder<UploadMediaCubit, UploadMediaState>(
          builder: (context, uploadState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attach Receipt (Optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Media selection buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedMediaButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () => _selectMediaFromCamera(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedMediaButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _selectMediaFromGallery(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Selected media preview
                selectState.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  empty: () => const SizedBox.shrink(),
                  loaded: (media) => media.isNotEmpty
                      ? _buildEnhancedMediaPreview(media.first)
                      : const SizedBox.shrink(),
                ),

                // Upload progress
                uploadState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => _buildUploadProgress('Uploading receipt...'),
                  loaded: () =>
                      _buildUploadSuccess('Receipt uploaded successfully'),
                  error: (message) =>
                      _buildUploadError('Upload failed: $message'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surfaceContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMediaPreview(PRFMediaDTO mediaFile) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(mediaFile.path),
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => context.read<SelectMediaCubit>().clearMedia(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onError,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Image',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to upload',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                context.read<UploadMediaCubit>().uploadMedia(
                  imageDTOs: [mediaFile],
                );
              },
              icon: Icon(
                Icons.cloud_upload_rounded,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Upload',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 4,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadProgress(String message) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSuccess(String message) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadError(String message) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(PRFChargeType type) {
    switch (type) {
      case PRFChargeType.cash:
        return Icons.payments_rounded;
      case PRFChargeType.mpesaDefault:
      case PRFChargeType.mpesaOtherRegisteredUser:
      case PRFChargeType.mpesaAgentWithdrawal:
      case PRFChargeType.mpesaATMWithdrawal:
        return Icons.phone_android_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Widget _buildCategoryDropdown(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<GetExpenseCategoriesCubit, GetExpenseCategoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const PRFLinearProgressIndicator(),
          loaded: (categories) => DropdownButtonFormField<PRFExpenseCategory>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: l10n.category,
              border: const OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          error: (message) => Text('Error loading categories: $message'),
        );
      },
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
          _buildCalculationRow('Sub Total', lineTotal, theme),
          const SizedBox(height: 8),
          _buildCalculationRow('Charge', charge, theme),
          const Divider(),
          _buildCalculationRow(
            'Total Amount',
            _totalAmount,
            theme,
            isTotal: true,
          ),
        ],
      ),
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

  Widget _buildReceiptAttachmentSection() {
    return BlocBuilder<SelectMediaCubit, SelectMediaState>(
      builder: (context, selectState) {
        return BlocBuilder<UploadMediaCubit, UploadMediaState>(
          builder: (context, uploadState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media selection buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildMediaButton(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () => _selectMediaFromCamera(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () => _selectMediaFromGallery(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected media preview
                selectState.maybeMap(
                  orElse: () => const SizedBox.shrink(),
                  loaded: (results) => results.media.isNotEmpty
                      ? _buildMediaPreview(results.media.first)
                      : const SizedBox.shrink(),
                ),

                // Upload progress
                uploadState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => Column(
                    children: [
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 4),
                      Text(
                        'Uploading receipt...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  loaded: () => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Receipt uploaded successfully',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (message) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upload failed: $message',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(PRFMediaDTO mediaFile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(mediaFile.path),
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => context.read<SelectMediaCubit>().clearMedia(),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onError,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt Image',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to upload',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Upload the selected media
              context.read<UploadMediaCubit>().uploadMedia(
                imageDTOs: [mediaFile],
              );
            },
            icon: Icon(
              Icons.cloud_upload,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Upload',
          ),
        ],
      ),
    );
  }

  void _selectMediaFromCamera(BuildContext context) {
    context.read<SelectMediaCubit>().captureFromCamera(
      context: context,
      modelUlid: widget.accountingEventUlid,
      model: PRFMediaModel.allocationEntryReceipts,
      mediaType: RequestType.image,
    );
  }

  void _selectMediaFromGallery(BuildContext context) {
    context.read<SelectMediaCubit>().selectMedia(
      context: context,
      modelUlid: widget.accountingEventUlid,
      model: PRFMediaModel.allocationEntryReceipts,
      mediaType: RequestType.image,
    );
  }

  void _submitForm() {
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

    context.read<AddAllocationEntryCubit>().addAllocationEntry(
      accountingEventUlid: widget.accountingEventUlid,
      expenseCategoryUlid: _selectedCategory!.ulid,
      entryType: PRFEntryType.debit, // Always debit for expenses
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
