import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/update_contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:prf_design/prf_design.dart';

class EditContactTypeViewHandset extends StatefulWidget {
  const EditContactTypeViewHandset({
    required this.contactType,
    required this.onContactTypeUpdated,
    super.key,
  });

  final PRFContactType contactType;
  final VoidCallback onContactTypeUpdated;

  @override
  State<EditContactTypeViewHandset> createState() =>
      _EditContactTypeViewHandsetState();
}

class _EditContactTypeViewHandsetState
    extends State<EditContactTypeViewHandset> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contactType.name);
  }

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

    context.read<UpdateContactTypeCubit>().updateContactType(
      ulid: widget.contactType.ulid,
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UpdateContactTypeCubit, UpdateContactTypeState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (updatedContactType) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contact type updated successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onContactTypeUpdated();
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
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildHeaderCard(theme),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  _buildFormCard(theme, isLoading),
                  const SizedBox(height: PRFSpacingTokens.xxxl),
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
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
            Icons.edit_note,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Edit Contact Type',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Update the contact type name to keep records current',
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
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
          PRFFormSection(
            icon: Icons.contact_mail_outlined,
            title: 'Contact Type Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PRFFormFieldLabel(label: 'Contact Type Name'),
                PRFTextInput(
                  hintText: 'Enter contact type name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          SizedBox(
            width: double.infinity,
            child: PRFPrimaryButton(
              onPressed: _submitForm,
              title: 'Update Contact Type',
              disabled: isLoading,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
