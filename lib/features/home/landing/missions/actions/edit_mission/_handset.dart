import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_dto.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:prf_design/prf_design.dart';

class EditMissionViewHandset extends StatefulWidget {
  const EditMissionViewHandset({required this.mission, super.key});

  final PRFMission mission;

  @override
  State<EditMissionViewHandset> createState() => _EditMissionViewHandsetState();
}

class _EditMissionViewHandsetState extends State<EditMissionViewHandset>
    with TimezoneMixin {
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
  String? _startDateError;
  String? _endDateError;
  String? _startTimeError;
  String? _endTimeError;
  bool _showValidation = false;

  bool get _isFormValid {
    return _startDate != null &&
        _endDate != null &&
        _startTimeController.text.trim().isNotEmpty &&
        _endTimeController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _startDate = widget.mission.startDate;
    _endDate = widget.mission.endDate;

    _themeController.text = widget.mission.theme ?? '';
    _capacityController.text = widget.mission.capacity.toString();
    _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate!);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);
    _startTimeController.text = Misc.formatTime(
      widget.mission.startTime,
      timezone,
    );
    _endTimeController.text = Misc.formatTime(widget.mission.endTime, timezone);
    _prepNotesController.text = widget.mission.missionPrepNotes ?? '';
    _whatsAppLinkController.text = widget.mission.whatsAppLink ?? '';
    _startTimeController.addListener(_onChanged);
    _endTimeController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  void _clearErrors() {
    _startDateError = null;
    _endDateError = null;
    _startTimeError = null;
    _endTimeError = null;
  }

  bool _validateForm() {
    _clearErrors();

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

    setState(() {
      _showValidation = true;
    });

    return [
      _startDateError,
      _endDateError,
      _startTimeError,
      _endTimeError,
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
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return BlocListener<MissionResourceCubit, ResourceState<PRFMission>>(
      listener: (context, state) {
        switch (state) {
          case ResourceMutating<PRFMission>(:final operation)
              when operation == ResourceOperation.update:
            setState(() => _isLoading = true);
          case ResourceMutated<PRFMission>(:final operation)
              when operation == ResourceOperation.update:
            setState(() => _isLoading = false);
            Gaimon.success();
            Navigator.of(context).pop(true);
            PRFSnackbar.success(context, 'Mission updated successfully');
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
                  _buildForm(context),
                  const SizedBox(height: PRFSpacingTokens.lg),
                  PRFPrimaryButton(
                        onPressed: _submit,
                        title: 'Update Mission',
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
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit_rounded,
            size: 32,
            color: theme.colorScheme.onSecondary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Edit Mission',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.event,
          title: 'Start Date',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Row(
            children: [
              Expanded(
                child: PRFTextInput(
                  hintText: 'YYYY-MM-DD',
                  labelText: 'Start Date *',
                  helperText: 'Required',
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
        ),
        PRFFormSection(
          icon: Icons.event_available,
          title: 'End Date',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Row(
            children: [
              Expanded(
                child: PRFTextInput(
                  hintText: 'YYYY-MM-DD',
                  labelText: 'End Date *',
                  helperText: 'Required',
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
        ),
        PRFFormSection(
          icon: Icons.schedule,
          title: 'Start Time',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Row(
            children: [
              Expanded(
                child: PRFTextInput(
                  hintText: 'HH:mm',
                  labelText: 'Start Time *',
                  helperText: 'Required',
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
        ),
        PRFFormSection(
          icon: Icons.schedule_send,
          title: 'End Time',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Row(
            children: [
              Expanded(
                child: PRFTextInput(
                  hintText: 'HH:mm',
                  labelText: 'End Time *',
                  helperText: 'Required',
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
        ),
        PRFFormSection(
          icon: Icons.label_outline,
          title: 'Theme',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Mission theme',
            labelText: 'Theme',
            helperText: 'Optional',
            controller: _themeController,
            enabled: !_isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.groups_outlined,
          title: 'Capacity',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFNumberInput(
            hintText: '0',
            labelText: 'Capacity',
            helperText: 'Optional',
            controller: _capacityController,
            enabled: !_isLoading,
          ),
        ),
        PRFFormSection(
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
        ),
        PRFFormSection(
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
        ),
      ],
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
      initialTime:
          _parseTime(_startTimeController.text) ??
          const TimeOfDay(hour: 9, minute: 0),
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
      initialTime:
          _parseTime(_endTimeController.text) ??
          const TimeOfDay(hour: 17, minute: 0),
    );

    if (selected == null) return;

    setState(() {
      _endTimeController.text = Misc.toApiTime(selected);
      if (_showValidation) {
        _validateForm();
      }
    });
  }

  TimeOfDay? _parseTime(String text) {
    final parts = text.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
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

    await context.read<MissionResourceCubit>().updateMission(
      missionUlid: widget.mission.ulid,
      dto: PRFMissionDTO(
        schoolTermUlid: widget.mission.schoolTerm!.ulid,
        missionTypeUlid: widget.mission.missionType!.ulid,
        schoolUlid: widget.mission.school!.ulid,
        startDate: utcStartDateTime,
        endDate: utcEndDateTime,
        startTime: Misc.toUtcApiTime(utcStartDateTime),
        endTime: Misc.toUtcApiTime(utcEndDateTime),
        theme: _themeController.text.trim().isEmpty
            ? null
            : _themeController.text.trim(),
        capacity: capacity ?? widget.mission.capacity,
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
