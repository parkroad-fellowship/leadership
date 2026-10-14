import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/enums/prf_leadership_group.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/features/events/cubit/event_resource_cubit.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
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

  Duration _motion(Duration duration) =>
      PRFMotionTokens.resolve(context, duration);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: PRFOpacities.faint),
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
                            Theme.of(context).colorScheme.primary.withValues(
                              alpha: PRFOpacities.stronger,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        boxShadow: PRFShadowTokens.badge(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: PRFSizeTokens.iconXl,
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
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(
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
                      duration: _motion(PRFMotionTokens.enterShort),
                    )
                    .fadeIn(),

                const SizedBox(height: PRFSpacingTokens.xxl),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(
                        alpha: PRFOpacities.muted,
                      ),
                    ),
                    boxShadow: PRFShadowTokens.card(
                      Theme.of(context).colorScheme.shadow,
                    ),
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
                                context.read<MemberResourceCubit>().getMembers(
                                  groups: groups,
                                );
                              },
                              selection: selectedResponsibleDesk,
                              hintText: l10n.responsibleDesk,
                            ),
                          )
                          .animate(delay: _motion(PRFMotionTokens.stagger3))
                          .slideX(
                            begin: -0.2,
                            duration: _motion(PRFMotionTokens.slow),
                          )
                          .fadeIn(),

                      PRFFormSection(
                            icon: Icons.badge_outlined,
                            title: l10n.title,
                            isRequired: true,
                            child: PRFTextField(
                              hintText: l10n.name,
                              controller: _titleController,
                            ),
                          )
                          .animate(delay: _motion(PRFMotionTokens.enterShort))
                          .slideX(
                            begin: -0.2,
                            duration: _motion(PRFMotionTokens.slow),
                          )
                          .fadeIn(),

                      PRFFormSection(
                            icon: Icons.schedule_outlined,
                            title: l10n.startTime,
                            isRequired: true,
                            child: Semantics(
                              button: true,
                              label: l10n.eventsChooseStartTime,
                              value: _startDateController.text,
                              excludeSemantics: true,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _selectStartDate,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.md,
                                  ),
                                  child: IgnorePointer(
                                    child: PRFTextField(
                                      hintText: l10n.eventsChooseStartTime,
                                      controller: _startDateController,
                                      enabled: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate(delay: _motion(PRFMotionTokens.stagger4))
                          .slideX(
                            begin: -0.2,
                            duration: _motion(PRFMotionTokens.slow),
                          )
                          .fadeIn(),

                      PRFFormSection(
                            icon: Icons.group_outlined,
                            title: l10n.participants,
                            child:
                                BlocBuilder<
                                  MemberResourceCubit,
                                  ResourceState<PRFMember>
                                >(
                                  builder: (context, state) {
                                    return state.maybeWhen(
                                      listLoaded: (members, _, _) =>
                                          _buildParticipantsMultiSelect(
                                            members,
                                          ),
                                      listLoading: (items) => Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 60,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(
                                                  alpha: PRFOpacities.muted,
                                                ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            PRFRadiusTokens.md,
                                          ),
                                        ),
                                        child: const Center(
                                          child: PRFCircularProgressIndicator(),
                                        ),
                                      ),
                                      orElse: () => Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 60,
                                        ),
                                        padding: const EdgeInsets.all(
                                          PRFSpacingTokens.md,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(
                                                  alpha: PRFOpacities.muted,
                                                ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            PRFRadiusTokens.md,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            selectedResponsibleDesk == null
                                                ? l10n.eventsChooseDeskForMembers
                                                : l10n.eventsNoMembersAvailable,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
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
                          .animate(delay: _motion(PRFMotionTokens.stagger5))
                          .slideX(
                            begin: -0.2,
                            duration: _motion(PRFMotionTokens.slow),
                          )
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
                          listLoaded: (items, page, hasMore) {
                            if (_isLoading) {
                              setState(() {
                                _isLoading = false;
                              });
                              Gaimon.success();

                              final requisition = context
                                  .read<EventResourceCubit>()
                                  .lastCreatedRequisition;
                              if (requisition == null) {
                                PRFSnackbar.error(
                                  context,
                                  l10n.eventsRequisitionNotFound,
                                );
                                return;
                              }

                              Navigator.of(context).pop();
                              context.router.push(
                                RequisitionDetailsRoute(
                                  requisitionUlid: requisition.ulid,
                                ),
                              );

                              PRFSnackbar.success(
                                context,
                                l10n.activityCreated,
                              );
                            }
                          },
                          error: (message, items) {
                            setState(() {
                              _isLoading = false;
                            });
                            Gaimon.error();
                            PRFSnackbar.error(context, l10n.eventsCreateFailed);
                          },
                          orElse: () {},
                        );
                      },
                      builder: (context, state) {
                        return PRFButton(
                          onPressed: _submitForm,
                          title: l10n.eventsCreateActivityButton,
                          disabled: !_isFormValid,
                          isLoading: _isLoading,
                        );
                      },
                    )
                    .animate(delay: _motion(PRFMotionTokens.enterLong))
                    .slideY(begin: 0.3, duration: _motion(PRFMotionTokens.slow))
                    .fadeIn(),

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
              return InputChip(
                label: Text(member.fullName),
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.glow,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: PRFSizeTokens.iconSm,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                deleteButtonTooltipMessage:
                    context.l10n.eventsRemoveParticipant,
                onDeleted: () {
                  setState(() {
                    selectedParticipants.removeWhere(
                      (p) => p.ulid == member.ulid,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
        ],

        // Members selection area
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: PRFOpacities.muted,
              ),
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          ),
          child: members.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                  child: Center(
                    child: Text(
                      context.l10n.eventsNoMembersAvailable,
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
                    color: theme.colorScheme.outline.withValues(
                      alpha: PRFOpacities.subtle,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = selectedParticipants.any(
                      (p) => p.ulid == member.ulid,
                    );

                    return ListTile(
                      selected: isSelected,
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
                                size: PRFSizeTokens.iconSm,
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
              ? context.l10n.eventsSelectParticipantsHint
              : context.l10n.eventsParticipantsSelected(
                  selectedParticipants.length,
                ),
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
