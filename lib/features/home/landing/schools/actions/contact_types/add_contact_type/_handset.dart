import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_contact_type_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

class AddContactTypeViewHandset extends StatefulWidget {
  const AddContactTypeViewHandset({
    required this.onContactTypeCreated,
    super.key,
  });

  final VoidCallback onContactTypeCreated;

  @override
  State<AddContactTypeViewHandset> createState() =>
      _AddContactTypeViewHandsetState();
}

class _AddContactTypeViewHandsetState extends State<AddContactTypeViewHandset> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('Please enter a contact type name');
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

    context.read<CreateContactTypeCubit>().createContactType(
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CreateContactTypeCubit, CreateContactTypeState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (newContactType) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contact type created successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onContactTypeCreated();
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            Icons.contact_page,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Contact Type',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a new contact type to keep records organized',
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
            icon: Icons.contact_mail_outlined,
            title: 'Contact Type Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Contact Type Name'),
                PRFTextInput(
                  hintText: 'Enter contact type name',
                  controller: _nameController,
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
              title: 'Create Contact Type',
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
