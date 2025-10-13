import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/add_event_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/router/router.gr.dart';

class CreateEventViewHandset extends StatefulWidget {
  const CreateEventViewHandset({super.key});

  @override
  State<CreateEventViewHandset> createState() => _CreateEventViewHandsetState();
}

class _CreateEventViewHandsetState extends State<CreateEventViewHandset> {
  final _titleController = TextEditingController();
  final _purposeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  HiveService get _hiveService => getIt<HiveService>();

  bool _isLoading = false;

  PRFResponsibleDesk? selectedResponsibleDesk;
  List<PRFMember> selectedParticipants = [];

  DateTime? startsAt;
  DateTime? endsAt;

  // Add form validity check
  bool get _isFormValid {
    return selectedResponsibleDesk != null &&
        _titleController.text.isNotEmpty &&
        _purposeController.text.isNotEmpty &&
        startsAt != null &&
        endsAt != null;
  }

  @override
  void initState() {
    super.initState();

    // Add listeners to update form validity
    _titleController.addListener(() => setState(() {}));
    _purposeController.addListener(() => setState(() {}));
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
                            onSelected: (responsibleDesk) {
                              setState(() {
                                selectedResponsibleDesk = responsibleDesk;
                              });

                              // Fetch members for the selected responsible desk
                              context.read<GetMembersCubit>().getMembers(
                                groups: PRFLeadershipGroup.fromResponsibleDesk(
                                  responsibleDesk!,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.badge_outlined,
                      title: l10n.title,
                      isRequired: true,
                      child: PRFTextInput(
                        hintText: l10n.name,
                        controller: _titleController,
                      ),
                    ).animate(delay: 600.ms).slideX(begin: -0.2).fadeIn(),

                    _buildFormSection(
                      icon: Icons.badge_outlined,
                      title: l10n.purpose,
                      isRequired: true,
                      child: PRFTextAreaInput(
                        hintText: l10n.purpose,
                        controller: _purposeController,
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

                    _buildFormSection(
                      icon: Icons.group_outlined,
                      title: l10n.participants,
                      child: BlocBuilder<GetMembersCubit, GetMembersState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            loaded: _buildParticipantsMultiSelect,
                            loading: () => Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            orElse: () => Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No members available',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ).animate(delay: 300.ms).slideX(begin: -0.2).fadeIn(),
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
                    loaded: (data) {
                      setState(() {
                        _isLoading = false;
                      });
                      Gaimon.success();
                      context.read<GetEventsCubit>().getUpcomingEvents();

                      Navigator.of(context).pop();
                      context.router.push(
                        RequisitionRoute(
                          requisitionUlid: data.requisition.ulid,
                        ),
                      );

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

  Widget _buildParticipantsMultiSelect(List<PRFMember> members) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected participants chips
        if (selectedParticipants.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedParticipants.map((member) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.fullName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedParticipants.removeWhere(
                            (p) => p.ulid == member.ulid,
                          );
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Members selection area
        Container(
          constraints: const BoxConstraints(
            maxHeight: 200,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: members.isEmpty
              ? SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'No members available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: members.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = selectedParticipants.any(
                      (p) => p.ulid == member.ulid,
                    );

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.onPrimary,
                              )
                            : Text(
                                member.firstName.isNotEmpty
                                    ? member.firstName[0].toUpperCase()
                                    : 'M',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      title: Text(
                        member.fullName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: member.email.isNotEmpty
                          ? Text(
                              member.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedParticipants.removeWhere(
                              (p) => p.ulid == member.ulid,
                            );
                          } else {
                            selectedParticipants.add(member);
                          }
                        });
                      },
                    );
                  },
                ),
        ),

        // Summary text
        const SizedBox(height: 8),
        Text(
          selectedParticipants.isEmpty
              ? 'Select participants from the list above'
              : '${selectedParticipants.length} '
                    'participant${selectedParticipants.length == 1 ? '' : 's'} '
                    'selected',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    final l10n = context.l10n;

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterTitle)),
      );
      Gaimon.warning();
      return;
    }

    if (_purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPurpose)),
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
      name: _titleController.text.trim(),
      remarks: _purposeController.text.trim(),
      startTime: startsAt!,
      endTime: endsAt!,
      responsibleDesk: selectedResponsibleDesk!,
      participants: selectedParticipants,
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
      maxTime: DateTime.now().add(const Duration(days: 30 * 12)),
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
