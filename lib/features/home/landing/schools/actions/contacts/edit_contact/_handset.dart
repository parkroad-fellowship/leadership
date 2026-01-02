import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/update_contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/_index.dart';

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
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late PRFContactType? _selectedContactType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = TextEditingController(text: widget.contact.phone);
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
    final phone = _phoneController.text.trim();

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
      phone: _phoneController.text.trim(),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              PRFTextInput(
                hintText: 'Enter phone number',
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PRFPrimaryButton(
                  onPressed: _submitForm,
                  title: 'Update Contact',
                  disabled: isLoading,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
