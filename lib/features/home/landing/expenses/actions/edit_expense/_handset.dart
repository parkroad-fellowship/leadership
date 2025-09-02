import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/select_media_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/edit_allocation_entry_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media_dto.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
        _narrationController.text.isNotEmpty &&
        _unitCostController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        double.tryParse(_unitCostController.text) != null &&
        int.tryParse(_quantityController.text) != null &&
        (double.tryParse(_chargeController.text) ?? 0) >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header with improved styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Expense',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update expense details and receipts',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: -0.2).fadeIn(),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense Category
                  _buildExpenseCategoryDropdown(
                    context,
                    l10n,
                  ).animate(delay: 100.ms).slideX(begin: -0.2).fadeIn(),

                  const SizedBox(height: 24),

                  // Receipt Upload Section
                  _buildReceiptUploadSection(
                    context,
                    l10n,
                  ).animate(delay: 200.ms).slideX(begin: 0.2).fadeIn(),

                  const SizedBox(height: 24),

                  // Amount Details Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Amount Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                          _buildTotalAmountDisplay(context),
                        ],
                      ],
                    ),
                  ).animate(delay: 300.ms).slideY(begin: 0.2).fadeIn(),

                  const SizedBox(height: 24),

                  // Payment Method
                  _buildPaymentMethodSection(
                    context,
                    l10n,
                  ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),

                  const SizedBox(height: 24),

                  // Description Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description & Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildEnhancedTextArea(
                          controller: _narrationController,
                          label: l10n.narration,
                          hint: 'Describe what this expense was for',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        _buildEnhancedTextArea(
                          controller: _confirmationController,
                          label: l10n.confirmationMessage,
                          hint: 'Add any confirmation or reference details',
                          icon: Icons.verified_rounded,
                        ),
                      ],
                    ),
                  ).animate(delay: 500.ms).slideY(begin: 0.2).fadeIn(),

                  const SizedBox(height: 24),

                  // Submit Button
                  BlocConsumer<
                        EditAllocationEntryCubit,
                        EditAllocationEntryState
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
                            title: 'Update Expense',
                            disabled: !_isFormValid,
                            isLoading: _isLoading,
                          );
                        },
                      )
                      .animate(delay: 600.ms)
                      .slideY(begin: 0.3)
                      .fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryDropdown(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return BlocBuilder<GetExpenseCategoriesCubit, GetExpenseCategoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const PRFLinearProgressIndicator(),
          loading: () => const PRFLinearProgressIndicator(),
          loaded: (categories) => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.expenseCategory,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PRFExpenseCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'Select expense category',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          error: (message) => PRFEmptyView(
            label: 'Error',
            description: message,
            icon: Icons.error_outline,
          ),
        );
      },
    );
  }

  Widget _buildReceiptUploadSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Receipt Upload',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SelectMediaCubit, SelectMediaState>(
              builder: (context, state) {
                return state.when(
                  initial: () => _buildUploadPrompt(context),
                  loading: () => const PRFLinearProgressIndicator(),
                  loaded: (mediaItems) =>
                      _buildMediaPreview(context, mediaItems),
                  error: (message) => Column(
                    children: [
                      _buildUploadPrompt(context),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  empty: () => _buildUploadPrompt(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _selectReceipts,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Receipt Photos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to select receipt images',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(
    BuildContext context,
    List<PRFMediaDTO> mediaItems,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${mediaItems.length} receipt(s) selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _selectReceipts,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add More'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mediaItems.length,
            itemBuilder: (context, index) {
              final media = mediaItems[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(media.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _removeReceipt(index),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.paymentMethod,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PRFChargeType.values.map((chargeType) {
                final isSelected = _selectedChargeType == chargeType;
                return Material(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  elevation: isSelected ? 2 : 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedChargeType = chargeType;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getChargeTypeIcon(chargeType),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getChargeTypeLabel(chargeType),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 3,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                icon,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmountDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total Amount',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'KES ${_totalAmount.toStringAsFixed(0)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _getChargeTypeLabel(PRFChargeType chargeType) {
    switch (chargeType) {
      case PRFChargeType.cash:
        return 'Cash';
      case PRFChargeType.mpesaDefault:
        return 'M-Pesa';
      case PRFChargeType.mpesaOtherRegisteredUser:
        return 'M-Pesa Other User';
      case PRFChargeType.mpesaAgentWithdrawal:
        return 'M-Pesa Agent';
      case PRFChargeType.mpesaATMWithdrawal:
        return 'M-Pesa ATM';
    }
  }

  IconData _getChargeTypeIcon(PRFChargeType chargeType) {
    switch (chargeType) {
      case PRFChargeType.cash:
        return Icons.money;
      case PRFChargeType.mpesaAgentWithdrawal:
      case PRFChargeType.mpesaDefault:
      case PRFChargeType.mpesaOtherRegisteredUser:
      case PRFChargeType.mpesaATMWithdrawal:
        return Icons.phone_android;
    }
  }

  Future<void> _selectReceipts() async {
    final mediaState = context.read<SelectMediaCubit>();
    await mediaState.selectMedia(
      context: context,
      modelUlid: widget.allocationEntry.accountingEvent?.ulid ?? '',
      model: PRFMediaModel.allocationEntryReceipts,
      mediaType: RequestType.image,
    );
  }

  void _removeReceipt(int index) {
    // Get current media list and remove item at index
    context.read<SelectMediaCubit>().state.maybeWhen(
      loaded: (mediaItems) {
        final updatedList = List<PRFMediaDTO>.from(mediaItems)..removeAt(index);
        // Clear and reload with updated list
        context.read<SelectMediaCubit>().clearMedia();
        if (updatedList.isNotEmpty) {
          context.read<SelectMediaCubit>().selectMedia(
            context: context,
            modelUlid: widget.allocationEntry.accountingEvent?.ulid ?? '',
            model: PRFMediaModel.allocationEntryReceipts,
            mediaType: RequestType.image,
            previousMedia: updatedList,
          );
        }
      },
      orElse: () {},
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

    context.read<EditAllocationEntryCubit>().updateAllocationEntry(
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
