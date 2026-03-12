import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/input/phone/phone.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:prf_design/prf_design.dart';

class AddContactViewHandset extends StatefulWidget {
  const AddContactViewHandset({
    required this.schoolUlid,
    required this.contactTypes,
    required this.onContactCreated,
    super.key,
  });

  final String schoolUlid;
  final List<PRFContactType> contactTypes;
  final VoidCallback onContactCreated;

  @override
  State<AddContactViewHandset> createState() => _AddContactViewHandsetState();
}

class _AddContactViewHandsetState extends State<AddContactViewHandset> {
  final _nameController = TextEditingController();
  final _phoneController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
  );
  final _emailController = TextEditingController();

  PRFContactType? _selectedContactType;

  @override
  void initState() {
    super.initState();
    if (widget.contactTypes.isNotEmpty) {
      _selectedContactType = widget.contactTypes.first;
    }
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

    if (_selectedContactType == null) {
      _showErrorSnackBar('Please select a contact type');
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

    context.read<CreateContactCubit>().createContact(
      name: _nameController.text.trim(),
      phone: _phoneController.value.international,
      email: _emailController.text.trim(),
      contactTypeUlid: _selectedContactType!.ulid,
      schoolUlid: widget.schoolUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CreateContactCubit, CreateContactState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Contact created successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onContactCreated();
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
            Icons.person_add_alt_1,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Add Contact',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Save a person to reach at this school quickly.',
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
            icon: Icons.badge_outlined,
            title: 'Contact Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PRFFormFieldLabel(label: 'Contact Name'),
                PRFTextInput(
                  hintText: 'Enter contact name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Contact Type'),
                DropdownButtonFormField<PRFContactType>(
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
                          if (value != null) {
                            setState(() {
                              _selectedContactType = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Phone Number'),
                PRFPhoneInput(
                  hintText: 'Enter phone number (e.g., 254712345678)',
                  controller: _phoneController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Email Address'),
                PRFTextInput(
                  hintText: 'Enter email address (optional)',
                  controller: _emailController,
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
              title: 'Add Contact',
              disabled: isLoading,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
