import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_dto.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class CreateMissionViewHandset extends StatefulWidget {
  const CreateMissionViewHandset({super.key});

  @override
  State<CreateMissionViewHandset> createState() =>
      _CreateMissionViewHandsetState();
}

class _CreateMissionViewHandsetState extends State<CreateMissionViewHandset> {
  final _themeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _prepNotesController = TextEditingController();
  final _whatsAppLinkController = TextEditingController();

  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedSchoolTermUlid;
  String? _selectedMissionTypeUlid;
  String? _selectedSchoolUlid;
  String? _schoolTermError;
  String? _missionTypeError;
  String? _schoolError;
  String? _startDateError;
  String? _endDateError;
  String? _startTimeError;
  String? _endTimeError;
  String? _themeError;
  String? _capacityError;
  bool _showValidation = false;

  bool get _isFormValid {
    return (_selectedSchoolTermUlid?.isNotEmpty ?? false) &&
        (_selectedMissionTypeUlid?.isNotEmpty ?? false) &&
        (_selectedSchoolUlid?.isNotEmpty ?? false) &&
        _startDate != null &&
        _endDate != null &&
        _startTimeController.text.trim().isNotEmpty &&
        _endTimeController.text.trim().isNotEmpty &&
        _themeController.text.trim().isNotEmpty &&
        ((int.tryParse(_capacityController.text.trim()) ?? 0) > 0);
  }

  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadAll(orderBy: 'name', orderDirection: 'asc');
    context.read<MissionTypeResourceCubit>().loadActive();
    context.read<SchoolTermResourceCubit>().loadActive();
    _startTimeController.addListener(_onChanged);
    _endTimeController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  void _clearErrors() {
    _schoolTermError = null;
    _missionTypeError = null;
    _schoolError = null;
    _startDateError = null;
    _endDateError = null;
    _startTimeError = null;
    _endTimeError = null;
    _themeError = null;
    _capacityError = null;
  }

  bool _validateForm() {
    _clearErrors();

    if (_selectedSchoolTermUlid?.isEmpty ?? true) {
      _schoolTermError = 'School term is required';
    }
    if (_selectedMissionTypeUlid?.isEmpty ?? true) {
      _missionTypeError = 'Mission type is required';
    }
    if (_selectedSchoolUlid?.isEmpty ?? true) {
      _schoolError = 'School is required';
    }
    if (_startDate == null) {
      _startDateError = 'Start date is required';
    }
    if (_endDate == null) {
      _endDateError = 'End date is required';
    }
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _endDateError = 'End date cannot be before start date';
    }
    if (_startTimeController.text.trim().isEmpty) {
      _startTimeError = 'Start time is required';
    }
    if (_endTimeController.text.trim().isEmpty) {
      _endTimeError = 'End time is required';
    }
    if (_themeController.text.trim().isEmpty) {
      _themeError = 'Theme is required';
    }
    final capacity = int.tryParse(_capacityController.text.trim());
    if (_capacityController.text.trim().isEmpty) {
      _capacityError = 'Capacity is required';
    } else if (capacity == null || capacity < 1) {
      _capacityError = 'Capacity must be at least 1';
    }

    setState(() {
      _showValidation = true;
    });

