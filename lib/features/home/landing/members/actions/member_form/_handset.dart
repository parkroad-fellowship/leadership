import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/landing/members/cubit/member_resource_cubit.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class MemberFormViewHandset extends StatefulWidget {
  const MemberFormViewHandset({
    required this.member,
    required this.onSaved,
    super.key,
  });

  final PRFMember member;
  final VoidCallback onSaved;

  @override
  State<MemberFormViewHandset> createState() => _MemberFormViewHandsetState();
}

class _MemberFormViewHandsetState extends State<MemberFormViewHandset> {
  // Personal
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _personalEmailController;
  late final TextEditingController _postalAddressController;
  late final TextEditingController _residenceController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkedInUrlController;

  // Spiritual
  late final TextEditingController _yearOfSalvationController;
  late bool _churchVolunteer;
  late final TextEditingController _pastorController;

  // Professional
  late final TextEditingController _professionInstitutionController;
  late final TextEditingController _professionLocationController;
  late final TextEditingController _professionContactController;

  // Demographics
  int? _selectedGender;

  String? _firstNameError;
  String? _lastNameError;

  bool _showValidation = false;

  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final member = widget.member;

    // Personal
    _firstNameController = TextEditingController(text: member.firstName);
    _lastNameController = TextEditingController(text: member.lastName);
    _phoneNumberController = TextEditingController(
      text: member.phoneNumber ?? '',
    );
    _personalEmailController = TextEditingController(text: member.email);
    _postalAddressController = TextEditingController(
      text: member.postalAddress ?? '',
    );
    _residenceController = TextEditingController(text: member.residence ?? '');
    _bioController = TextEditingController(text: member.bio ?? '');
    _linkedInUrlController = TextEditingController(
      text: member.linkedInUrl ?? '',
    );

    // Spiritual
    _yearOfSalvationController = TextEditingController(
      text: member.yearOfSalvation?.toString() ?? '',
    );
    _churchVolunteer = member.churchVolunteer;
    _pastorController = TextEditingController(text: member.pastor ?? '');

    // Professional
    _professionInstitutionController = TextEditingController(
      text: member.professionInstitution ?? '',
    );
    _professionLocationController = TextEditingController(
      text: member.professionLocation ?? '',
    );
    _professionContactController = TextEditingController(
      text: member.professionContact ?? '',
    );

    // Demographics
    _selectedGender = member.gender;

