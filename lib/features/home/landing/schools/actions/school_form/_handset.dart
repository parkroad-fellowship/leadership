import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class SchoolFormViewHandset extends StatefulWidget {
  const SchoolFormViewHandset({
    required this.onSaved,
    this.school,
    super.key,
  });

  final PRFSchool? school;
  final VoidCallback onSaved;

  @override
  State<SchoolFormViewHandset> createState() => _SchoolFormViewHandsetState();
}

class _SchoolFormViewHandsetState extends State<SchoolFormViewHandset> {
  late final TextEditingController _nameController;
  late final TextEditingController _studentsController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _directionsController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late PRFInstitutionType _selectedInstitutionType;

  bool get _isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    final school = widget.school;
    _nameController = TextEditingController(text: school?.name ?? '');
    _studentsController = TextEditingController(
      text: school?.totalStudents.toString() ?? '',
    );
    _addressController = TextEditingController(text: school?.address ?? '');
    _descriptionController = TextEditingController(
      text: school?.description ?? '',
    );
    _directionsController = TextEditingController(
      text: school?.directions ?? '',
    );
    _latitudeController = TextEditingController(
      text: school?.latitude.toString() ?? '0.0',
    );
    _longitudeController = TextEditingController(
      text: school?.longitude.toString() ?? '0.0',
    );
    _selectedInstitutionType =
        school?.institutionType ?? PRFInstitutionType.primarySchool;
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
    final cubit = context.read<SchoolCubit>();

    if (_isEditing) {
      cubit.updateSchool(
        ulid: widget.school!.ulid,
        name: _nameController.text.trim(),
        totalStudents: students,
        institutionType: _selectedInstitutionType,
        address: _addressController.text.trim(),
        latitude: lat,
        longitude: lon,
        description: _descriptionController.text.trim(),
        directions: _directionsController.text.trim(),
      );
    } else {
      cubit.createSchool(
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SchoolCubit, ResourceState<PRFSchool>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFSchool> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFSchool>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFSchool>(:final operation):
            if (operation == ResourceOperation.create ||
                operation == ResourceOperation.update) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditing
                        ? 'School updated successfully'
                        : 'School created successfully',
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              widget.onSaved();
            }
          case ResourceError<PRFSchool>(:final message):
            _showErrorSnackBar(message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFSchool> ||
          curr is ResourceError<PRFSchool>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFSchool>;

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
            _isEditing ? Icons.edit : Icons.school,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? 'Edit School' : 'Add New School',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? 'Update the details below to keep records current'
                : 'Fill in the details below to create a school record',
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
            icon: Icons.school_outlined,
            title: 'School Details',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PRFFormFieldLabel(label: 'School Name'),
                PRFTextInput(
                  hintText: 'Enter school name',
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Institution Type'),
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
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Total Students'),
                PRFNumberInput(
                  hintText: 'Enter total students',
                  controller: _studentsController,
                ),
              ],
            ),
          ),
          PRFFormSection(
            icon: Icons.place_outlined,
            title: 'Location',
            isRequired: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PRFFormFieldLabel(label: 'Address'),
                PRFTextAreaInput(
                  hintText: 'Enter school address',
                  controller: _addressController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'Directions'),
                PRFTextAreaInput(
                  hintText: 'Enter directions (optional)',
                  controller: _directionsController,
                  enabled: !isLoading,
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                const PRFFormFieldLabel(label: 'GPS Coordinates'),
                const SizedBox(height: PRFSpacingTokens.sm),
                LocationPicker(
                  initialLatitude: double.tryParse(
                    _latitudeController.text,
                  ),
                  initialLongitude: double.tryParse(
                    _longitudeController.text,
                  ),
                  onLocationSelected: (lat, lon) {
                    _latitudeController.text = lat.toString();
                    _longitudeController.text = lon.toString();
                  },
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PRFFormFieldLabel(label: 'Latitude'),
                          PRFTextInput(
                            hintText: '0.0',
                            controller: _latitudeController,
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PRFFormFieldLabel(label: 'Longitude'),
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
          PRFFormSection(
            icon: Icons.description_outlined,
            title: 'Additional Info',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PRFFormFieldLabel(label: 'Description'),
                PRFTextAreaInput(
                  hintText: 'Enter description (optional)',
                  controller: _descriptionController,
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
              title: _isEditing ? 'Update School' : 'Create School',
              disabled: isLoading,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
