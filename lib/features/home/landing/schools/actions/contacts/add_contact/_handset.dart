import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/_index.dart';

class AddContactViewHandset extends StatefulWidget {
  const AddContactViewHandset({
    required this.contactTypes,
    required this.onContactCreated,
    super.key,
  });

  final List<PRFContactType> contactTypes;
  final VoidCallback onContactCreated;

  @override
  State<AddContactViewHandset> createState() => _AddContactViewHandsetState();
}

class _AddContactViewHandsetState extends State<AddContactViewHandset> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
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
    final phone = _phoneController.text.trim();

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
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      contactTypeUlid: _selectedContactType!.ulid,
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
                  title: 'Add Contact',
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