    _firstNameController.addListener(_onFormChanged);
    _lastNameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _personalEmailController.dispose();
    _postalAddressController.dispose();
    _residenceController.dispose();
    _bioController.dispose();
    _linkedInUrlController.dispose();
    _yearOfSalvationController.dispose();
    _pastorController.dispose();
    _professionInstitutionController.dispose();
    _professionLocationController.dispose();
    _professionContactController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _firstNameError = null;
    _lastNameError = null;
  }

  bool _validateForm() {
    _clearErrors();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
    }
    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
    }

    setState(() {
      _showValidation = true;
    });

    return [_firstNameError, _lastNameError].every((error) => error == null);
  }

  void _submitForm() {
    if (!_validateForm()) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fix the highlighted fields and try again.',
      );
      return;
    }

    final yearText = _yearOfSalvationController.text.trim();
    final yearOfSalvation = yearText.isNotEmpty ? int.tryParse(yearText) : null;

    context.read<MemberResourceCubit>().updateMember(
      ulid: widget.member.ulid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      personalEmail: _personalEmailController.text.trim(),
      postalAddress: _postalAddressController.text.trim(),
      residence: _residenceController.text.trim(),
      bio: _bioController.text.trim(),
      linkedInUrl: _linkedInUrlController.text.trim(),
      yearOfSalvation: yearOfSalvation,
      churchVolunteer: _churchVolunteer,
      pastor: _pastorController.text.trim(),
      professionInstitution: _professionInstitutionController.text.trim(),
      professionLocation: _professionLocationController.text.trim(),
      professionContact: _professionContactController.text.trim(),
      gender: _selectedGender,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberResourceCubit, ResourceState<PRFMember>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFMember> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFMember>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFMember>(:final operation):
            if (operation == ResourceOperation.update) {
              Gaimon.success();
              Navigator.pop(context);
              PRFSnackbar.success(
                context,
                'Member updated successfully',
              );
              widget.onSaved();
            }
          case ResourceError<PRFMember>(:final message):
            Gaimon.error();
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFMember> ||
          curr is ResourceError<PRFMember>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFMember>;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: PRFSpacingTokens.lg),
                    _buildHeaderCard(context)
                        .animate()
                        .slideY(begin: -0.3)
                        .fadeIn(duration: PRFMotionTokens.enterShort),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildPersonalSection(isLoading),
                              _buildSpiritualSection(isLoading),
                              _buildProfessionalSection(isLoading),
                              _buildDemographicsSection(isLoading),
                            ],
                          ),
                        )
                        .animate(delay: PRFMotionTokens.stagger3)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: 'Update Member',
                        disabled: isLoading || !_isFormValid,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.xxxl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
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
            Icons.edit_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Edit Member',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Update member profile information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection(bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.person_outline,
          title: 'First Name',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'First name',
            labelText: 'First Name *',
            helperText: 'Required',
            errorText: _showValidation ? _firstNameError : null,
            controller: _firstNameController,
            enabled: !isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.person_outline,
          title: 'Last Name',
          isRequired: true,
          subtitle: 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Last name',
            labelText: 'Last Name *',
            helperText: 'Required',
            errorText: _showValidation ? _lastNameError : null,
            controller: _lastNameController,
            enabled: !isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Phone number',
            labelText: 'Phone Number',
            helperText: 'Optional',
            controller: _phoneNumberController,
            enabled: !isLoading,
            keyboardType: TextInputType.phone,
          ),
        ),
        PRFFormSection(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Email address',
            labelText: 'Email',
            helperText: 'Optional',
            controller: _personalEmailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        PRFFormSection(
          icon: Icons.location_on_outlined,
          title: 'Postal Address',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Postal address',
            labelText: 'Postal Address',
            helperText: 'Optional',
            controller: _postalAddressController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.home_outlined,
          title: 'Residence',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Residence',
            labelText: 'Residence',
            helperText: 'Optional',
            controller: _residenceController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.notes_outlined,
          title: 'Bio',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextAreaInput(
            hintText: 'Bio',
            labelText: 'Bio',
            helperText: 'Optional',
            controller: _bioController,
            enabled: !isLoading,
            minLines: 2,
            maxLines: 4,
          ),
        ),
        PRFFormSection(
          icon: Icons.link_outlined,
          title: 'LinkedIn URL',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'LinkedIn URL',
            labelText: 'LinkedIn URL',
            helperText: 'Optional',
            controller: _linkedInUrlController,
            enabled: !isLoading,
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }

  Widget _buildSpiritualSection(bool isLoading) {
    final theme = Theme.of(context);

    return Column(
      children: [
        PRFFormSection(
          icon: Icons.calendar_today_outlined,
          title: 'Year of Salvation',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'e.g. 2010',
            labelText: 'Year of Salvation',
            helperText: 'Optional',
            controller: _yearOfSalvationController,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
          ),
        ),
        PRFFormSection(
          icon: Icons.volunteer_activism_outlined,
          title: 'Church Volunteer',
          subtitle: 'Toggle volunteer status',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _churchVolunteer ? 'Yes' : 'No',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _churchVolunteer,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _churchVolunteer = value;
                        });
                      },
              ),
            ],
          ),
        ),
        PRFFormSection(
          icon: Icons.person_pin_outlined,
          title: 'Pastor',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Pastor name',
            labelText: 'Pastor',
            helperText: 'Optional',
            controller: _pastorController,
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalSection(bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.business_outlined,
          title: 'Institution',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Profession institution',
            labelText: 'Institution',
            helperText: 'Optional',
            controller: _professionInstitutionController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.location_city_outlined,
          title: 'Location',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Profession location',
            labelText: 'Location',
            helperText: 'Optional',
            controller: _professionLocationController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.contact_phone_outlined,
          title: 'Contact',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Profession contact',
            labelText: 'Contact',
            helperText: 'Optional',
            controller: _professionContactController,
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsSection(bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.wc_outlined,
          title: 'Gender',
          subtitle: 'Optional',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              helperText: 'Optional',
            ),
            items: const [
              DropdownMenuItem(
                value: 1,
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Female'),
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
          ),
        ),
      ],
    );
  }
}
