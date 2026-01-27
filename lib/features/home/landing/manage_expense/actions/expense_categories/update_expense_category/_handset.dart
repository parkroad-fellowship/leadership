import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/manage_expense/cubit/update_expense_category_cubit.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/shared_widgets/buttons/primary/primary.dart';
import 'package:leadership/shared_widgets/input/form_field_label/form_field_label.dart';
import 'package:leadership/shared_widgets/input/text/text.dart';
import 'package:leadership/shared_widgets/input/text_area/text_area.dart';

class EditExpenseCategoryHandsetView extends StatefulWidget {
  const EditExpenseCategoryHandsetView({
    required this.category,
    required this.onExpenseCategoryUpdated,
    super.key,
  });

  final PRFExpenseCategory category;
  final VoidCallback onExpenseCategoryUpdated;

  @override
  State<EditExpenseCategoryHandsetView> createState() =>
      _EditExpenseCategoryHandsetViewState();
}

class _EditExpenseCategoryHandsetViewState
    extends State<EditExpenseCategoryHandsetView> {
  late TextEditingController _descriptionController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);

    _descriptionController = TextEditingController(
      text: widget.category.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();

    _descriptionController.dispose();

    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('Please fill in all required fields');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _submitForm() {
    if (!_validateForm()) return;

    context.read<UpdateExpenseCategoryCubit>().updateExpenseCategory(
      ulid: widget.category.ulid,
      name: _nameController.text.trim(),

      description: _descriptionController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<UpdateExpenseCategoryCubit, UpdateExpenseCategoryState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (updatedExpenseCategory) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Expense Category updated successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onExpenseCategoryUpdated();
          },
          error: (message) {
            _showErrorSnackBar(message);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.05),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderCard(theme),
                  const SizedBox(height: 24),
                  _buildFormCard(theme, isLoading),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Edit Expense Category',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Update the description below to keep records current',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            icon: Icons.school_outlined,
            title: 'Expense Category Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Expense Category Name'),
                PRFTextInput(
                  hintText: 'Enter expense category name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          _buildFormSection(
            icon: Icons.description_outlined,
            title: 'Description',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Description'),
                PRFTextAreaInput(
                  hintText: 'Enter description ',
                  controller: _descriptionController,
                  enabled: !isLoading,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: PRFPrimaryButton(
              onPressed: _submitForm,
              title: 'Update Expense Category',
              disabled: isLoading,
              isLoading: isLoading,
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
                  color: Theme.of(context).colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
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
}
