import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/landing/churches/actions/church_form/_handset.dart';
import 'package:leadership/features/home/landing/churches/cubit/church_resource_cubit.dart';
import 'package:leadership/features/home/landing/departments/actions/department_form/_handset.dart';
import 'package:leadership/features/home/landing/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/features/home/landing/gifts/actions/gift_form/_handset.dart';
import 'package:leadership/features/home/landing/gifts/cubit/gift_resource_cubit.dart';
import 'package:leadership/features/home/landing/marital_statuses/actions/marital_status_form/_handset.dart';
import 'package:leadership/features/home/landing/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/features/home/landing/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/home/landing/professions/actions/profession_form/_handset.dart';
import 'package:leadership/features/home/landing/professions/cubit/profession_resource_cubit.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_member_create_dto.dart';
import 'package:leadership/models/remote/prf_member_update_dto.dart';
import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:prf_design/prf_design.dart';

class MemberFormViewHandset extends StatefulWidget {
  const MemberFormViewHandset({
    required this.onSaved,
    this.member,
    super.key,
  });

  final PRFMember? member;
  final VoidCallback onSaved;

  @override
  State<MemberFormViewHandset> createState() => _MemberFormViewHandsetState();
}

class _MemberFormViewHandsetState extends State<MemberFormViewHandset> {
  // Personal
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final PhoneController _phoneNumberController;
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

  // Single ULID selections
  String? _selectedChurchUlid;
  String? _selectedProfessionUlid;
  String? _selectedMaritalStatusUlid;

  // Multi ULID selections
  List<String> _selectedDepartmentUlids = [];
  List<String> _selectedGiftUlids = [];

  // Demographics
  int? _selectedGender;

  String? _firstNameError;
  String? _lastNameError;
  String? _personalEmailError;

  bool _showValidation = false;

  bool get _isEditing => widget.member != null;

  bool get _isFormValid {
    final hasName =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty;
    if (!_isEditing) {
      return hasName && _personalEmailController.text.trim().isNotEmpty;
    }
    return hasName;
  }

  @override
  void initState() {
    super.initState();
    final member = widget.member;

    // Personal
    _firstNameController = TextEditingController(text: member?.firstName ?? '');
    _lastNameController = TextEditingController(text: member?.lastName ?? '');
    _phoneNumberController = PhoneController(
      initialValue: member != null && member.phoneNumber != null
          ? PhoneNumber.parse(
              member.phoneNumber!,
            )
          : const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
    );
    _personalEmailController = TextEditingController(
      text: member?.email ?? '',
    );
    _postalAddressController = TextEditingController(
      text: member?.postalAddress ?? '',
    );
    _residenceController = TextEditingController(
      text: member?.residence ?? '',
    );
    _bioController = TextEditingController(text: member?.bio ?? '');
    _linkedInUrlController = TextEditingController(
      text: member?.linkedInUrl ?? '',
    );

    // Spiritual
    _yearOfSalvationController = TextEditingController(
      text: member?.yearOfSalvation?.toString() ?? '',
    );
    _churchVolunteer = member?.churchVolunteer ?? false;
    _pastorController = TextEditingController(text: member?.pastor ?? '');

    // Professional
    _professionInstitutionController = TextEditingController(
      text: member?.professionInstitution ?? '',
    );
    _professionLocationController = TextEditingController(
      text: member?.professionLocation ?? '',
    );
    _professionContactController = TextEditingController(
      text: member?.professionContact ?? '',
    );

    // Single ULID selections
    _selectedChurchUlid = member?.church?.ulid;
    _selectedProfessionUlid = member?.profession?.ulid;
    _selectedMaritalStatusUlid = member?.maritalStatus?.ulid;

    // Multi ULID selections
    _selectedDepartmentUlids =
        member?.departments.map((d) => d.ulid).toList() ?? [];
    _selectedGiftUlids = member?.gifts.map((g) => g.ulid).toList() ?? [];

    // Demographics
    _selectedGender = member?.gender;

    _firstNameController.addListener(_onFormChanged);
    _lastNameController.addListener(_onFormChanged);
    if (!_isEditing) {
      _personalEmailController.addListener(_onFormChanged);
    }

    // Load entity lists for selection
    context.read<ChurchResourceCubit>().loadAll(
      orderBy: 'name',
      orderDirection: 'asc',
    );
    context.read<ProfessionResourceCubit>().loadAll(
      orderBy: 'name',
      orderDirection: 'asc',
    );
    context.read<MaritalStatusResourceCubit>().loadAll(
      orderBy: 'name',
      orderDirection: 'asc',
    );
    context.read<DepartmentResourceCubit>().loadAll(
      orderBy: 'name',
      orderDirection: 'asc',
    );
    context.read<GiftResourceCubit>().loadAll(
      orderBy: 'name',
      orderDirection: 'asc',
    );
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
    _personalEmailError = null;
  }

