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

  String? _nameError;
  String? _studentsError;
  String? _addressError;
  String? _institutionTypeError;
  String? _latitudeError;
  String? _longitudeError;

  bool _showValidation = false;

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

  void _clearErrors() {
    _nameError = null;
    _studentsError = null;
    _addressError = null;
    _institutionTypeError = null;
    _latitudeError = null;
    _longitudeError = null;
  }

  bool _validateForm() {
    _clearErrors();

    final name = _nameController.text.trim();
    final studentsText = _studentsController.text.trim();
    final address = _addressController.text.trim();
    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    if (name.isEmpty) {
      _nameError = 'School name is required';
    }

    final students = int.tryParse(studentsText);
    if (studentsText.isEmpty) {
      _studentsError = 'Total students is required';
    } else if (students == null || students < 1) {
      _studentsError = 'Enter a valid student count';
    }

    if (address.isEmpty) {
      _addressError = 'Address is required';
    }

    if (_selectedInstitutionType.name.isEmpty) {
      _institutionTypeError = 'Institution type is required';
    }

    final latitude = double.tryParse(latitudeText);
    if (latitude == null || latitude < -90 || latitude > 90) {
      _latitudeError = 'Latitude must be between -90 and 90';
    }

    final longitude = double.tryParse(longitudeText);
    if (longitude == null || longitude < -180 || longitude > 180) {
      _longitudeError = 'Longitude must be between -180 and 180';
    }

    setState(() {
      _showValidation = true;
    });

    return [
      _nameError,
      _studentsError,
      _addressError,
      _institutionTypeError,
      _latitudeError,
      _longitudeError,
    ].every((error) => error == null);
  }

  void _submitForm() {
    if (!_validateForm()) {
      PRFSnackbar.error(
        context,
        'Please fix the highlighted fields and try again.',
      );
      return;
    }

    final students = int.parse(_studentsController.text.trim());
    final latitude = double.parse(_latitudeController.text.trim());
    final longitude = double.parse(_longitudeController.text.trim());
    final cubit = context.read<SchoolCubit>();

    if (_isEditing) {
      cubit.updateSchool(
        ulid: widget.school!.ulid,
        name: _nameController.text.trim(),
        totalStudents: students,
        institutionType: _selectedInstitutionType,
        address: _addressController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        description: _descriptionController.text.trim(),
        directions: _directionsController.text.trim(),
      );
      return;
    }

    cubit.createSchool(
      name: _nameController.text.trim(),
      totalStudents: students,
      institutionType: _selectedInstitutionType,
      address: _addressController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      description: _descriptionController.text.trim(),
      directions: _directionsController.text.trim(),
    );
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
              PRFSnackbar.success(
                context,
                _isEditing
                    ? 'School updated successfully'
                    : 'School created successfully',
              );
              widget.onSaved();
            }
          case ResourceError<PRFSchool>(:final message):
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFSchool> ||
          curr is ResourceError<PRFSchool>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFSchool>;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: PRFSpacingTokens.xl),
                  _buildAvatar(),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  _buildIdentitySection(theme, isLoading),
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildLocationSection(theme, isLoading),
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildDetailsSection(isLoading),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: PRFPrimaryButton(
                      onPressed: _submitForm,
                      title: _isEditing ? 'Update School' : 'Create School',
                      disabled: isLoading,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    final school = widget.school;
    final hasInitials = _isEditing && (school?.name.isNotEmpty ?? false);

    return Center(
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _selectedInstitutionType.gradientColors,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33090B1F),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: hasInitials
              ? Text(
                  _getInitials(school!.name),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(
                  _isEditing ? Icons.edit_rounded : Icons.school_rounded,
                  color: Colors.white,
                  size: 26,
                ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Widget _buildIdentitySection(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.school_outlined,
          title: 'School Name',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'School name',
            labelText: 'School Name *',
            helperText: 'Required',
            errorText: _showValidation ? _nameError : null,
            controller: _nameController,
            enabled: !isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.category_outlined,
          title: 'Institution Type',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: DropdownButtonFormField<PRFInstitutionType>(
            initialValue: _selectedInstitutionType,
            decoration: InputDecoration(
              labelText: 'Institution Type *',
              helperText: 'Required',
              errorText: _showValidation ? _institutionTypeError : null,
            ),
            items: PRFInstitutionType.values
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
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedInstitutionType = value;
                      _institutionTypeError = null;
                    });
                  },
          ),
        ),
        PRFFormSection(
          icon: Icons.groups_outlined,
          title: 'Total Students',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFNumberInput(
            hintText: '0',
            labelText: 'Total Students *',
            helperText: 'Required',
            errorText: _showValidation ? _studentsError : null,
            controller: _studentsController,
            enabled: !isLoading,
            isLoading: isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.location_on_outlined,
          title: 'Address',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextAreaInput(
            hintText: 'Address',
            labelText: 'Address *',
            helperText: 'Required',
            errorText: _showValidation ? _addressError : null,
            controller: _addressController,
            enabled: !isLoading,
            minLines: 2,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme, bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.explore_rounded,
          title: 'Map Location',
          subtitle: 'Tap on the map to set exact coordinates',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: LocationPicker(
            initialLatitude: double.tryParse(_latitudeController.text),
            initialLongitude: double.tryParse(_longitudeController.text),
            onLocationSelected: (lat, lon) {
              setState(() {
                _latitudeController.text = lat.toString();
                _longitudeController.text = lon.toString();
                _latitudeError = null;
                _longitudeError = null;
              });
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.pin_drop_outlined,
          title: 'Latitude',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: '0.000000',
            labelText: 'Latitude *',
            helperText: 'Required',
            errorText: _showValidation ? _latitudeError : null,
            controller: _latitudeController,
            readOnly: true,
            enabled: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        PRFFormSection(
          icon: Icons.pin_drop_outlined,
          title: 'Longitude',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: '0.000000',
            labelText: 'Longitude *',
            helperText: 'Required',
            errorText: _showValidation ? _longitudeError : null,
            controller: _longitudeController,
            readOnly: true,
            enabled: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.route_outlined,
          title: 'Directions',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextAreaInput(
            hintText: 'Directions',
            labelText: 'Directions',
            helperText: 'Optional',
            controller: _directionsController,
            enabled: !isLoading,
            minLines: 2,
            maxLines: 4,
          ),
        ),
        PRFFormSection(
          icon: Icons.description_outlined,
          title: 'Description',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextAreaInput(
            hintText: 'Description',
            labelText: 'Description',
            helperText: 'Optional',
            controller: _descriptionController,
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }
}