    return [
      _schoolTermError,
      _missionTypeError,
      _schoolError,
      _startDateError,
      _endDateError,
      _startTimeError,
      _endTimeError,
      _themeError,
      _capacityError,
    ].every((error) => error == null);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _capacityController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _prepNotesController.dispose();
    _whatsAppLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return BlocListener<MissionResourceCubit, ResourceState<PRFMission>>(
      listener: (context, state) {
        switch (state) {
          case ResourceMutating<PRFMission>(:final operation)
              when operation == ResourceOperation.create:
            setState(() => _isLoading = true);
          case ResourceMutated<PRFMission>(:final operation)
              when operation == ResourceOperation.create:
            setState(() => _isLoading = false);
            Gaimon.success();
            Navigator.of(context).pop(true);
            PRFSnackbar.success(context, 'Mission created successfully');
          case ResourceError<PRFMission>(:final message) when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.error();
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PRFSpacingTokens.lg,
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: PRFSpacingTokens.sm),
                  _buildHeader(context),
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildForm(context, l10n),
                  const SizedBox(height: PRFSpacingTokens.lg),
                  PRFPrimaryButton(
                        onPressed: _submit,
                        title: 'Create Mission',
                        disabled: !_isFormValid,
                        isLoading: _isLoading,
                      )
                      .animate(delay: PRFMotionTokens.enterMedium)
                      .slideY(begin: 0.3)
                      .fadeIn(),
                  const SizedBox(height: PRFSpacingTokens.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          ),
          child: Column(
            children: [
              Icon(
                Icons.flight_takeoff_rounded,
                size: 32,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              Text(
                'Create Mission',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xs),
              Text(
                'Fill required mission details to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: -0.3)
        .fadeIn(duration: PRFMotionTokens.enterShort);
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSchoolTermDropdown(),
        _buildMissionTypeDropdown(),
        _buildSchoolDropdown(),
        _buildStartDateField(),
        _buildStartTimeField(),
        _buildEndDateField(),
        _buildEndTimeField(),
        _buildThemeField(l10n),
        _buildCapacityField(),
        _buildWhatsAppField(),
        _buildPreparationNotesField(),
      ],
    );
  }

  Widget _buildStartDateField() {
    return PRFFormSection(
      icon: Icons.event,
      title: 'Start Date',
      isRequired: true,
      subtitle: 'Select mission start date',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextInput(
              hintText: 'YYYY-MM-DD',
              labelText: 'Start Date *',
              helperText: 'Select mission start date',
              errorText: _showValidation ? _startDateError : null,
              controller: _startDateController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            onPressed: _isLoading ? null : _selectStartDate,
            icon: const Icon(Icons.event),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTimeField() {
    return PRFFormSection(
      icon: Icons.schedule,
      title: 'Start Time',
      isRequired: true,
      subtitle: 'Mission start time',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextInput(
              hintText: 'HH:mm',
              labelText: 'Start Time *',
              helperText: 'Mission start time',
              errorText: _showValidation ? _startTimeError : null,
              controller: _startTimeController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            onPressed: _isLoading ? null : _selectStartTime,
            icon: const Icon(Icons.schedule),
          ),
        ],
      ),
    );
  }

  Widget _buildEndDateField() {
    return PRFFormSection(
      icon: Icons.event_available,
      title: 'End Date',
      isRequired: true,
      subtitle: 'Select mission end date',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextInput(
              hintText: 'YYYY-MM-DD',
              labelText: 'End Date *',
              helperText: 'Select mission end date',
              errorText: _showValidation ? _endDateError : null,
              controller: _endDateController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            onPressed: _isLoading ? null : _selectEndDate,
            icon: const Icon(Icons.event_available),
          ),
        ],
      ),
    );
  }

  Widget _buildEndTimeField() {
    return PRFFormSection(
      icon: Icons.schedule_send,
      title: 'End Time',
      isRequired: true,
      subtitle: 'Mission end time',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextInput(
              hintText: 'HH:mm',
              labelText: 'End Time *',
              helperText: 'Mission end time',
              errorText: _showValidation ? _endTimeError : null,
              controller: _endTimeController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            onPressed: _isLoading ? null : _selectEndTime,
            icon: const Icon(Icons.schedule_send),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeField(AppLocalizations l10n) {
    return PRFFormSection(
      icon: Icons.label_outline,
      title: l10n.theme,
      isRequired: true,
      subtitle: 'Mission focus/theme',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextInput(
        hintText: 'Mission theme',
        labelText: '${l10n.theme} *',
        helperText: 'Mission focus/theme',
        errorText: _showValidation ? _themeError : null,
        controller: _themeController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildCapacityField() {
    return PRFFormSection(
      icon: Icons.groups_outlined,
      title: 'Capacity',
      isRequired: true,
      subtitle: 'Missionaries needed',
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFNumberInput(
        hintText: '0',
        labelText: 'Capacity *',
        helperText: 'Missionaries needed',
        errorText: _showValidation ? _capacityError : null,
        controller: _capacityController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildWhatsAppField() {
    return PRFFormSection(
      icon: Icons.forum_outlined,
      title: 'WhatsApp Link',

      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextInput(
        hintText: 'https://...',
        labelText: 'WhatsApp Link',
        helperText: 'Optional',
        controller: _whatsAppLinkController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildPreparationNotesField() {
    return PRFFormSection(
      icon: Icons.notes_outlined,
      title: 'Preparation Notes',

      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextAreaInput(
        hintText: 'Any mission preparation notes',
        labelText: 'Preparation Notes',
        helperText: 'Optional',
        controller: _prepNotesController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildSchoolTermDropdown() {
    return BlocBuilder<SchoolTermResourceCubit, ResourceState<PRFSchoolTerm>>(
      builder: (context, state) {
        final terms = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, data) => items,
          error: (message, items) => items,
          orElse: () => <PRFSchoolTerm>[],
        );

        return PRFFormSection(
          icon: Icons.calendar_view_month,
          title: 'School Term',
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: PRFSpacingTokens.sm,
                runSpacing: PRFSpacingTokens.sm,
                children: terms.map((term) {
                  final isSelected = term.ulid == _selectedSchoolTermUlid;
                  return GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedSchoolTermUlid = term.ulid;
                            });
                            if (_showValidation) {
                              _validateForm();
                            }
                          },
                    child: AnimatedContainer(
                      duration: PRFMotionTokens.standard,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.lg,
                        vertical: PRFSpacingTokens.sm,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: Text(
                        term.name,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_showValidation && _schoolTermError != null)
                Padding(
                  padding: const EdgeInsets.only(top: PRFSpacingTokens.xs),
                  child: Text(
                    _schoolTermError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionTypeDropdown() {
    return BlocBuilder<MissionTypeResourceCubit, ResourceState<PRFMissionType>>(
      builder: (context, state) {
        final types = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, data) => items,
          error: (message, items) => items,
          orElse: () => <PRFMissionType>[],
        );

        return PRFFormSection(
          icon: Icons.category_outlined,
          title: 'Mission Type',
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: PRFSpacingTokens.sm,
                runSpacing: PRFSpacingTokens.sm,
                children: types.map((type) {
                  final isSelected = type.ulid == _selectedMissionTypeUlid;
                  return GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedMissionTypeUlid = type.ulid;
                            });
                            if (_showValidation) {
                              _validateForm();
                            }
                          },
                    child: AnimatedContainer(
                      duration: PRFMotionTokens.standard,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.lg,
                        vertical: PRFSpacingTokens.sm,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: Text(
                        type.name,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_showValidation && _missionTypeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: PRFSpacingTokens.xs),
                  child: Text(
                    _missionTypeError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchoolDropdown() {
    return BlocBuilder<SchoolCubit, ResourceState<PRFSchool>>(
      builder: (context, state) {
        final schools = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          mutated: (items, operation, data) => items,
          error: (message, items) => items,
          orElse: () => <PRFSchool>[],
        );

        return PRFFormSection(
          icon: Icons.school_outlined,
          title: 'School',
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFSearchableList<String>(
            entries: schools
                .map(
                  (school) => PRFSearchableListEntry<String>(
                    value: school.ulid,
                    label: school.name,
                  ),
                )
                .toList(),
            onSelected: (value) {
              setState(() {
                _selectedSchoolUlid = value;
              });
              if (_showValidation) {
                _validateForm();
              }
            },
            selection: _selectedSchoolUlid,
            hintText: 'Search school',
            emptyText: 'No schools found',
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _startDate ?? DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;
      _startDateController.text = DateFormat('yyyy-MM-dd').format(selected);
      if (_endDate != null && _endDate!.isBefore(selected)) {
        _endDate = selected;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(selected);
      }
      if (_showValidation) {
        _validateForm();
      }
    });
  }

  Future<void> _selectEndDate() async {
    final firstDate = _startDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _endDate ?? firstDate,
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
      _endDateController.text = DateFormat('yyyy-MM-dd').format(selected);
      if (_showValidation) {
        _validateForm();
      }
    });
  }

  Future<void> _selectStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (selected == null) return;

    setState(() {
      _startTimeController.text = Misc.toApiTime(selected);
      if (_showValidation) {
        _validateForm();
      }
    });
  }

  Future<void> _selectEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );

    if (selected == null) return;

    setState(() {
      _endTimeController.text = Misc.toApiTime(selected);
      if (_showValidation) {
        _validateForm();
      }
    });
  }

  Future<void> _submit() async {
    if (!_validateForm()) {
      PRFSnackbar.error(context, 'Please fix highlighted fields first.');
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim());
    final utcStartDateTime = Misc.localDateAndTimeToUtc(
      date: _startDate!,
      hhmm: _startTimeController.text.trim(),
    );
    final utcEndDateTime = Misc.localDateAndTimeToUtc(
      date: _endDate!,
      hhmm: _endTimeController.text.trim(),
    );

    await context.read<MissionResourceCubit>().createMission(
      dto: PRFMissionDTO(
        schoolTermUlid: _selectedSchoolTermUlid!,
        missionTypeUlid: _selectedMissionTypeUlid!,
        schoolUlid: _selectedSchoolUlid!,
        startDate: utcStartDateTime,
        endDate: utcEndDateTime,
        startTime: Misc.toUtcApiTime(utcStartDateTime),
        endTime: Misc.toUtcApiTime(utcEndDateTime),
        theme: _themeController.text.trim().isEmpty
            ? null
            : _themeController.text.trim(),
        capacity: capacity,
        missionPrepNotes: _prepNotesController.text.trim().isEmpty
            ? null
            : _prepNotesController.text.trim(),
        whatsAppLink: _whatsAppLinkController.text.trim().isEmpty
            ? null
            : _whatsAppLinkController.text.trim(),
      ),
    );
  }
}
