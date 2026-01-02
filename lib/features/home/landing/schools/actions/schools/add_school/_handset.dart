import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_school_cubit.dart';
import 'package:leadership/shared_widgets/_index.dart';

class AddSchoolViewHandset extends StatefulWidget {
  const AddSchoolViewHandset({
    required this.onSchoolCreated,
    super.key,
  });

  final VoidCallback onSchoolCreated;

  @override
  State<AddSchoolViewHandset> createState() => _AddSchoolViewHandsetState();
}

class _AddSchoolViewHandsetState extends State<AddSchoolViewHandset> {
  final _nameController = TextEditingController();
  final _studentsController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _directionsController = TextEditingController();
  final _latitudeController = TextEditingController(text: '0.0');
  final _longitudeController = TextEditingController(text: '0.0');

  late PRFInstitutionType _selectedInstitutionType;

  @override
  void initState() {
    super.initState();
    _selectedInstitutionType = PRFInstitutionType.primarySchool;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentsController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _directionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final studentsText = _studentsController.text.trim();
    final address = _addressController.text.trim();
    final latText = _latitudeController.text.trim();
    final lonText = _longitudeController.text.trim();

    if (name.isEmpty || studentsText.isEmpty || address.isEmpty) {
      _showErrorSnackBar('Please fill in all required fields');
      return false;
    }

    final students = int.tryParse(studentsText);
    final lat = double.tryParse(latText);
    final lon = double.tryParse(lonText);

    if (students == null || lat == null || lon == null) {
      _showErrorSnackBar('Invalid number format');
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

    final students = int.parse(_studentsController.text.trim());
    final lat = double.parse(_latitudeController.text.trim());
    final lon = double.parse(_longitudeController.text.trim());

    context.read<CreateSchoolCubit>().createSchool(
      name: _nameController.text.trim(),
      totalStudents: students,
      institutionType: _selectedInstitutionType,
      address: _addressController.text.trim(),
      latitude: lat,
      longitude: lon,
      description: _descriptionController.text.trim(),
      directions: _directionsController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CreateSchoolCubit, CreateSchoolState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (newSchool) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('School created successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            widget.onSchoolCreated();
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
            Icons.school,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Add New School',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in the details below to create a school record',
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
            title: 'School Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'School Name'),
                PRFTextInput(
                  hintText: 'Enter school name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Institution Type'),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<PRFInstitutionType>(
                      initialValue: _selectedInstitutionType,
                      decoration: const InputDecoration(
                        hintText: 'Select institution type',
                      ),
                      items: PRFInstitutionType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedInstitutionType = value;
                                });
                              }
                            },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Total Students'),
                PRFNumberInput(
                  hintText: 'Enter total students',
                  controller: _studentsController,
                ),
              ],
            ),
          ),
          _buildFormSection(
            icon: Icons.place_outlined,
            title: 'Location',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Address'),
                PRFTextAreaInput(
                  hintText: 'Enter school address',
                  controller: _addressController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                const FormFieldLabel(label: 'Directions'),
                PRFTextAreaInput(
                  hintText: 'Enter directions (optional)',
                  controller: _directionsController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormFieldLabel(label: 'Latitude'),
                          PRFTextInput(
                            hintText: '0.0',
                            controller: _latitudeController,
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormFieldLabel(label: 'Longitude'),
                          PRFTextInput(
                            hintText: '0.0',
                            controller: _longitudeController,
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildFormSection(
            icon: Icons.description_outlined,
            title: 'Additional Info',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormFieldLabel(label: 'Description'),
                PRFTextAreaInput(
                  hintText: 'Enter description (optional)',
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
              title: 'Create School',
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
