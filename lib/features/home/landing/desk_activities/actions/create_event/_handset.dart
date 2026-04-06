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
import 'package:leadership/features/home/landing/desk_activities/cubit/event_resource_cubit.dart';
import 'package:leadership/features/home/landing/desk_activities/cubit/get_events_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class CreateEventViewHandset extends StatefulWidget {
  const CreateEventViewHandset({super.key});

  @override
  State<CreateEventViewHandset> createState() => _CreateEventViewHandsetState();
}

class _CreateEventViewHandsetState extends State<CreateEventViewHandset> {
  final _titleController = TextEditingController();
  final _startDateController = TextEditingController();
  HiveService get _hiveService => getIt<HiveService>();

  bool _isLoading = false;

  PRFResponsibleDesk? selectedResponsibleDesk;
  List<PRFMember> selectedParticipants = [];

  DateTime? startsAt;

  // Add form validity check
  bool get _isFormValid {
    return selectedResponsibleDesk != null &&
        _titleController.text.isNotEmpty &&
        startsAt != null;
  }

  @override
  void initState() {
    super.initState();

    // Add listeners to update form validity
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox(height: PRFSpacingTokens.lg),

                // Header Card
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
                          const SizedBox(height: PRFSpacingTokens.sm),
                          Text(
                            l10n.createNewActivity,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: PRFSpacingTokens.xs),
                          Text(
                            l10n.createActivityDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withValues(
                                        alpha: 0.9,
                                      ),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(duration: PRFMotionTokens.enterShort),

                const SizedBox(height: PRFSpacingTokens.xxl),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
                      PRFFormSection(
                            icon: Icons.group_outlined,
                            title: l10n.responsibleDesk,
                            isRequired: true,
                            child: PRFSearchableList<PRFResponsibleDesk>(
                              entries: _hiveService.responsibleDesks
                                  .map(
                                    (responsibleDesk) =>
                                        PRFSearchableListEntry<
                                          PRFResponsibleDesk
                                        >(
                                          value: responsibleDesk,
                                          label: responsibleDesk.name,
                                        ),
                                  )
                                  .toList(),
                              onSelected: (responsibleDesk) {
                                if (responsibleDesk == null) {
                                  setState(() {
                                    selectedResponsibleDesk = null;
                                  });
                                  return;
                                }
                                setState(() {
                                  selectedResponsibleDesk = responsibleDesk;
                                });

                                // Fetch members for the selected responsible
                                // desk.
                                final groups =
                                    PRFLeadershipGroup.fromResponsibleDesk(
                                      responsibleDesk,
                                    );
                                context.read<GetMembersCubit>().getMembers(
                                  groups: groups,
                                );
                              },
                              selection: selectedResponsibleDesk,
                              hintText: l10n.responsibleDesk,
                            ),
                          )
                          .animate(delay: PRFMotionTokens.stagger3)
                          .slideX(begin: -0.2)
                          .fadeIn(),

                      PRFFormSection(
                            icon: Icons.badge_outlined,
                            title: l10n.title,
                            isRequired: true,
                            child: PRFTextInput(
                              hintText: l10n.name,
                              controller: _titleController,
                            ),
                          )
                          .animate(delay: PRFMotionTokens.enterShort)
                          .slideX(begin: -0.2)
                          .fadeIn(),

                      PRFFormSection(
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
                          )
                          .animate(delay: PRFMotionTokens.stagger4)
                          .slideX(begin: -0.2)
                          .fadeIn(),

                      PRFFormSection(
                            icon: Icons.group_outlined,
                            title: l10n.participants,
                            child:
                                BlocBuilder<GetMembersCubit, GetMembersState>(
                                  builder: (context, state) {
                                    return state.maybeWhen(
                                      loaded: _buildParticipantsMultiSelect,
                                      loading: () => Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(
                                                      context,
                                                    ).colorScheme.outline
                                                    .withValues(
                                                      alpha: 0.2,
                                                    ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            PRFRadiusTokens.md,
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      orElse: () => Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Theme.of(
                                                      context,
                                                    ).colorScheme.outline
                                                    .withValues(
                                                      alpha: 0.2,
                                                    ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            PRFRadiusTokens.md,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No members available',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          )
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          )
                          .animate(delay: PRFMotionTokens.stagger3)
                          .slideX(begin: -0.2)
                          .fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: PRFSpacingTokens.xxl),

                // Submit Button
                BlocConsumer<EventResourceCubit, ResourceState<PRFEvent>>(
                  listener: (context, state) {
                    state.maybeWhen(
                      mutating: (items, operation) {
                        if (operation != ResourceOperation.create) {
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                      },
                      mutated: (items, operation, item) {
                        if (operation != ResourceOperation.create) {
                          return;
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        Gaimon.success();
                        context.read<GetEventsCubit>().getUpcomingEvents();

                        final requisition = context
                            .read<EventResourceCubit>()
                            .lastCreatedRequisition;
                        if (requisition == null) {
                          PRFSnackbar.error(
                            context,
                            'Event created but requisition was not found',
                          );
                          return;
                        }

                        Navigator.of(context).pop();
                        context.router.push(
                          RequisitionDetailsRoute(
                            requisitionUlid: requisition.ulid,
                          ),
                        );

                        PRFSnackbar.success(context, l10n.activityCreated);
                      },
                      error: (message, items) {
                        setState(() {
                          _isLoading = false;
                        });
                        Gaimon.error();
                        PRFSnackbar.error(context, message);
                      },
                      orElse: () {},
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

                const SizedBox(height: PRFSpacingTokens.xxxl),
              ],
            ),
          ),
        ),
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
            spacing: PRFSpacingTokens.sm,
            runSpacing: PRFSpacingTokens.sm,
            children: selectedParticipants.map((member) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
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
          const SizedBox(height: PRFSpacingTokens.md),
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
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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
                        horizontal: PRFSpacingTokens.lg,
                        vertical: PRFSpacingTokens.xs,
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
        const SizedBox(height: PRFSpacingTokens.sm),
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
    if (!_validateForm()) {
      return;
    }

    await context.read<EventResourceCubit>().addEvent(
      name: _titleController.text.trim(),
      startTime: startsAt!,
      responsibleDesk: selectedResponsibleDesk!,
      participants: selectedParticipants,
    );
  }

  bool _validateForm() {
    final l10n = context.l10n;

    if (_titleController.text.trim().isEmpty) {
      PRFSnackbar.error(context, l10n.enterTitle);
      Gaimon.warning();
      return false;
    }

    if (startsAt == null) {
      PRFSnackbar.error(context, l10n.addStartEnd);
      Gaimon.warning();
      return false;
    }

    if (selectedResponsibleDesk == null) {
      PRFSnackbar.error(context, l10n.selectResponsibleDesk);
      Gaimon.warning();
      return false;
    }

    return true;
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
}
