import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class ContactTypeFormViewHandset extends StatefulWidget {
  const ContactTypeFormViewHandset({
    required this.onSaved,
    this.contactType,
    super.key,
  });

  final PRFContactType? contactType;
  final VoidCallback onSaved;

  @override
  State<ContactTypeFormViewHandset> createState() =>
      _ContactTypeFormViewHandsetState();
}

class _ContactTypeFormViewHandsetState
    extends State<ContactTypeFormViewHandset> {
  late final TextEditingController _nameController;

  bool get _isEditing => widget.contactType != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.contactType?.name ?? '',
    );
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

    final cubit = context.read<ContactTypeCubit>();

    if (_isEditing) {
      cubit.updateContactType(
        ulid: widget.contactType!.ulid,
        name: _nameController.text.trim(),
      );
    } else {
      cubit.createContactType(
        name: _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ContactTypeCubit, ResourceState<PRFContactType>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFContactType> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFContactType>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFContactType>(:final operation):
            if (operation == ResourceOperation.create ||
                operation == ResourceOperation.update) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditing
                        ? 'Contact type updated successfully'
                        : 'Contact type created successfully',
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              widget.onSaved();
            }
          case ResourceError<PRFContactType>(:final message):
            _showErrorSnackBar(message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFContactType> ||
          curr is ResourceError<PRFContactType>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFContactType>;

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
            _isEditing ? Icons.edit_note : Icons.contact_page,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? 'Edit Contact Type' : 'Add Contact Type',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? 'Update the contact type name to keep records current'
                : 'Create a new contact type to keep records organized',
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
              title: _isEditing
                  ? 'Update Contact Type'
                  : 'Create Contact Type',
              disabled: isLoading,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
