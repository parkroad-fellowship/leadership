import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_institution_type.dart';
import 'package:leadership/enums/prf_mission_role.dart';
import 'package:leadership/enums/prf_mission_subscription_status.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_soul_decision_type.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/missions/actions/edit_mission/edit_mission.dart';
import 'package:leadership/features/home/landing/missions/cubit/class_group_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/debrief_note_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_offline_member_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_question_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_session_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_subscription_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/soul_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/feedback_data_section.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/finance_section.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/mission_ground.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/overview_section.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/people_data_section.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/record_sections.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/mission/prf_mission_offline_member.dart';
import 'package:leadership/models/remote/mission/prf_mission_offline_member_dto.dart';
import 'package:leadership/models/remote/mission/prf_mission_question.dart';
import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription_dto.dart';
import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/models/remote/mission/prf_soul_dto.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/models/remote/prf_debrief_note.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_views/expenses/expenses.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition/create_requisition.dart';
import 'package:leadership/shared_views/requisitions/requisitions.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:prf_design/prf_design.dart';

class MissionsDetailsPageHandset extends StatefulWidget {
  const MissionsDetailsPageHandset({required this.missionUlid, super.key});

  final String missionUlid;

  @override
  State<MissionsDetailsPageHandset> createState() =>
      _MissionsDetailsPageHandsetState();
}

