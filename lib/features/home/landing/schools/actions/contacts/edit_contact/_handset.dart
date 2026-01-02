import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/update_contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/shared_widgets/input/phone/phone.dart';
import 'package:phone_form_field/phone_form_field.dart';

class EditContactViewHandset extends StatefulWidget {
  const EditContactViewHandset({
    required this.contact,
    required this.contactTypes,
    required this.onContactUpdated,
    super.key,
  });

  final PRFContact contact;
  final List<PRFContactType> contactTypes;
  final VoidCallback onContactUpdated;

  @override
  State<EditContactViewHandset> createState() => _EditContactViewHandsetState();
}

class _EditContactViewHandsetState extends State<EditContactViewHandset> {
  late TextEditingController _nameController;
  late PhoneController _phoneController;
  late TextEditingController _emailController;

  late PRFContactType? _selectedContactType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = _buildPhoneController(widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email ?? '');
    _selectedContactType = widget.contact.contactType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.value.nsn.trim();

    if (name.isEmpty || phone.isEmpty) {
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

    context.read<UpdateContactCubit>().updateContact(
      ulid: widget.contact.ulid,
      name: _nameController.text.trim(),
      phone: _phoneController.value.international,
      email: _emailController.text.trim(),
      contactTypeUlid: _selectedContactType?.ulid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UpdateContactCubit, UpdateContactState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contact updated successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onContactUpdated();
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
            Icons.edit_note,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Edit Contact',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Update this person’s details and save.',
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
            icon: Icons.badge_outlined,
            title: 'Contact Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Contact Name'),
                PRFTextInput(
                  hintText: 'Enter contact name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Contact Type'),
                DropdownButtonFormField<PRFContactType?>(
                  initialValue: _selectedContactType,
                  decoration: const InputDecoration(
                    hintText: 'Select contact type',
                  ),
                  items: widget.contactTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedContactType = value;
                          });
                        },
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Phone Number'),
                PRFPhoneInput(
                  hintText: 'Enter phone number (e.g., 254712345678)',
                  controller: _phoneController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Email Address'),
                PRFTextInput(
                  hintText: 'Enter email address (optional)',
                  controller: _emailController,
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
              title: 'Update Contact',
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

  PhoneController _buildPhoneController(String rawPhone) {
    try {
      final parsed = PhoneNumber.parse(rawPhone);
      return PhoneController(initialValue: parsed);
    } catch (_) {
      return PhoneController(
        initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
      );
    }
  }
}
