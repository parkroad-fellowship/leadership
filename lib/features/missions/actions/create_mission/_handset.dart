import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/features/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/missions/widgets/mission_selectable_chip.dart';
import 'package:leadership/features/schools/cubit/school_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_dto.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
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
    context.read<MissionTypeResourceCubit>().loadActive();
    context.read<SchoolTermResourceCubit>().loadActive();
    context.read<SchoolCubit>().loadAll();
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
      _schoolTermError = context.l10n.mfSchoolTermRequired;
    }
    if (_selectedMissionTypeUlid?.isEmpty ?? true) {
      _missionTypeError = context.l10n.mfMissionTypeRequired;
    }
    if (_selectedSchoolUlid?.isEmpty ?? true) {
      _schoolError = context.l10n.mfSchoolRequired;
    }
    if (_startDate == null) {
      _startDateError = context.l10n.mfStartDateRequired;
    }
    if (_endDate == null) {
      _endDateError = context.l10n.mfEndDateRequired;
    }
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      _endDateError = context.l10n.mfEndBeforeStart;
    }
    if (_startTimeController.text.trim().isEmpty) {
      _startTimeError = context.l10n.mfStartTimeRequired;
    }
    if (_endTimeController.text.trim().isEmpty) {
      _endTimeError = context.l10n.mfEndTimeRequired;
    }
    if (_themeController.text.trim().isEmpty) {
      _themeError = context.l10n.mfThemeRequired;
    }
    final capacity = int.tryParse(_capacityController.text.trim());
    if (_capacityController.text.trim().isEmpty) {
      _capacityError = context.l10n.mfCapacityRequired;
    } else if (capacity == null || capacity < 1) {
      _capacityError = context.l10n.mfCapacityMin;
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
          case ResourceListLoaded<PRFMission>() when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.success();
            Navigator.of(context).pop(true);
            PRFSnackbar.success(context, context.l10n.mfCreated);
          case ResourceError<PRFMission>() when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.mfSaveFailed);
          default:
            break;
        }
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
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
                  PRFButton(
                        onPressed: _submit,
                        title: context.l10n.mfCreateButton,
                        disabled: !_isFormValid,
                        isLoading: _isLoading,
                      )
                      .animate(
                        delay: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.enterMedium,
                        ),
                      )
                      .slideY(
                        begin: 0.3,
                        duration: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.slow,
                        ),
                      )
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
                theme.colorScheme.primary.withValues(
                  alpha: PRFOpacities.stronger,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          child: Column(
            children: [
              Icon(
                Icons.flight_takeoff_rounded,
                size: PRFSizeTokens.iconXl,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              Text(
                context.l10n.mfCreateButton,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xs),
              Text(
                context.l10n.mfCreateSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(
                    alpha: PRFOpacities.nearOpaque,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: -0.3,
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
        .fadeIn();
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
      title: context.l10n.mfStartDate,
      isRequired: true,
      subtitle: context.l10n.mfTapToChoose,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextField(
              hintText: 'YYYY-MM-DD',
              labelText: context.l10n.mfStartDate,
              helperText: context.l10n.mfTapToChoose,
              errorText: _showValidation ? _startDateError : null,
              controller: _startDateController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            tooltip: context.l10n.mfChooseStartDate,
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
      title: context.l10n.mfStartTime,
      isRequired: true,
      subtitle: context.l10n.mfTapToChoose,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextField(
              hintText: 'HH:mm',
              labelText: context.l10n.mfStartTime,
              helperText: context.l10n.mfTapToChoose,
              errorText: _showValidation ? _startTimeError : null,
              controller: _startTimeController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            tooltip: context.l10n.mfChooseStartTime,
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
      title: context.l10n.mfEndDate,
      isRequired: true,
      subtitle: context.l10n.mfTapToChoose,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextField(
              hintText: 'YYYY-MM-DD',
              labelText: context.l10n.mfEndDate,
              helperText: context.l10n.mfTapToChoose,
              errorText: _showValidation ? _endDateError : null,
              controller: _endDateController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            tooltip: context.l10n.mfChooseEndDate,
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
      title: context.l10n.mfEndTime,
      isRequired: true,
      subtitle: context.l10n.mfTapToChoose,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: PRFTextField(
              hintText: 'HH:mm',
              labelText: context.l10n.mfEndTime,
              helperText: context.l10n.mfTapToChoose,
              errorText: _showValidation ? _endTimeError : null,
              controller: _endTimeController,
              enabled: false,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          IconButton.outlined(
            tooltip: context.l10n.mfChooseEndTime,
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
      subtitle: context.l10n.mfThemeHelp,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextField(
        hintText: context.l10n.mfThemeHint,
        labelText: l10n.theme,
        helperText: context.l10n.mfThemeHelp,
        errorText: _showValidation ? _themeError : null,
        controller: _themeController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildCapacityField() {
    return PRFFormSection(
      icon: Icons.groups_outlined,
      title: context.l10n.mfCapacity,
      isRequired: true,
      subtitle: context.l10n.mfCapacityHelp,
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextField(
        hintText: '0',
        labelText: context.l10n.mfCapacity,
        helperText: context.l10n.mfCapacityHelp,
        errorText: _showValidation ? _capacityError : null,
        controller: _capacityController,
        type: PRFTextFieldType.number,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildWhatsAppField() {
    return PRFFormSection(
      icon: Icons.forum_outlined,
      title: context.l10n.mfWhatsAppLink,

      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextField(
        hintText: 'https://...',
        labelText: context.l10n.mfWhatsAppLink,
        helperText: context.l10n.mfOptional,
        controller: _whatsAppLinkController,
        enabled: !_isLoading,
      ),
    );
  }

  Widget _buildPreparationNotesField() {
    return PRFFormSection(
      icon: Icons.notes_outlined,
      title: context.l10n.mfPrepNotes,

      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: PRFTextField(
        hintText: context.l10n.mfPrepNotesHint,
        labelText: context.l10n.mfPrepNotes,
        helperText: context.l10n.mfOptional,
        controller: _prepNotesController,
        type: PRFTextFieldType.textArea,
        enabled: !_isLoading,
        minLines: 3,
        maxLines: 6,
      ),
    );
  }

  Widget _buildSchoolTermDropdown() {
    return BlocBuilder<SchoolTermResourceCubit, ResourceState<PRFSchoolTerm>>(
      builder: (context, state) {
        final terms = state.maybeWhen(
          listLoaded: (items, page, hasMore) => items,
          mutating: (items, operation) => items,
          error: (message, items) => items,
          orElse: () => <PRFSchoolTerm>[],
        );
        final hasError = state.maybeWhen(
          error: (_, _) => true,
          orElse: () => false,
        );

        return PRFFormSection(
          icon: Icons.calendar_view_month,
          title: context.l10n.mfSchoolTerm,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (terms.isEmpty && hasError)
                PRFErrorView.inline(
                  title: context.l10n.mfOptionsLoadError,
                  message: context.l10n.missionsLoadErrorMessage,
                  retryLabel: context.l10n.tryAgain,
                  onRetry: () =>
                      context.read<SchoolTermResourceCubit>().loadActive(),
                )
              else if (terms.isEmpty && state is! ResourceListLoading)
                Text(
                  context.l10n.mfNoTerms,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              Wrap(
                spacing: PRFSpacingTokens.sm,
                runSpacing: PRFSpacingTokens.sm,
                children: terms.map((term) {
                  final isSelected = term.ulid == _selectedSchoolTermUlid;
                  return MissionSelectableChip(
                    label: term.name,
                    selected: isSelected,
                    maxWidth: MediaQuery.sizeOf(context).width * 0.7,
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
          error: (message, items) => items,
          orElse: () => <PRFMissionType>[],
        );
        final hasError = state.maybeWhen(
          error: (_, _) => true,
          orElse: () => false,
        );

        return PRFFormSection(
          icon: Icons.category_outlined,
          title: context.l10n.mfMissionType,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (types.isEmpty && hasError)
                PRFErrorView.inline(
                  title: context.l10n.mfOptionsLoadError,
                  message: context.l10n.missionsLoadErrorMessage,
                  retryLabel: context.l10n.tryAgain,
                  onRetry: () =>
                      context.read<MissionTypeResourceCubit>().loadActive(),
                )
              else if (types.isEmpty && state is! ResourceListLoading)
                Text(
                  context.l10n.mfNoTypes,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              Wrap(
                spacing: PRFSpacingTokens.sm,
                runSpacing: PRFSpacingTokens.sm,
                children: types.map((type) {
                  final isSelected = type.ulid == _selectedMissionTypeUlid;
                  return MissionSelectableChip(
                    label: type.name,
                    selected: isSelected,
                    maxWidth: MediaQuery.sizeOf(context).width * 0.7,
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
          error: (message, items) => items,
          orElse: () => <PRFSchool>[],
        );

        return PRFFormSection(
          icon: Icons.school_outlined,
          title: context.l10n.mfSchool,
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
            hintText: context.l10n.mfSearchSchool,
            emptyText: context.l10n.mfNoSchools,
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
      PRFSnackbar.error(context, context.l10n.mfFixFields);
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