class _MissionsDetailsPageHandsetState extends State<MissionsDetailsPageHandset>
    with SingleTickerProviderStateMixin {
  String get missionUlid => widget.missionUlid;

  int tabCount = 4;

  late TabController _tabController;
  int _currentTab = 0;
  PRFInstitutionType? _loadedClassGroupInstitutionType;

  void _changeTab() {
    setState(() {
      _currentTab = _tabController.index;
    });
  }

  Future<void> _showEditMissionSheet(PRFMission mission) async {
    await PRFBottomSheet.show<void>(
      context,
      title: 'Edit Mission',
      child: EditMissionView(mission: mission),
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch mission data
    context.read<MissionResourceCubit>().loadMission(missionUlid: missionUlid);
    _loadMissionSubdomainData();

    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_changeTab);
  }

  PRFMission? _currentMissionFromState(ResourceState<PRFMission> state) {
    return switch (state) {
      ResourceListLoaded<PRFMission>(:final items) when items.isNotEmpty =>
        items.first,
      ResourceMutating<PRFMission>(:final items) when items.isNotEmpty =>
        items.first,
      ResourceMutated<PRFMission>(:final items) when items.isNotEmpty =>
        items.first,
      ResourceError<PRFMission>(:final items) when items.isNotEmpty =>
        items.first,
      _ => null,
    };
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_changeTab)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadMissionSubdomainData() {
    return Future.wait([
      context.read<MissionQuestionResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<DebriefNoteResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<SoulResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<MissionSubscriptionResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<MissionSessionResourceCubit>().loadForMission(
        // Works
        missionUlid: missionUlid,
      ),
      context.read<MissionOfflineMemberResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
    ]);
  }

  Future<void> _loadClassGroupsForMission(PRFMission mission) async {
    final institutionType = mission.school?.institutionType;
    if (institutionType == null) {
      return;
    }

    if (_loadedClassGroupInstitutionType == institutionType) {
      return;
    }

    _loadedClassGroupInstitutionType = institutionType;
    await context.read<ClassGroupResourceCubit>().loadActiveForInstitutionType(
      institutionType,
    );
  }

  List<T> _itemsFromResourceState<T>(ResourceState<T> state) {
    return state.maybeWhen(
      listLoaded: (items, _, _) => items,
      mutating: (items, _) => items,
      mutated: (items, _, _) => items,
      error: (_, items) => items,
      orElse: () => const [],
    );
  }

  String? _resourceErrorMessage<T>(ResourceState<T> state) {
    return switch (state) {
      ResourceError<T>(:final message) => message,
      _ => null,
    };
  }

  Future<String?> _showQuestionFormSheet({
    required String title,
    String? initialValue,
    String submitLabel = 'Save',
  }) {
    return PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionTextFormBody(
        title: 'Question',
        subtitle: 'Capture what students asked during the mission',
        labelText: 'Question',
        helperText: 'Required',
        validationErrorText: 'Question is required',
        hintText: 'What did the students want to know?',
        isRequired: true,
        initialValue: initialValue,
        submitLabel: submitLabel,
      ),
    );
  }

  Future<String?> _showDebriefNoteFormSheet({
    required String title,
    String? initialValue,
    String submitLabel = 'Save',
  }) {
    return PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionTextFormBody(
        title: 'Debrief Note',
        subtitle: 'Capture what happened and what the team learned',
        labelText: 'Debrief Note',
        helperText: 'Required',
        validationErrorText: 'Debrief note is required',
        hintText: 'Capture what happened and what we learned.',
        isRequired: true,
        minLines: 4,
        maxLines: 8,
        initialValue: initialValue,
        submitLabel: submitLabel,
      ),
    );
  }

  List<PRFClassGroup> _availableClassGroups() {
    final mission = _currentMissionFromState(
      context.read<MissionResourceCubit>().state,
    );
    final missionInstitutionType = mission?.school?.institutionType;
    final classGroups = _itemsFromResourceState(
      context.read<ClassGroupResourceCubit>().state,
    );

    final result =
        classGroups
            .where(
              (group) =>
                  missionInstitutionType == null ||
                  group.institutionType == missionInstitutionType,
            )
            .where((group) => group.ulid.isNotEmpty)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return result;
  }

  Future<PRFSoulDTO?> _showSoulFormSheet({
    required String title,
    required String submitLabel,
    String? initialName,
    String? initialNote,
    String? initialClassGroupUlid,
    PRFSoulDecisionType initialDecisionType = PRFSoulDecisionType.salvation,
  }) {
    return PRFBottomSheet.show<PRFSoulDTO>(
      context,
      title: title,
      child: _MissionSoulFormBody(
        missionUlid: missionUlid,
        classGroups: _availableClassGroups(),
        initialName: initialName,
        initialNote: initialNote,
        initialClassGroupUlid: initialClassGroupUlid,
        initialDecisionType: initialDecisionType,
        submitLabel: submitLabel,
      ),
    );
  }

  Future<Object?> _showMemberSubscriptionFormSheet() {
    context.read<GetMembersCubit>().getMembers();

    return PRFBottomSheet.show<Object>(
      context,
      title: 'Subscribe Member',
      child: _MissionMemberSubscriptionFormBody(missionUlid: missionUlid),
    );
  }

  Future<bool> _showDeleteConfirmation({
    required String title,
    String message = 'Are you sure you want to continue?',
  }) async {
    final shouldDelete = await PRFConfirmationDialog.show(
      context,
      title: title,
      message: message,
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    return shouldDelete ?? false;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Unknown date';
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Future<void> _promptAddQuestion() async {
    final questionValue = await _showQuestionFormSheet(
      title: 'Add Question',
    );
    if (!mounted || questionValue == null || questionValue.isEmpty) return;

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.createQuestion(
      missionUlid: missionUlid,
      question: questionValue,
    );
    if (!mounted) return;

    final state = cubit.state;
    final error = _resourceErrorMessage(state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Question recorded');
  }

  Future<void> _deleteQuestion(PRFMissionQuestion question) async {
    final questionUlid = question.ulid;
    if (questionUlid.isEmpty) {
      PRFSnackbar.error(context, 'Question cannot be deleted yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: 'Delete Question',
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.deleteQuestion(questionUlid: questionUlid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Question deleted successfully');
  }

  Future<void> _promptEditQuestion(PRFMissionQuestion question) async {
    if (question.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Question cannot be edited yet');
      return;
    }

    final updatedQuestion = await _showQuestionFormSheet(
      title: 'Edit Question',
      initialValue: question.question,
      submitLabel: 'Update',
    );
    if (!mounted || updatedQuestion == null || updatedQuestion.isEmpty) {
      return;
    }

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.updateQuestion(
      questionUlid: question.ulid,
      missionUlid: missionUlid,
      question: updatedQuestion,
    );
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Question updated');
  }

  Future<void> _promptAddDebriefNote() async {
    final noteValue = await _showDebriefNoteFormSheet(
      title: 'Add Debrief Note',
    );
    if (!mounted || noteValue == null || noteValue.isEmpty) return;

    final cubit = context.read<DebriefNoteResourceCubit>();
    await cubit.createNote(missionUlid: missionUlid, note: noteValue);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note added');
  }

  Future<void> _deleteDebriefNote(PRFDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Debrief note cannot be deleted yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: 'Delete Debrief Note',
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<DebriefNoteResourceCubit>();
    await cubit.deleteNote(noteUlid: note.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note deleted');
  }

  Future<void> _promptEditDebriefNote(PRFDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Debrief note cannot be edited yet');
      return;
    }

    final updatedNote = await _showDebriefNoteFormSheet(
      title: 'Edit Debrief Note',
      initialValue: note.note,
      submitLabel: 'Update',
    );
    if (!mounted || updatedNote == null || updatedNote.isEmpty) return;

    final cubit = context.read<DebriefNoteResourceCubit>();
    await cubit.updateNote(
      noteUlid: note.ulid,
      missionUlid: missionUlid,
      note: updatedNote,
    );
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note updated');
  }

  Future<void> _promptAddSoul() async {
    final classGroups = _availableClassGroups();
    if (classGroups.isEmpty) {
      PRFSnackbar.error(
        context,
        'No active class groups found. Create one and try again.',
      );
      return;
    }

    final soulData = await _showSoulFormSheet(
      title: 'Record Soul',
      submitLabel: 'Record',
    );
    if (!mounted || soulData == null || soulData.fullName.trim().isEmpty) {
      return;
    }

    final cubit = context.read<SoulResourceCubit>();
    await cubit.createSoul(dto: soulData);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Soul recorded');
  }

  Future<void> _deleteSoul(PRFSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Soul cannot be deleted yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(title: 'Delete Soul');
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<SoulResourceCubit>();
    await cubit.deleteSoul(soulUlid: soul.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Soul deleted');
  }

  Future<void> _promptEditSoul(PRFSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Soul cannot be edited yet');
      return;
    }

    final updatedSoul = await _showSoulFormSheet(
      title: 'Edit Soul',
      submitLabel: 'Update',
      initialName: soul.fullName,
      initialNote: soul.notes,
      initialClassGroupUlid: soul.classGroup?.ulid,
      initialDecisionType: soul.decisionType,
    );
    if (!mounted ||
        updatedSoul == null ||
        updatedSoul.fullName.trim().isEmpty) {
      return;
    }

    final cubit = context.read<SoulResourceCubit>();
    await cubit.updateSoul(
      soulUlid: soul.ulid,
      dto: updatedSoul,
    );
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Soul updated');
  }

  Future<void> _promptSubscribeMember(PRFMission mission) async {
    final result = await _showMemberSubscriptionFormSheet();
    if (!mounted || result == null) return;

    if (result is PRFMissionSubscriptionDTO) {
      final cubit = context.read<MissionSubscriptionResourceCubit>();
      await cubit.subscribeMember(
        missionUlid: mission.ulid,
        memberUlid: result.memberUlid,
      );
      if (!mounted) return;

      final error = _resourceErrorMessage(cubit.state);
      if (error != null) {
        PRFSnackbar.error(context, error);
        return;
      }

      await context.read<MissionResourceCubit>().loadMission(
        missionUlid: mission.ulid,
      );
      if (!mounted) return;

      PRFSnackbar.success(context, 'Member subscribed to mission');
    } else if (result is PRFMissionOfflineMemberDTO) {
      final cubit = context.read<MissionOfflineMemberResourceCubit>();
      await cubit.addOfflineMember(
        missionUlid: mission.ulid,
        name: result.name,
        phone: result.phone,
      );
      if (!mounted) return;

      final error = _resourceErrorMessage(cubit.state);
      if (error != null) {
        PRFSnackbar.error(context, error);
        return;
      }

      await context.read<MissionResourceCubit>().loadMission(
        missionUlid: mission.ulid,
      );
      if (!mounted) return;

      PRFSnackbar.success(context, 'Missioner added to mission');
    }
  }

  Future<void> _unsubscribeMember({
    required PRFMission mission,
    required PRFMissionSubscription subscription,
  }) async {
    if (subscription.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Subscription cannot be removed yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: 'Remove Subscription',
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionSubscriptionResourceCubit>();
    await cubit.unsubscribeMember(subscriptionUlid: subscription.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }

    await context.read<MissionResourceCubit>().loadMission(
      missionUlid: mission.ulid,
    );
    if (!mounted) return;

    PRFSnackbar.success(context, 'Subscription removed');
  }

  Future<void> _viewSubscriberDetails(PRFMissionSubscription subscription) {
    return PRFBottomSheet.show<void>(
      context,
      title: 'Subscriber Details',
      child: _MissionSubscriberDetailsBody(subscription: subscription),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocListener<MissionResourceCubit, ResourceState<PRFMission>>(
      listener: (context, state) {
        final mission = _currentMissionFromState(state);
        if (mission != null) {
          _loadClassGroupsForMission(mission);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: DefaultTabController(
          length: tabCount,
          child: Column(
            children: [
              ColoredBox(
                color: theme.colorScheme.primary,
                child: Column(
                  children: [
                    PRFBrandedNavBar(
                      title: l10n.missionDetails,
                      onBack: () => context.router.popUntilRouteWithPath(
                        PRFLeadershipRouter.missionsRoute,
                      ),
                      actions: [
                        BlocBuilder<
                          MissionResourceCubit,
                          ResourceState<PRFMission>
                        >(
                          builder: (context, state) {
                            final isBusy =
                                state is ResourceMutating<PRFMission>;
                            if (isBusy) {
                              return const SizedBox.square(
                                dimension: 20,
                                child: PRFCircularProgressIndicator(),
                              );
                            }

                            final mission = context
                                .read<MissionResourceCubit>()
                                .currentMission;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (mission != null)
                                  IconButton(
                                    tooltip: 'Edit mission',
                                    onPressed: () =>
                                        _showEditMissionSheet(mission),
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                IconButton(
                                  tooltip: 'Refresh mission',
                                  onPressed: () => context
                                      .read<MissionResourceCubit>()
                                      .loadMission(missionUlid: missionUlid),
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: PRFSpacingTokens.lg),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PRFSpacingTokens.sm,
                        0,
                        PRFSpacingTokens.sm,
                        PRFSpacingTokens.sm,
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, -6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TabBar(
                            controller: _tabController,
                            onTap: (value) => setState(() {
                              _currentTab = value;
                            }),
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: PRFSpacingTokens.sm,
                            ),
                            labelColor: theme.colorScheme.onPrimary,
                            unselectedLabelColor: theme.colorScheme.onPrimary
                                .withValues(alpha: 0.65),
                            indicatorColor: theme.colorScheme.secondary,
                            dividerColor: theme.colorScheme.onPrimary
                                .withValues(
                                  alpha: 0.2,
                                ),
                            labelStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'People Data'),
                              Tab(text: 'Feedback Data'),
                              Tab(text: 'Finance'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<
                      MissionResourceCubit,
                      ResourceState<PRFMission>
                    >(
                      builder: (context, state) {
                        final mission = _currentMissionFromState(state);

                        if (state is ResourceListLoading<PRFMission> &&
                            mission == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (mission == null &&
                            state is ResourceError<PRFMission>) {
                          final message = state.message;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: PRFSpacingTokens.lg),
                                Text(
                                  'Error: $message',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (mission == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            OverviewMissionDetailsSection(
                              missionGround: MissionGroundView(
                                mission: mission,
                              ),
                              operations: _buildMissionOperationsTab(mission),
                            ),
                            PeopleDataMissionDetailsSection(
                              subscribers: _buildMissionSubscribersTab(mission),
                              sessions: _buildMissionSessionsTab(),
                            ),
                            FeedbackDataMissionDetailsSection(
                              debriefNotes: _buildMissionDebriefTab(),
                              souls: _buildSoulsTab(),
                              questions: _buildMissionQuestionsTab(),
                            ),
                            FinanceMissionDetailsSection(
                              requisitionsLabel: l10n.requisitions,
                              expensesLabel: l10n.expenses,
                              requisitions: _buildMissionRequisitionsTab(
                                mission,
                              ),
                              expenses: _buildMissionExpensesTab(mission),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
        floatingActionButton:
            BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
              builder: (context, state) {
                final mission = _currentMissionFromState(state);
                if (mission == null) {
                  return const SizedBox.shrink();
                }

                return switch (_currentTab) {
                  3 when Misc.userCan(PRFPermissions.createRequisition) =>
                    FloatingActionButton.extended(
                      backgroundColor: PRFColorPalette.lime300,
                      foregroundColor: PRFColorPalette.navy900,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (mission.accountingEvent != null) {
                          PRFBottomSheet.show<void>(
                            context,
                            title: l10n.createRequisition,
                            child: CreateRequisitionView(
                              accountingEvent: mission.accountingEvent!,
                            ),
                          );
                        } else {
                          PRFSnackbar.error(
                            context,
                            l10n.requisitionUnavailable,
                          );
                        }
                      },
                      label: Text(l10n.createRequisition),
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
      ),
    );
  }

  Widget _buildMissionRequisitionsTab(PRFMission mission) {
    final l10n = context.l10n;

    if (mission.accountingEvent == null) {
      return PRFEmptyView(
        label: l10n.requisitionUnavailable,
        description: l10n.requisitionUnavailableDesc,
      );
    }

    return RequisitionsView(accountingEvent: mission.accountingEvent!);
  }

  Widget _buildMissionExpensesTab(PRFMission mission) {
    final l10n = context.l10n;

    if (mission.accountingEvent == null) {
      return PRFEmptyView(
        label: l10n.expensesUnavailable,
        description: l10n.expensesUnavailableDesc,
      );
    }

    return ExpensesView(accountingEventUlid: mission.accountingEvent!.ulid);
  }

  Widget _buildMissionSubscribersTab(PRFMission mission) {
    return MissionSubscribersTab(
      mission: mission,
      onRefresh: _loadMissionSubdomainData,
      subscriptionsSection: _buildMissionSubscriptionsSection(mission),
      offlineMembersSection: _buildOfflineMembersSection(mission),
    );
  }

  Widget _buildMissionQuestionsTab() {
    return BlocBuilder<
      MissionQuestionResourceCubit,
      ResourceState<PRFMissionQuestion>
    >(
      builder: (context, state) {
        final questions = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFMissionQuestion>,
          error: error,
          isEmpty: questions.isEmpty,
          onRefresh: () =>
              context.read<MissionQuestionResourceCubit>().loadForMission(
                missionUlid: missionUlid,
              ),
          onAdd: _promptAddQuestion,
          addButtonLabel: 'Add Question',
          addButtonIcon: Icons.add_comment_outlined,
          emptyLabel: 'No questions yet',
          emptyDescription:
              'Questions captured on mission ground will appear here.',
          items: questions
              .map(
                (question) => MissionResourceCard(
                  title: question.question.isEmpty
                      ? 'Untitled question'
                      : question.question,
                  subtitle: 'Captured ${_formatDate(question.createdAt)}',
                  editTooltip: 'Edit question',
                  onEdit: () => _promptEditQuestion(question),
                  deleteTooltip: 'Delete question',
                  onDelete: () => _deleteQuestion(question),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMissionDebriefTab() {
    return BlocBuilder<DebriefNoteResourceCubit, ResourceState<PRFDebriefNote>>(
      builder: (context, state) {
        final notes = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFDebriefNote>,
          error: error,
          isEmpty: notes.isEmpty,
          onRefresh: () => context
              .read<DebriefNoteResourceCubit>()
              .loadForMission(missionUlid: missionUlid),
          onAdd: _promptAddDebriefNote,
          addButtonLabel: 'Add Debrief Note',
          addButtonIcon: Icons.rate_review_outlined,
          emptyLabel: 'No debrief notes yet',
          emptyDescription:
              'Capture reflection notes from the mission team here.',
          items: notes
              .map(
                (note) => MissionResourceCard(
                  title: note.note.isEmpty ? 'Untitled note' : note.note,
                  subtitle: 'Captured ${_formatDate(note.createdAt)}',
                  editTooltip: 'Edit debrief note',
                  onEdit: () => _promptEditDebriefNote(note),
                  deleteTooltip: 'Delete debrief note',
                  onDelete: () => _deleteDebriefNote(note),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSoulsTab() {
    return BlocBuilder<SoulResourceCubit, ResourceState<PRFSoul>>(
      builder: (context, state) {
        final souls = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFSoul>,
          error: error,
          isEmpty: souls.isEmpty,
          onRefresh: () => context.read<SoulResourceCubit>().loadForMission(
            missionUlid: missionUlid,
          ),
          onAdd: _promptAddSoul,
          addButtonLabel: 'Record Soul',
          addButtonIcon: Icons.favorite_outline,
          emptyLabel: 'No souls recorded yet',
          emptyDescription: 'Souls recorded during ministry will appear here.',
          items: souls
              .map(
                (soul) => MissionResourceCard(
                  title: soul.fullName,
                  subtitle: soul.notes?.trim().isNotEmpty ?? false
                      ? soul.notes
                      : 'Captured ${_formatDate(soul.createdAt)}',
                  editTooltip: 'Edit soul',
                  onEdit: () => _promptEditSoul(soul),
                  deleteTooltip: 'Delete soul',
                  onDelete: () => _deleteSoul(soul),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMissionSubscriptionsSection(PRFMission mission) {
    return BlocBuilder<
      MissionSubscriptionResourceCubit,
      ResourceState<PRFMissionSubscription>
    >(
      builder: (context, state) {
        final subscriptions = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);
        return MissionSubscriptionsSection(
          subscriptions: subscriptions,
          error: error,
          onSubscribe: () => _promptSubscribeMember(mission),
          onViewSubscriber: _viewSubscriberDetails,
          onUnsubscribe: (subscription) => _unsubscribeMember(
            mission: mission,
            subscription: subscription,
          ),
          formatDate: _formatDate,
        );
      },
    );
  }

  Widget _buildOfflineMembersSection(PRFMission mission) {
    return BlocBuilder<
      MissionOfflineMemberResourceCubit,
      ResourceState<PRFMissionOfflineMember>
    >(
      builder: (context, state) {
        final members = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);
        return MissionOfflineMembersSection(
          offlineMembers: members,
          error: error,
          onAdd: () => _promptSubscribeMember(mission),
          onRemove: (member) => _removeOfflineMember(
            mission: mission,
            member: member,
          ),
          formatDate: _formatDate,
        );
      },
    );
  }

  Future<void> _removeOfflineMember({
    required PRFMission mission,
    required PRFMissionOfflineMember member,
  }) async {
    if (member.ulid.isEmpty) {
      PRFSnackbar.error(
        context,
        'Missioner cannot be removed yet',
      );
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: 'Remove Missioner',
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionOfflineMemberResourceCubit>();
    await cubit.removeOfflineMember(ulid: member.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }

    await context.read<MissionResourceCubit>().loadMission(
      missionUlid: mission.ulid,
    );
    if (!mounted) return;

    PRFSnackbar.success(context, 'Missioner removed');
  }

  Widget _buildMissionOperationsTab(PRFMission mission) {
    final operationTiles = <Widget>[
      _operationTile(
        icon: Icons.verified_outlined,
        title: 'Approve Mission',
        subtitle: 'Mark mission as approved',
        onTap: () => _runMissionAction(
          successMessage: 'Mission approved successfully',
          action: () => context.read<MissionResourceCubit>().approveMission(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.close_rounded,
        title: 'Reject Mission',
        subtitle: 'Reject this mission request',
        onTap: () => _rejectMission(mission),
      ),
      _operationTile(
        icon: Icons.event_busy_outlined,
        title: 'Cancel Mission',
        subtitle: 'Cancel this mission',
        onTap: () => _cancelMission(mission),
      ),
      _operationTile(
        icon: Icons.task_alt_outlined,
        title: 'Complete Mission',
        subtitle: 'Mark mission as serviced',
        onTap: () => _confirmCompleteMission(mission),
      ),
      _operationTile(
        icon: Icons.notifications_active_outlined,
        title: 'Notify School',
        subtitle: 'Send mission notification to school',
        onTap: () => _runMissionAction(
          successMessage: 'School notified successfully',
          action: () => context.read<MissionResourceCubit>().notifySchool(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.rate_review_outlined,
        title: 'Request School Feedback',
        subtitle: 'Ask school for mission feedback',
        onTap: () => _runMissionAction(
          successMessage: 'Feedback requested successfully',
          action: () => context
              .read<MissionResourceCubit>()
              .requestSchoolFeedback(missionUlid: mission.ulid),
        ),
      ),
      _operationTile(
        icon: Icons.forum_outlined,
        title: 'Notify WhatsApp Group',
        subtitle: 'Send mission update to WhatsApp group',
        onTap: () => _runMissionAction(
          successMessage: 'WhatsApp group notified successfully',
          action: () => context
              .read<MissionResourceCubit>()
              .notifyWhatsappGroup(missionUlid: mission.ulid),
        ),
      ),
      _operationTile(
        icon: Icons.summarize_outlined,
        title: 'Generate Summary',
        subtitle: 'Generate mission summary',
        onTap: () => _runMissionAction(
          successMessage: 'Mission summary generated successfully',
          action: () => context.read<MissionResourceCubit>().generateSummary(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.cloud_upload_outlined,
        title: 'Upload Media To Drive',
        subtitle: 'Upload mission media to Google Drive',
        onTap: () => _runMissionAction(
          successMessage: 'Mission media upload started',
          action: () => context.read<MissionResourceCubit>().uploadMediaToDrive(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.receipt_long_outlined,
        title: 'Make Zero Requisition',
        subtitle: 'Create a zero-value requisition for this mission',
        onTap: () => _confirmMakeZeroRequisition(mission),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.xxxl,
      ),
      children: operationTiles,
    );
  }

  Widget _operationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final disabled = _isMissionMutating;

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: disabled
              ? const SizedBox.square(
                  dimension: 18,
                  child: PRFCircularProgressIndicator(),
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: disabled ? null : onTap,
        ),
      ),
    );
  }

  Future<void> _runMissionAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_isMissionMutating) {
      PRFSnackbar.error(context, 'A mission operation is already in progress');
      return;
    }

    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      PRFSnackbar.error(context, e.toString());
      return;
    }

    if (!mounted) return;

    final state = context.read<MissionResourceCubit>().state;
    if (state case ResourceError<PRFMission>(:final message)) {
      PRFSnackbar.error(context, message);
      return;
    }

    PRFSnackbar.success(context, successMessage);
  }

  Future<void> _confirmCompleteMission(PRFMission mission) async {
    final shouldComplete = await _confirmAction(
      title: 'Complete Mission',
      content:
          'Mark this mission as completed? This should be used only after '
          'the mission has been serviced.',
      confirmLabel: 'Complete',
    );

    if (shouldComplete != true || !mounted) return;

    await _runMissionAction(
      successMessage: 'Mission completed successfully',
      action: () => context.read<MissionResourceCubit>().completeMission(
        missionUlid: mission.ulid,
      ),
    );
  }

  Future<void> _confirmMakeZeroRequisition(PRFMission mission) async {
    final shouldCreate = await _confirmAction(
      title: 'Make Zero Requisition',
      content:
          'Create a zero-value requisition for this mission? This is '
          'usually used when no spending is expected.',
      confirmLabel: 'Create',
    );

    if (shouldCreate != true || !mounted) return;

    await _runMissionAction(
      successMessage: 'Zero requisition created successfully',
      action: () => context.read<MissionResourceCubit>().makeZeroRequisition(
        missionUlid: mission.ulid,
      ),
    );
  }

  Future<bool?> _confirmAction({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return PRFConfirmationDialog.show(
      context,
      title: title,
      message: content,
      confirmLabel: confirmLabel,
    );
  }

  bool get _isMissionMutating {
    return context.read<MissionResourceCubit>().state
        is ResourceMutating<PRFMission>;
  }

  Future<void> _rejectMission(PRFMission mission) async {
    final reason = await _promptReason(
      title: 'Reject Mission',
      hintText: 'Optional reason',
      confirmLabel: 'Reject',
    );
    if (!mounted || reason == null) return;

    await _runMissionAction(
      successMessage: 'Mission rejected successfully',
      action: () => context.read<MissionResourceCubit>().rejectMission(
        missionUlid: mission.ulid,
        reason: reason,
      ),
    );
  }

  Future<void> _cancelMission(PRFMission mission) async {
    final reason = await _promptReason(
      title: 'Cancel Mission',
      hintText: 'Optional reason',
      confirmLabel: 'Cancel Mission',
    );
    if (!mounted || reason == null) return;

    await _runMissionAction(
      successMessage: 'Mission cancelled successfully',
      action: () => context.read<MissionResourceCubit>().cancelMission(
        missionUlid: mission.ulid,
        reason: reason,
      ),
    );
  }

  Future<String?> _promptReason({
    required String title,
    required String hintText,
    required String confirmLabel,
  }) async {
    final result = await PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionTextFormBody(
        title: 'Reason',
        subtitle: 'Optional context for this action',
        labelText: 'Reason',
        helperText: 'Optional',
        hintText: hintText,
        submitLabel: confirmLabel,
        isRequired: false,
      ),
    );

    if (result == null) {
      return null;
    }

    final trimmed = result.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  Widget _buildMissionSessionsTab() {
    return BlocBuilder<
      MissionSessionResourceCubit,
      ResourceState<PRFMissionSession>
    >(
      builder: (context, state) {
        final sessions = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);
        final theme = Theme.of(context);

        if (state is ResourceListLoading<PRFMissionSession> &&
            sessions.isEmpty) {
          return const Center(child: PRFCircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => context
              .read<MissionSessionResourceCubit>()
              .loadForMission(missionUlid: missionUlid),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.xxxl,
            ),
            children: [
              MissionSectionCard(
                title: 'Mission Sessions',
                subtitle:
                    'Track who led each session and when the ministry happened.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: PRFSpacingTokens.md,
                        ),
                        padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.md,
                          ),
                        ),
                        child: Text(
                          error,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    if (sessions.isEmpty)
                      const PRFEmptyView(
                        label: 'No sessions yet',
                        description:
                            'Session records for this mission will appear here.',
                      )
                    else
                      ...sessions.map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: PRFSpacingTokens.sm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PRFSpacingTokens.md,
                              vertical: PRFSpacingTokens.md,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.md,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.38,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.classGroup?.name ?? 'Mission Session',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: PRFSpacingTokens.xs),
                                Text(
                                  '${_formatDateTime(session.startsAt)} - ${_formatDateTime(session.endsAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: PRFSpacingTokens.xs),
                                Text(
                                  'Facilitator: ${session.facilitator?.fullName ?? 'Unassigned'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  'Speaker: ${session.speaker?.fullName ?? 'Unassigned'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (session.notes.trim().isNotEmpty) ...[
                                  const SizedBox(height: PRFSpacingTokens.sm),
                                  Text(
                                    session.notes,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissionTextFormBody extends StatefulWidget {
  const _MissionTextFormBody({
    required this.title,
    required this.subtitle,
    required this.labelText,
    required this.helperText,
    required this.hintText,
    required this.submitLabel,
    required this.isRequired,
    this.initialValue,
    this.validationErrorText,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final String title;
  final String subtitle;
  final String labelText;
  final String helperText;
  final String hintText;
  final String submitLabel;
  final bool isRequired;
  final String? initialValue;
  final String? validationErrorText;
  final int minLines;
  final int maxLines;

  @override
  State<_MissionTextFormBody> createState() => _MissionTextFormBodyState();
}

class _MissionTextFormBodyState extends State<_MissionTextFormBody> {
  late final TextEditingController _controller;
  String? _error;
  bool _showValidation = false;

  bool get _isFormValid {
    if (!widget.isRequired) {
      return true;
    }
    return _controller.text.trim().isNotEmpty;
  }

  bool _validate() {
    if (!widget.isRequired) {
      setState(() {
        _showValidation = true;
        _error = null;
      });
      return true;
    }

    final isValid = _controller.text.trim().isNotEmpty;
    setState(() {
      _showValidation = true;
      _error = isValid ? null : (widget.validationErrorText ?? 'Required');
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, 'Please fill in all required fields');
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '')
      ..addListener(_onChanged);
  }

  void _onChanged() {
    if (_showValidation) {
      _validate();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
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
                _buildHeaderCard(theme)
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(duration: PRFMotionTokens.enterShort),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PRFFormSection(
                        icon: Icons.edit_note_outlined,
                        title: widget.title,
                        subtitle: widget.subtitle,
                        isRequired: widget.isRequired,
                        margin: EdgeInsets.zero,
                        child: PRFTextAreaInput(
                          hintText: widget.hintText,
                          labelText: widget.labelText,
                          helperText: widget.helperText,
                          errorText: _showValidation ? _error : null,
                          controller: _controller,
                          minLines: widget.minLines,
                          maxLines: widget.maxLines,
                        ),
                      ),
                    )
                    .animate(delay: PRFMotionTokens.stagger3)
                    .slideX(begin: -0.2)
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFPrimaryButton(
                    onPressed: _submit,
                    title: widget.submitLabel,
                    disabled: !_isFormValid,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
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
            Icons.edit_note_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            widget.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            widget.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MissionMemberSubscriptionFormBody extends StatefulWidget {
  const _MissionMemberSubscriptionFormBody({required this.missionUlid});

  final String missionUlid;

  @override
  State<_MissionMemberSubscriptionFormBody> createState() =>
      _MissionMemberSubscriptionFormBodyState();
}

class _MissionMemberSubscriptionFormBodyState
    extends State<_MissionMemberSubscriptionFormBody> {
  String? _selectedMemberUlid;
  String? _selectionError;
  bool _showValidation = false;

  bool get _isFormValid {
    return _selectedMemberUlid != null &&
        _selectedMemberUlid!.trim().isNotEmpty;
  }

  bool _validateSelection() {
    if (_selectedMemberUlid != null && _selectedMemberUlid!.trim().isNotEmpty) {
      setState(() {
        _selectionError = null;
      });
      return true;
    }

    setState(() {
      _showValidation = true;
      _selectionError = 'Please select a member to continue';
    });
    return false;
  }

  void _submit() {
    if (!_validateSelection()) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fill in all required fields',
      );
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(
      PRFMissionSubscriptionDTO(
        missionUlid: widget.missionUlid,
        memberUlid: _selectedMemberUlid!.trim(),
      ),
    );
  }

  Future<void> _promptAddOfflineMember() async {
    final dto = await PRFBottomSheet.show<PRFMissionOfflineMemberDTO>(
      context,
      title: 'Add Missioner',
      child: _OfflineMemberFormBody(
        missionUlid: widget.missionUlid,
      ),
    );

    if (!mounted || dto == null) return;

    Gaimon.success();
    Navigator.of(context).pop(dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMembersCubit, GetMembersState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final members = state.maybeWhen(
          loaded: (members) => members,
          orElse: () => <PRFMember>[],
        );
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final errorMessage = state.maybeWhen(
          error: (message) => message,
          orElse: () => null,
        );
        final entries = members
            .map(
              (m) => PRFSearchableListEntry<String>(
                value: m.ulid,
                label: m.fullName,
              ),
            )
            .toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(
                    alpha: 0.05,
                  ),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
              ),
              child: Column(
                children: [
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildHeaderCard(theme)
                      .animate()
                      .slideY(begin: -0.3)
                      .fadeIn(
                        duration: PRFMotionTokens.enterShort,
                      ),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      PRFSpacingTokens.xl,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        PRFRadiusTokens.lg,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.1,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PRFFormSection(
                      icon: Icons.group_add_outlined,
                      title: 'Select Member',
                      subtitle:
                          'Search for a member to add '
                          'to this mission',
                      isRequired: true,
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: PRFSpacingTokens.md,
                              ),
                              child: PRFCircularProgressIndicator(),
                            )
                          else
                            PRFSearchableList<String>(
                              entries: entries,
                              onSelected: (value) {
                                setState(() {
                                  _selectedMemberUlid = value;
                                  _selectionError = null;
                                });
                              },
                              selection: _selectedMemberUlid,
                              hintText: 'Search member by name',
                              emptyText: 'No members found',
                            ),
                          if (_showValidation && _selectionError != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PRFSpacingTokens.xs,
                              ),
                              child: Text(
                                _selectionError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PRFSpacingTokens.sm,
                              ),
                              child: Text(
                                errorMessage,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          if (!isLoading && members.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: PRFSpacingTokens.sm,
                              ),
                              child: Text(
                                'No members found. '
                                'Refresh and try again.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(
                            height: PRFSpacingTokens.lg,
                          ),
                          _buildAddMissionerButton(theme),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: PRFPrimaryButton(
                      onPressed: _submit,
                      title: 'Subscribe Member',
                      disabled: isLoading || !_isFormValid,
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddMissionerButton(ThemeData theme) {
    return GestureDetector(
      onTap: _promptAddOfflineMember,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PRFRadiusTokens.full,
          ),
          border: Border.all(
            color: PRFColors.limeGreen.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              size: 16,
              color: PRFColors.limeGreen,
            ),
            const SizedBox(
              width: PRFSpacingTokens.xs,
            ),
            Text(
              'Add Offline Missioner',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: PRFColors.limeGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
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
            color: theme.colorScheme.primary.withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Subscribe Member',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Choose a fellowship member to '
            'join this mission',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: 0.9,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OfflineMemberFormBody extends StatefulWidget {
  const _OfflineMemberFormBody({required this.missionUlid});

  final String missionUlid;

  @override
  State<_OfflineMemberFormBody> createState() => _OfflineMemberFormBodyState();
}

class _OfflineMemberFormBodyState extends State<_OfflineMemberFormBody> {
  late final TextEditingController _nameController;
  late final PhoneController _phoneController;
  bool _showValidation = false;
  String? _nameError;

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.value.nsn.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController()..addListener(_onChanged);
    _phoneController = PhoneController(
      initialValue: const PhoneNumber(
        isoCode: IsoCode.KE,
        nsn: '',
      ),
    );
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() {
    if (_showValidation) {
      _validate();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();
    _phoneController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  bool _validate() {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.value.nsn.isNotEmpty;
    setState(() {
      _showValidation = true;
      _nameError = hasName ? null : 'Name is required';
    });
    return hasName && hasPhone;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fill in all required fields',
      );
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(
      PRFMissionOfflineMemberDTO(
        missionUlid: widget.missionUlid,
        name: _nameController.text.trim(),
        phone: _phoneController.value.international,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(
                alpha: 0.05,
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
                _buildHeaderCard(theme)
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(
                      duration: PRFMotionTokens.enterShort,
                    ),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        PRFSpacingTokens.xl,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          PRFRadiusTokens.lg,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PRFFormSection(
                            icon: Icons.person_outline,
                            title: 'Full Name',

                            isRequired: true,
                            margin: EdgeInsets.zero,
                            child: PRFTextInput(
                              hintText: 'Enter full name',
                              labelText: 'Full Name *',
                              helperText: 'Required',
                              controller: _nameController,
                              errorText: _showValidation ? _nameError : null,
                            ),
                          ),
                          const SizedBox(
                            height: PRFSpacingTokens.xl,
                          ),
                          PRFFormSection(
                            icon: Icons.phone_outlined,
                            title: 'Phone Number',

                            isRequired: true,
                            margin: EdgeInsets.zero,
                            child: PRFPhoneInput(
                              hintText: 'Enter phone number',
                              controller: _phoneController,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(
                      delay: PRFMotionTokens.stagger3,
                    )
                    .slideX(begin: -0.2)
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFPrimaryButton(
                    onPressed: _submit,
                    title: 'Add Missioner',
                    disabled: !_isFormValid,
                  ),
                ),
                const SizedBox(
                  height: PRFSpacingTokens.xxxl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(
              alpha: 0.8,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(
          PRFRadiusTokens.lg,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Add Missioner',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            "Add someone who isn't a "
            'registered member',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: 0.9,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MissionSoulFormBody extends StatefulWidget {
  const _MissionSoulFormBody({
    required this.missionUlid,
    required this.classGroups,
    required this.submitLabel,
    this.initialName,
    this.initialNote,
    this.initialClassGroupUlid,
    this.initialDecisionType = PRFSoulDecisionType.salvation,
  });

  final String missionUlid;
  final List<PRFClassGroup> classGroups;
  final String submitLabel;
  final String? initialName;
  final String? initialNote;
  final String? initialClassGroupUlid;
  final PRFSoulDecisionType initialDecisionType;

  @override
  State<_MissionSoulFormBody> createState() => _MissionSoulFormBodyState();
}

class _MissionSoulFormBodyState extends State<_MissionSoulFormBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  String? _selectedClassGroupUlid;
  late PRFSoulDecisionType _selectedDecisionType;
  String? _nameError;
  bool _showValidation = false;

  bool get _isFormValid {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasClassGroup =
        _selectedClassGroupUlid != null && _selectedClassGroupUlid!.isNotEmpty;
    return hasName && hasClassGroup;
  }

  bool _validate() {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasClassGroup =
        _selectedClassGroupUlid != null && _selectedClassGroupUlid!.isNotEmpty;

    setState(() {
      _showValidation = true;
      _nameError = hasName ? null : 'Name / Identifier is required';
    });

    return hasName && hasClassGroup;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, 'Please fill in all required fields');
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(
      PRFSoulDTO(
        fullName: _nameController.text.trim(),
        missionUlid: widget.missionUlid,
        classGroupUlid: _selectedClassGroupUlid!,
        decisionType: _selectedDecisionType.apiKey,
        notes: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_onChanged);
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedClassGroupUlid = widget.initialClassGroupUlid;
    _selectedDecisionType = widget.initialDecisionType;
  }

  void _onChanged() {
    if (_showValidation) {
      _validate();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
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
                _buildHeaderCard(theme)
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(duration: PRFMotionTokens.enterShort),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PRFFormSection(
                            icon: Icons.person_outline,
                            title: 'Name / Identifier',
                            isRequired: true,

                            margin: const EdgeInsets.only(
                              bottom: PRFSpacingTokens.md,
                            ),
                            child: PRFTextInput(
                              hintText: 'Enter a name or identifier',
                              labelText: 'Name / Identifier *',
                              helperText: 'Required',
                              errorText: _showValidation ? _nameError : null,
                              controller: _nameController,
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.class_outlined,
                            title: 'Class Group',
                            isRequired: true,

                            margin: const EdgeInsets.only(
                              bottom: PRFSpacingTokens.md,
                            ),
                            child: PRFSearchableList<String>(
                              entries: widget.classGroups
                                  .map(
                                    (group) => PRFSearchableListEntry<String>(
                                      value: group.ulid,
                                      label: group.name,
                                    ),
                                  )
                                  .toList(),
                              onSelected: (value) {
                                setState(() {
                                  _selectedClassGroupUlid = value;
                                });
                              },
                              selection: _selectedClassGroupUlid,
                              hintText: 'Search class group',
                              emptyText:
                                  'No class groups found for '
                                  'this school type',
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.favorite_outline,
                            title: 'Decision Type',
                            subtitle: 'Select one',
                            margin: const EdgeInsets.only(
                              bottom: PRFSpacingTokens.md,
                            ),
                            child: Wrap(
                              spacing: PRFSpacingTokens.sm,
                              runSpacing: PRFSpacingTokens.sm,
                              children: PRFSoulDecisionType.values.map((value) {
                                final isSelected =
                                    _selectedDecisionType == value;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDecisionType = value;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: PRFMotionTokens.standard,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: PRFSpacingTokens.lg,
                                      vertical: PRFSpacingTokens.sm,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(
                                        PRFRadiusTokens.xl,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      value.name,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.notes_outlined,
                            title: 'Notes',

                            margin: EdgeInsets.zero,
                            child: PRFTextAreaInput(
                              hintText: 'Optional details for follow-up',
                              labelText: 'Notes',
                              helperText: 'Optional',
                              controller: _noteController,
                            ),
                          ),
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
                    onPressed: _submit,
                    title: widget.submitLabel,
                    disabled: !_isFormValid,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
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
            Icons.volunteer_activism_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Record Soul',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Capture salvation decisions and follow-up details',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MissionSubscriberDetailsBody extends StatefulWidget {
  const _MissionSubscriberDetailsBody({required this.subscription});

  final PRFMissionSubscription subscription;

  @override
  State<_MissionSubscriberDetailsBody> createState() =>
      _MissionSubscriberDetailsBodyState();
}

class _MissionSubscriberDetailsBodyState
    extends State<_MissionSubscriberDetailsBody> {
  late PRFMissionSubscriptionStatus _selectedStatus;
  late PRFMissionRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.subscription.status;
    _selectedRole = widget.subscription.missionRole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = widget.subscription.member;

    return BlocListener<
      MissionSubscriptionResourceCubit,
      ResourceState<PRFMissionSubscription>
    >(
      listener: (context, state) {
        switch (state) {
          case ResourceMutating<PRFMissionSubscription>(:final operation)
              when operation == ResourceOperation.update:
            setState(() => _isLoading = true);
          case ResourceMutated<PRFMissionSubscription>(:final operation)
              when operation == ResourceOperation.update:
            setState(() => _isLoading = false);
            Gaimon.success();
            Navigator.of(context).pop(true);
            PRFSnackbar.success(context, 'Subscriber updated successfully');
          case ResourceError<PRFMissionSubscription>(:final message)
              when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.error();
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: PRFSpacingTokens.lg),
              _detailRow('Name', member?.fullName),
              _detailRow('Email', member?.email),
              _detailRow('Phone', member?.phoneNumber),
              _detailRow('Residence', member?.residence),
              _detailRow('Pastor', member?.pastor),
              const SizedBox(height: PRFSpacingTokens.md),
              _buildChipSelector<PRFMissionRole>(
                theme: theme,
                label: 'Role',
                icon: Icons.badge_outlined,
                values: PRFMissionRole.values,
                selected: _selectedRole,
                nameOf: (v) => v.name,
                onSelected: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              _buildChipSelector<PRFMissionSubscriptionStatus>(
                theme: theme,
                label: 'Status',
                icon: Icons.flag_outlined,
                values: PRFMissionSubscriptionStatus.values,
                selected: _selectedStatus,
                nameOf: (v) => v.name,
                onSelected: (v) => setState(() => _selectedStatus = v),
              ),
              const SizedBox(height: PRFSpacingTokens.xxl),
              SizedBox(
                width: double.infinity,
                child: PRFPrimaryButton(
                  onPressed: _submit,
                  title: 'Update Subscriber',
                  isLoading: _isLoading,
                  disabled:
                      _selectedStatus == widget.subscription.status &&
                      _selectedRole == widget.subscription.missionRole,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipSelector<T>({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required List<T> values,
    required T selected,
    required String Function(T) nameOf,
    required ValueChanged<T> onSelected,
  }) {
    return PRFFormSection(
      icon: icon,
      title: label,
      margin: EdgeInsets.zero,
      child: Wrap(
        spacing: PRFSpacingTokens.sm,
        runSpacing: PRFSpacingTokens.sm,
        children: values.map((value) {
          final isSelected = value == selected;
          return GestureDetector(
            onTap: _isLoading ? null : () => onSelected(value),
            child: AnimatedContainer(
              duration: PRFMotionTokens.standard,
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
                vertical: PRFSpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                nameOf(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _submit() async {
    final subscription = widget.subscription;

    await context.read<MissionSubscriptionResourceCubit>().updateSubscription(
      subscriptionUlid: subscription.ulid,
      dto: PRFMissionSubscriptionDTO(
        missionUlid: subscription.mission?.ulid ?? '',
        memberUlid: subscription.member?.ulid ?? '',
        status: _selectedStatus,
        missionRole: _selectedRole,
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    final safeValue = (value ?? '').trim();
    if (safeValue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(safeValue),
        ],
      ),
    );
  }
}
