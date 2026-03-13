import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/enums/prf_soul_decision_type.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/debrief_note_resource_cubit.dart';
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
import 'package:leadership/features/home/landing/missions/mission_details/widgets/sheets.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/mission/prf_mission_question.dart';
import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription_dto.dart';
import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/models/remote/mission/prf_soul_dto.dart';
import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/models/remote/prf_debrief_note.dart';
import 'package:leadership/shared_views/expenses/expenses.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition/create_requisition.dart';
import 'package:leadership/shared_views/requisitions/requisitions.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
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

  void _changeTab() {
    setState(() {
      _currentTab = _tabController.index;
    });
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
    ]);
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
      child: MissionQuestionFormSheet(
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
      child: MissionDebriefNoteFormSheet(
        initialValue: initialValue,
        submitLabel: submitLabel,
      ),
    );
  }

  List<PRFClassGroup> _availableClassGroups() {
    final sessions = _itemsFromResourceState(
      context.read<MissionSessionResourceCubit>().state,
    );

    final byUlid = <String, PRFClassGroup>{};
    for (final session in sessions) {
      final group = session.classGroup;
      if (group == null || group.ulid.isEmpty) {
        continue;
      }
      byUlid[group.ulid] = group;
    }

    final result = byUlid.values.toList()
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
      child: MissionSoulFormSheet(
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

  Future<PRFMissionSubscriptionDTO?> _showMemberSubscriptionFormSheet() {
    context.read<GetMembersCubit>().getMembers();

    return PRFBottomSheet.show<PRFMissionSubscriptionDTO>(
      context,
      title: 'Subscribe Member',
      child: MissionMemberSubscriptionFormSheet(missionUlid: missionUlid),
    );
  }

  Future<bool> _showDeleteConfirmation({
    required String title,
    String message = 'Are you sure you want to continue?',
  }) async {
    final shouldDelete = await PRFBottomSheet.show<bool>(
      context,
      title: title,
      child: MissionConfirmationSheet(
        message: message,
        confirmLabel: 'Delete',
        destructive: true,
      ),
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
        'No class groups found. Add a mission session with class group first.',
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
    final subscriptionData = await _showMemberSubscriptionFormSheet();
    if (!mounted || subscriptionData == null) return;

    final cubit = context.read<MissionSubscriptionResourceCubit>();
    await cubit.subscribeMember(
      missionUlid: mission.ulid,
      memberUlid: subscriptionData.memberUlid,
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
      child: MissionSubscriberDetailsSheet(subscription: subscription),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
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
                          final isBusy = state is ResourceMutating<PRFMission>;
                          if (isBusy) {
                            return const SizedBox.square(
                              dimension: 20,
                              child: PRFCircularProgressIndicator(),
                            );
                          }

                          return IconButton(
                            tooltip: 'Refresh mission',
                            onPressed: () => context
                                .read<MissionResourceCubit>()
                                .loadMission(missionUlid: missionUlid),
                            icon: Icon(
                              Icons.refresh_rounded,
                              color: theme.colorScheme.onPrimary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: PRFSpacingTokens.lg),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PRFSpacingTokens.lg,
                      0,
                      PRFSpacingTokens.lg,
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
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.65),
                          indicatorColor: theme.colorScheme.secondary,
                          dividerColor: theme.colorScheme.onPrimary.withValues(
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
                  BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
                    builder: (context, state) {
                      final mission = _currentMissionFromState(state);

                      if (state is ResourceListLoading<PRFMission> &&
                          mission == null) {
                        return const Center(child: CircularProgressIndicator());
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          OverviewMissionDetailsSection(
                            missionGround: MissionGroundView(mission: mission),
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
                            requisitions: _buildMissionRequisitionsTab(mission),
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
                        PRFSnackbar.error(context, l10n.requisitionUnavailable);
                      }
                    },
                    label: Text(l10n.createRequisition),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
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
    return PRFBottomSheet.show<bool>(
      context,
      title: title,
      child: MissionConfirmationSheet(
        message: content,
        confirmLabel: confirmLabel,
      ),
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
      child: MissionReasonFormSheet(
        hintText: hintText,
        submitLabel: confirmLabel,
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