  bool _validateForm() {
    _clearErrors();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _personalEmailController.text.trim();

    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
    }
    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
    }
    if (!_isEditing && email.isEmpty) {
      _personalEmailError = 'Email is required';
    }

    setState(() {
      _showValidation = true;
    });

    return [
      _firstNameError,
      _lastNameError,
      _personalEmailError,
    ].every((error) => error == null);
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
    final departmentUlids = _selectedDepartmentUlids.isNotEmpty
        ? _selectedDepartmentUlids
        : null;
    final giftUlids = _selectedGiftUlids.isNotEmpty ? _selectedGiftUlids : null;

    final cubit = context.read<MemberResourceCubit>();

    if (_isEditing) {
      cubit.updateMember(
        ulid: widget.member!.ulid,
        dto: PRFMemberUpdateDTO(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneNumberController.value.international,
          personalEmail: _personalEmailController.text.trim(),
          postalAddress: _postalAddressController.text.trim(),
          residence: _residenceController.text.trim(),
          bio: _bioController.text.trim(),
          linkedInUrl: _linkedInUrlController.text.trim(),
          yearOfSalvation: yearOfSalvation,
          churchVolunteer: _churchVolunteer,
          pastor: _pastorController.text.trim(),
          churchUlid: _selectedChurchUlid,
          professionUlid: _selectedProfessionUlid,
          professionInstitution: _professionInstitutionController.text.trim(),
          professionLocation: _professionLocationController.text.trim(),
          professionContact: _professionContactController.text.trim(),
          gender: _selectedGender,
          maritalStatusUlid: _selectedMaritalStatusUlid,
          departmentUlids: departmentUlids,
          giftUlids: giftUlids,
        ),
      );
    } else {
      cubit.createMember(
        dto: PRFMemberCreateDTO(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          personalEmail: _personalEmailController.text.trim(),
          phoneNumber: _phoneNumberController.value.international,
          postalAddress: _postalAddressController.text.trim(),
          residence: _residenceController.text.trim(),
          bio: _bioController.text.trim(),
          linkedInUrl: _linkedInUrlController.text.trim(),
          yearOfSalvation: yearOfSalvation,
          churchVolunteer: _churchVolunteer,
          pastor: _pastorController.text.trim(),
          churchUlid: _selectedChurchUlid,
          professionUlid: _selectedProfessionUlid,
          professionInstitution: _professionInstitutionController.text.trim(),
          professionLocation: _professionLocationController.text.trim(),
          professionContact: _professionContactController.text.trim(),
          gender: _selectedGender,
          maritalStatusUlid: _selectedMaritalStatusUlid,
          departmentUlids: departmentUlids,
          giftUlids: giftUlids,
        ),
      );
    }
  }

  // --- "Add New" bottom sheet methods ---

  Future<void> _promptAddChurch() async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Add Church',
      child: ChurchFormViewHandset(
        onSaved: () {
          context.read<ChurchResourceCubit>().loadAll(
            orderBy: 'name',
            orderDirection: 'asc',
          );
        },
      ),
    );
  }

  Future<void> _promptAddProfession() async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Add Profession',
      child: ProfessionFormViewHandset(
        onSaved: () {
          context.read<ProfessionResourceCubit>().loadAll(
            orderBy: 'name',
            orderDirection: 'asc',
          );
        },
      ),
    );
  }

  Future<void> _promptAddMaritalStatus() async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Add Marital Status',
      child: MaritalStatusFormViewHandset(
        onSaved: () {
          context.read<MaritalStatusResourceCubit>().loadAll(
            orderBy: 'name',
            orderDirection: 'asc',
          );
        },
      ),
    );
  }

  Future<void> _promptAddDepartment() async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Add Department',
      child: DepartmentFormViewHandset(
        onSaved: () {
          context.read<DepartmentResourceCubit>().loadAll(
            orderBy: 'name',
            orderDirection: 'asc',
          );
        },
      ),
    );
  }

  Future<void> _promptAddGift() async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Add Gift',
      child: GiftFormViewHandset(
        onSaved: () {
          context.read<GiftResourceCubit>().loadAll(
            orderBy: 'name',
            orderDirection: 'asc',
          );
        },
      ),
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
            if (operation == ResourceOperation.update ||
                operation == ResourceOperation.create) {
              Gaimon.success();
              Navigator.pop(context);
              PRFSnackbar.success(
                context,
                _isEditing
                    ? 'Member updated successfully'
                    : 'Member created successfully',
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
                              _buildRelationshipsSection(),
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
                        title: _isEditing ? 'Update Member' : 'Create Member',
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
            _isEditing ? Icons.edit_outlined : Icons.person_add_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? 'Edit Member' : 'Add Member',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? 'Update member profile information'
                : 'Register a new member',
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
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFPhoneInput(
            hintText: 'Phone number',

            controller: _phoneNumberController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.email_outlined,
          title: 'Email',
          isRequired: !_isEditing,
          subtitle: _isEditing ? 'Optional' : 'Required',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Email address',
            labelText: _isEditing ? 'Email' : 'Email *',
            helperText: _isEditing ? 'Optional' : 'Required',
            errorText: _showValidation ? _personalEmailError : null,
            controller: _personalEmailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_showValidation && !_isEditing) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.location_on_outlined,
          title: 'Postal Address',

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

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Pastor name',
            labelText: 'Pastor',
            helperText: 'Optional',
            controller: _pastorController,
            enabled: !isLoading,
          ),
        ),
        _buildChurchSelection(),
      ],
    );
  }

  Widget _buildProfessionalSection(bool isLoading) {
    return Column(
      children: [
        _buildProfessionSelection(),
        PRFFormSection(
          icon: Icons.business_outlined,
          title: 'Institution',

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

          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              helperText: 'Optional',
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Male')),
              DropdownMenuItem(value: 2, child: Text('Female')),
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
        _buildMaritalStatusSelection(),
      ],
    );
  }

  Widget _buildRelationshipsSection() {
    return Column(
      children: [
        _buildDepartmentSelection(),
        _buildGiftSelection(),
      ],
    );
  }

  // --- Searchable selection widgets ---

  Widget _buildChurchSelection() {
    return BlocBuilder<ChurchResourceCubit, ResourceState<PRFChurch>>(
      builder: (context, state) {
        final churches = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, item) => items,
          error: (message, items) => items,
          orElse: () => <PRFChurch>[],
        );

        return PRFFormSection(
          icon: Icons.church_outlined,
          title: 'Church',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFSearchableList<String>(
                entries: churches
                    .map(
                      (c) => PRFSearchableListEntry<String>(
                        value: c.ulid,
                        label: c.name,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedChurchUlid = value;
                  });
                },
                selection: _selectedChurchUlid,
                hintText: 'Search church',
                emptyText: 'No churches found',
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: 'Add Church',
                onTap: _promptAddChurch,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionSelection() {
    return BlocBuilder<ProfessionResourceCubit, ResourceState<PRFProfession>>(
      builder: (context, state) {
        final professions = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, item) => items,
          error: (message, items) => items,
          orElse: () => <PRFProfession>[],
        );

        return PRFFormSection(
          icon: Icons.work_outlined,
          title: 'Profession',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFSearchableList<String>(
                entries: professions
                    .map(
                      (p) => PRFSearchableListEntry<String>(
                        value: p.ulid,
                        label: p.name,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedProfessionUlid = value;
                  });
                },
                selection: _selectedProfessionUlid,
                hintText: 'Search profession',
                emptyText: 'No professions found',
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: 'Add Profession',
                onTap: _promptAddProfession,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaritalStatusSelection() {
    return BlocBuilder<
      MaritalStatusResourceCubit,
      ResourceState<PRFMaritalStatus>
    >(
      builder: (context, state) {
        final statuses = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, item) => items,
          error: (message, items) => items,
          orElse: () => <PRFMaritalStatus>[],
        );

        return PRFFormSection(
          icon: Icons.favorite_outlined,
          title: 'Marital Status',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFSearchableList<String>(
                entries: statuses
                    .map(
                      (ms) => PRFSearchableListEntry<String>(
                        value: ms.ulid,
                        label: ms.name,
                      ),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedMaritalStatusUlid = value;
                  });
                },
                selection: _selectedMaritalStatusUlid,
                hintText: 'Search marital status',
                emptyText: 'No marital statuses found',
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: 'Add Marital Status',
                onTap: _promptAddMaritalStatus,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentSelection() {
    return BlocBuilder<DepartmentResourceCubit, ResourceState<PRFDepartment>>(
      builder: (context, state) {
        final departments = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, item) => items,
          error: (message, items) => items,
          orElse: () => <PRFDepartment>[],
        );

        return PRFFormSection(
          icon: Icons.groups_outlined,
          title: 'Departments',
          subtitle: 'Optional — select multiple',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFSearchableList<String>(
                entries: departments
                    .map(
                      (d) => PRFSearchableListEntry<String>(
                        value: d.ulid,
                        label: d.name,
                      ),
                    )
                    .toList(),
                selections: _selectedDepartmentUlids,
                onSelected: (value) {
                  if (value == null) return;
                  setState(() {
                    if (_selectedDepartmentUlids.contains(value)) {
                      _selectedDepartmentUlids.remove(value);
                    } else {
                      _selectedDepartmentUlids.add(value);
                    }
                  });
                },
                hintText: 'Search department',
                emptyText: 'No departments found',
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: 'Add Department',
                onTap: _promptAddDepartment,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftSelection() {
    return BlocBuilder<GiftResourceCubit, ResourceState<PRFGift>>(
      builder: (context, state) {
        final gifts = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, item) => items,
          error: (message, items) => items,
          orElse: () => <PRFGift>[],
        );

        return PRFFormSection(
          icon: Icons.card_giftcard_outlined,
          title: 'Gifts',
          subtitle: 'Optional — select multiple',
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFSearchableList<String>(
                entries: gifts
                    .map(
                      (g) => PRFSearchableListEntry<String>(
                        value: g.ulid,
                        label: g.name,
                      ),
                    )
                    .toList(),
                selections: _selectedGiftUlids,
                onSelected: (value) {
                  if (value == null) return;
                  setState(() {
                    if (_selectedGiftUlids.contains(value)) {
                      _selectedGiftUlids.remove(value);
                    } else {
                      _selectedGiftUlids.add(value);
                    }
                  });
                },
                hintText: 'Search gift',
                emptyText: 'No gifts found',
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: 'Add Gift',
                onTap: _promptAddGift,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddNewButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: PRFSpacingTokens.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
