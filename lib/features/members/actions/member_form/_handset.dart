import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/churches/actions/church_form/_handset.dart';
import 'package:leadership/features/churches/cubit/church_resource_cubit.dart';
import 'package:leadership/features/departments/actions/department_form/_handset.dart';
import 'package:leadership/features/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/features/gifts/actions/gift_form/_handset.dart';
import 'package:leadership/features/gifts/cubit/gift_resource_cubit.dart';
import 'package:leadership/features/marital_statuses/actions/marital_status_form/_handset.dart';
import 'package:leadership/features/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/professions/actions/profession_form/_handset.dart';
import 'package:leadership/features/professions/cubit/profession_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
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
  const MemberFormViewHandset({required this.onSaved, this.member, super.key});

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
          ? PhoneNumber.parse(member.phoneNumber!)
          : const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
    );
    _personalEmailController = TextEditingController(text: member?.email ?? '');
    _postalAddressController = TextEditingController(
      text: member?.postalAddress ?? '',
    );
    _residenceController = TextEditingController(text: member?.residence ?? '');
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
    context.read<ChurchResourceCubit>().loadAll(sortBy: 'name');
    context.read<ProfessionResourceCubit>().loadAll(sortBy: 'name');
    context.read<MaritalStatusResourceCubit>().loadAll(sortBy: 'name');
    context.read<DepartmentResourceCubit>().loadAll(sortBy: 'name');
    context.read<GiftResourceCubit>().loadAll(sortBy: 'name');
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
      _firstNameError = context.l10n.membersFirstNameRequired;
    }
    if (lastName.isEmpty) {
      _lastNameError = context.l10n.membersLastNameRequired;
    }
    if (!_isEditing && email.isEmpty) {
      _personalEmailError = context.l10n.membersEmailRequired;
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
      PRFSnackbar.error(context, context.l10n.commonFixHighlightedFields);
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
      title: context.l10n.membersAddChurch,
      child: ChurchFormViewHandset(
        onSaved: () {
          context.read<ChurchResourceCubit>().loadAll(sortBy: 'name');
        },
      ),
    );
  }

  Future<void> _promptAddProfession() async {
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.membersAddProfession,
      child: ProfessionFormViewHandset(
        onSaved: () {
          context.read<ProfessionResourceCubit>().loadAll(sortBy: 'name');
        },
      ),
    );
  }

  Future<void> _promptAddMaritalStatus() async {
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.membersAddMaritalStatus,
      child: MaritalStatusFormViewHandset(
        onSaved: () {
          context.read<MaritalStatusResourceCubit>().loadAll(sortBy: 'name');
        },
      ),
    );
  }

  Future<void> _promptAddDepartment() async {
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.membersAddDepartment,
      child: DepartmentFormViewHandset(
        onSaved: () {
          context.read<DepartmentResourceCubit>().loadAll(sortBy: 'name');
        },
      ),
    );
  }

  Future<void> _promptAddGift() async {
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.membersAddGift,
      child: GiftFormViewHandset(
        onSaved: () {
          context.read<GiftResourceCubit>().loadAll(sortBy: 'name');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberResourceCubit, ResourceState<PRFMember>>(
      listenWhen: (prev, curr) =>
          (prev is ResourceMutating<PRFMember> &&
              curr is ResourceListLoaded<PRFMember>) ||
          curr is ResourceError<PRFMember>,
      listener: (context, state) {
        switch (state) {
          case ResourceListLoaded<PRFMember>():
            Gaimon.success();
            Navigator.pop(context);
            PRFSnackbar.success(
              context,
              _isEditing
                  ? context.l10n.membersUpdated
                  : context.l10n.membersCreated,
            );
            widget.onSaved();
          case ResourceError<PRFMember>():
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.commonSaveErrorMessage);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFMember> ||
          curr is ResourceError<PRFMember>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFMember>;
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final enter = PRFMotionTokens.resolve(
          context,
          PRFMotionTokens.enterShort,
        );

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.faint,
                  ),
                  theme.colorScheme.surface,
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
                        .slideY(begin: -0.3, duration: enter)
                        .fadeIn(duration: enter),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: PRFOpacities.muted,
                              ),
                            ),
                            boxShadow: PRFShadowTokens.card(
                              theme.colorScheme.shadow,
                            ),
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
                        .animate(
                          delay: PRFMotionTokens.resolve(
                            context,
                            PRFMotionTokens.stagger3,
                          ),
                        )
                        .slideX(begin: -0.2, duration: enter)
                        .fadeIn(duration: enter),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: PRFButton(
                        onPressed: _submitForm,
                        title: _isEditing
                            ? l10n.membersSave
                            : l10n.membersCreate,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.raised(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            _isEditing ? Icons.edit_outlined : Icons.person_add_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? context.l10n.membersEdit : context.l10n.membersAdd,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? context.l10n.membersFormEditSubtitle
                : context.l10n.membersFormCreateSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection(bool isLoading) {
    final l10n = context.l10n;
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.person_outline,
          title: l10n.membersFirstName,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersFirstName,
            labelText: l10n.membersFirstName,
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
          title: l10n.membersLastName,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersLastName,
            labelText: l10n.membersLastName,
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
          title: l10n.membersPhone,
          subtitle: l10n.membersOptional,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFPhoneInput(
            hintText: l10n.membersPhone,

            controller: _phoneNumberController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.email_outlined,
          title: l10n.email,
          isRequired: !_isEditing,
          subtitle: _isEditing ? l10n.membersOptional : null,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersEmailHint,
            labelText: l10n.email,
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
          title: l10n.membersPostalAddress,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersPostalAddress,
            labelText: l10n.membersPostalAddress,
            helperText: l10n.membersOptional,
            controller: _postalAddressController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.home_outlined,
          title: l10n.membersResidence,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersResidence,
            labelText: l10n.membersResidence,
            helperText: l10n.membersOptional,
            controller: _residenceController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.notes_outlined,
          title: l10n.membersBio,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersBioHint,
            labelText: l10n.membersBio,
            helperText: l10n.membersOptional,
            controller: _bioController,
            type: PRFTextFieldType.textArea,
            enabled: !isLoading,
            minLines: 3,
            maxLines: 6,
          ),
        ),
        PRFFormSection(
          icon: Icons.link_outlined,
          title: l10n.membersLinkedIn,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersLinkedInHint,
            labelText: l10n.membersLinkedIn,
            helperText: l10n.membersOptional,
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
    final l10n = context.l10n;

    return Column(
      children: [
        PRFFormSection(
          icon: Icons.calendar_today_outlined,
          title: l10n.membersYearOfSalvation,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersYearHint,
            labelText: l10n.membersYearOfSalvation,
            helperText: l10n.membersOptional,
            controller: _yearOfSalvationController,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
          ),
        ),
        PRFFormSection(
          icon: Icons.volunteer_activism_outlined,
          title: l10n.membersChurchVolunteer,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: SwitchListTile(
            title: Text(
              _churchVolunteer ? l10n.yes : l10n.no,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _churchVolunteer,
            contentPadding: EdgeInsets.zero,
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() {
                      _churchVolunteer = value;
                    });
                  },
          ),
        ),
        PRFFormSection(
          icon: Icons.person_pin_outlined,
          title: l10n.membersPastor,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersPastorHint,
            labelText: l10n.membersPastor,
            helperText: l10n.membersOptional,
            controller: _pastorController,
            enabled: !isLoading,
          ),
        ),
        _buildChurchSelection(),
      ],
    );
  }

  Widget _buildProfessionalSection(bool isLoading) {
    final l10n = context.l10n;
    return Column(
      children: [
        _buildProfessionSelection(),
        PRFFormSection(
          icon: Icons.business_outlined,
          title: l10n.membersInstitution,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersInstitutionHint,
            labelText: l10n.membersInstitution,
            helperText: l10n.membersOptional,
            controller: _professionInstitutionController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.location_city_outlined,
          title: l10n.membersLocation,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersLocationHint,
            labelText: l10n.membersLocation,
            helperText: l10n.membersOptional,
            controller: _professionLocationController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.contact_phone_outlined,
          title: l10n.membersContact,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.membersContactHint,
            labelText: l10n.membersContact,
            helperText: l10n.membersOptional,
            controller: _professionContactController,
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsSection(bool isLoading) {
    final l10n = context.l10n;
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.wc_outlined,
          title: l10n.membersGender,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedGender,
            decoration: InputDecoration(
              labelText: l10n.membersGender,
              helperText: l10n.membersOptional,
            ),
            items: [
              DropdownMenuItem(value: 1, child: Text(l10n.membersMale)),
              DropdownMenuItem(value: 2, child: Text(l10n.membersFemale)),
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
      children: [_buildDepartmentSelection(), _buildGiftSelection()],
    );
  }

  // --- Searchable selection widgets ---

  Widget _buildChurchSelection() {
    return BlocBuilder<ChurchResourceCubit, ResourceState<PRFChurch>>(
      builder: (context, state) {
        final churches = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          error: (message, items) => items,
          orElse: () => <PRFChurch>[],
        );

        return PRFFormSection(
          icon: Icons.church_outlined,
          title: context.l10n.membersChurch,
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
                hintText: context.l10n.membersSearchChurch,
                emptyText: context.l10n.membersNoChurches,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: context.l10n.membersAddChurch,
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
          error: (message, items) => items,
          orElse: () => <PRFProfession>[],
        );

        return PRFFormSection(
          icon: Icons.work_outlined,
          title: context.l10n.membersProfession,
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
                hintText: context.l10n.membersSearchProfession,
                emptyText: context.l10n.membersNoProfessions,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: context.l10n.membersAddProfession,
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
          error: (message, items) => items,
          orElse: () => <PRFMaritalStatus>[],
        );

        return PRFFormSection(
          icon: Icons.favorite_outlined,
          title: context.l10n.membersMaritalStatus,
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
                hintText: context.l10n.membersSearchMaritalStatus,
                emptyText: context.l10n.membersNoMaritalStatuses,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: context.l10n.membersAddMaritalStatus,
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
          error: (message, items) => items,
          orElse: () => <PRFDepartment>[],
        );

        return PRFFormSection(
          icon: Icons.groups_outlined,
          title: context.l10n.membersSectionDepartments,
          subtitle: context.l10n.membersSelectMultiple,
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
                hintText: context.l10n.membersSearchDepartment,
                emptyText: context.l10n.membersNoDepartments,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: context.l10n.membersAddDepartment,
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
          error: (message, items) => items,
          orElse: () => <PRFGift>[],
        );

        return PRFFormSection(
          icon: Icons.card_giftcard_outlined,
          title: context.l10n.membersSectionGifts,
          subtitle: context.l10n.membersSelectMultiple,
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
                hintText: context.l10n.membersSearchGift,
                emptyText: context.l10n.membersNoGifts,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildAddNewButton(
                label: context.l10n.membersAddGift,
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
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PRFSizeTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: PRFSizeTokens.iconMd,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: PRFSpacingTokens.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
