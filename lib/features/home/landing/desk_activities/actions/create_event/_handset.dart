import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/add_event_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';

class CreateEventViewHandset extends StatefulWidget {
  const CreateEventViewHandset({super.key});

  @override
  State<CreateEventViewHandset> createState() => _CreateEventViewHandsetState();
}

class _CreateEventViewHandsetState extends State<CreateEventViewHandset> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  HiveService get _hiveService => getIt<HiveService>();

  bool _isLoading = false;

  PRFResponsibleDesk? selectedResponsibleDesk;

  DateTime? startsAt;
  DateTime? endsAt;

  // Add form validity check
  bool get _isFormValid {
    return selectedResponsibleDesk != null &&
        _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        startsAt != null &&
        endsAt != null;
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to update form validity
    _nameController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createNewActivity,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.createActivityDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
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
                    _buildFormSection(
                      icon: Icons.group_outlined,
                      title: l10n.responsibleDesk,
                      isRequired: true,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<PRFResponsibleDesk>(
                            width: constraints.maxWidth,
                            initialSelection: selectedResponsibleDesk,
                            hintText: l10n.responsibleDesk,
                            dropdownMenuEntries: _hiveService.responsibleDesks
                                .map(
                                  (responsibleDesk) =>
                                      DropdownMenuEntry<PRFResponsibleDesk>(
                                        value: responsibleDesk,
                                        label: responsibleDesk.name,
                                      ),
                                )
                                .toList(),
                            onSelected: (responsibleDesk) => setState(() {
                              selectedResponsibleDesk = responsibleDesk;
                            }),
                          );
                        },
                      ),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.badge_outlined,
                      title: l10n.name,
                      isRequired: true,
                      child: PRFTextInput(
                        hintText: l10n.name,
                        controller: _nameController,
                      ),
                    ).animate(delay: 600.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.notes_outlined,
                      title: l10n.description,
                      isRequired: true,
                      child: PRFTextAreaInput(
                        hintText: l10n.description,
                        controller: _descriptionController,
                      ),
                    ).animate(delay: 600.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.schedule_outlined,
                      title: l10n.startTime,
                      isRequired: true,
                      child: GestureDetector(
                        onTap: _selectStartDate,
                        child: PRFTextInput(
                          hintText: l10n.startTime,
                          controller: _startDateController,
                          enabled: false,
                        ),
                      ),
                    ).animate(delay: 400.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.schedule_outlined,
                      title: l10n.endTime,
                      isRequired: true,
                      child: GestureDetector(
                        onTap: _selectEndDate,
                        child: PRFTextInput(
                          hintText: l10n.endTime,
                          controller: _endDateController,
                          enabled: false,
                        ),
                      ),
                    ).animate(delay: 500.ms).slideX(begin: -0.2).fadeIn(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              BlocConsumer<AddEventCubit, AddEventState>(
                listener: (context, state) {
                  state.mapOrNull(
                    loading: (_) {
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    loaded: (_) {
                      setState(() {
                        _isLoading = false;
                      });
                      Gaimon.success();
                      context.read<GetEventsCubit>().getUpcomingEvents();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.activityCreated)),
                      );
                    },
                    error: (error) {
                      setState(() {
                        _isLoading = false;
                      });
                      Gaimon.error();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.message)));
                    },
                  );
                },
                builder: (context, state) {
                  return PRFPrimaryButton(
                    onPressed: _submitForm,
                    title: l10n.record,
                    disabled: !_isFormValid,
                    isLoading: _isLoading,
                  );
                },
              ).animate(delay: 700.ms).slideY(begin: 0.3).fadeIn(),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
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

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterName)),
      );
      Gaimon.warning();
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterDescription)),
      );
      Gaimon.warning();
      return;
    }

    if (startsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addStartEnd)),
      );
      Gaimon.warning();
      return;
    }

    if (endsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addStartEnd)),
      );
      Gaimon.warning();
      return;
    }

    if (selectedResponsibleDesk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectResponsibleDesk)),
      );
      Gaimon.warning();
      return;
    }

    await context.read<AddEventCubit>().addEvent(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startsAt!,
      endTime: endsAt!,
      responsibleDesk: selectedResponsibleDesk!,
    );
  }

  Future<void> _selectStartDate() async {
    await DatePicker.showDateTimePicker(
      context,
      minTime: DateTime.now().subtract(const Duration(days: 7)),
      maxTime: DateTime.now().add(const Duration(days: 30)),
      theme: picker.DatePickerTheme(
        itemStyle: Theme.of(context).textTheme.headlineSmall!,
        doneStyle: Theme.of(context).textTheme.headlineSmall!,
        cancelStyle: Theme.of(context).textTheme.headlineSmall!,
      ),
      onConfirm: (date) {
        setState(() {
          startsAt = date;
        });
        _startDateController.text = DateFormat.MMMMEEEEd().add_Hm().format(
          date,
        );
      },
      currentTime: DateTime.now(),
    );
  }

  Future<void> _selectEndDate() async {
    await DatePicker.showDateTimePicker(
      context,
      minTime: DateTime.now().subtract(const Duration(days: 7)),
      maxTime: DateTime.now().add(const Duration(days: 30)),
      theme: picker.DatePickerTheme(
        itemStyle: Theme.of(context).textTheme.headlineSmall!,
        doneStyle: Theme.of(context).textTheme.headlineSmall!,
        cancelStyle: Theme.of(context).textTheme.headlineSmall!,
      ),
      onConfirm: (date) {
        setState(() {
          endsAt = date;
        });
        _endDateController.text = DateFormat.MMMMEEEEd().add_Hm().format(date);
      },
      currentTime: DateTime.now(),
    );
  }
}
