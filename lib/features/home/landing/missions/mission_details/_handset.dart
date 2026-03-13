import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/missions/actions/edit_mission/edit_mission.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_debrief_note_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_question_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_soul_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_subscription_resource_cubit.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/mission_ground.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/models/remote/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_debrief_note.dart';
import 'package:leadership/models/remote/prf_mission_question.dart';
import 'package:leadership/models/remote/prf_mission_soul.dart';
import 'package:leadership/models/remote/prf_mission_subscription.dart';
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

  int tabCount = 8;

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
      ResourceMutated<PRFMission>(:final items) when items.isNotEmpty =>
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
      context.read<MissionDebriefNoteResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<MissionSoulResourceCubit>().loadForMission(
        missionUlid: missionUlid,
      ),
      context.read<MissionSubscriptionResourceCubit>().loadForMission(
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

  Future<String?> _showSimpleTextFormSheet({
    required String title,
    required String label,
    required String hintText,
    int maxLines = 4,
    bool isRequired = true,
    String? initialValue,
    String submitLabel = 'Save',
  }) async {
    return PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionSimpleTextFormSheet(
        label: label,
        hintText: hintText,
        maxLines: maxLines,
        isRequired: isRequired,
        initialValue: initialValue,
        submitLabel: submitLabel,
      ),
    );
  }

  Future<({String name, String? note})?> _showSoulFormSheet({
    required String title,
    required String submitLabel,
    String? initialName,
    String? initialNote,
  }) {
    return PRFBottomSheet.show<({String name, String? note})>(
      context,
      title: title,
      child: _MissionSoulFormSheet(
        initialName: initialName,
        initialNote: initialNote,
        submitLabel: submitLabel,
      ),
    );
  }

  Future<String?> _showMemberSubscriptionFormSheet() {
    context.read<GetMembersCubit>().getMembers();

    return PRFBottomSheet.show<String>(
      context,
      title: 'Subscribe Member',
      child: const _MissionMemberSubscriptionFormSheet(),
    );
  }

  Future<bool> _showDeleteConfirmation({
    required String title,
    String message = 'Are you sure you want to continue?',
  }) async {
    final shouldDelete = await PRFBottomSheet.show<bool>(
      context,
      title: title,
      child: _MissionConfirmationSheet(
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
    final questionText = await _showSimpleTextFormSheet(
      title: 'Add Question',
      label: 'Question',
      hintText: 'What did the students want to know?',
    );
    if (!mounted || questionText == null || questionText.isEmpty) return;

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.createQuestion(
      missionUlid: missionUlid,
      question: questionText,
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

    final updatedQuestion = await _showSimpleTextFormSheet(
      title: 'Edit Question',
      label: 'Question',
      hintText: 'What did the students want to know?',
      initialValue: question.question,
      submitLabel: 'Update',
    );
    if (!mounted || updatedQuestion == null || updatedQuestion.isEmpty) return;

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.updateQuestion(
      questionUlid: question.ulid,
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
    final noteText = await _showSimpleTextFormSheet(
      title: 'Add Debrief Note',
      label: 'Debrief Note',
      hintText: 'Capture what happened and what we learned.',
      maxLines: 6,
    );
    if (!mounted || noteText == null || noteText.isEmpty) return;

    final cubit = context.read<MissionDebriefNoteResourceCubit>();
    await cubit.createNote(missionUlid: missionUlid, note: noteText);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note added');
  }

  Future<void> _deleteDebriefNote(PRFMissionDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Debrief note cannot be deleted yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: 'Delete Debrief Note',
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionDebriefNoteResourceCubit>();
    await cubit.deleteNote(noteUlid: note.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note deleted');
  }

  Future<void> _promptEditDebriefNote(PRFMissionDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Debrief note cannot be edited yet');
      return;
    }

    final updatedNote = await _showSimpleTextFormSheet(
      title: 'Edit Debrief Note',
      label: 'Debrief Note',
      hintText: 'Capture what happened and what we learned.',
      maxLines: 6,
      initialValue: note.note,
      submitLabel: 'Update',
    );
    if (!mounted || updatedNote == null || updatedNote.isEmpty) return;

    final cubit = context.read<MissionDebriefNoteResourceCubit>();
    await cubit.updateNote(noteUlid: note.ulid, note: updatedNote);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Debrief note updated');
  }

  Future<void> _promptAddSoul() async {
    final soulData = await _showSoulFormSheet(
      title: 'Record Soul',
      submitLabel: 'Record',
    );
    if (!mounted || soulData == null || soulData.name.trim().isEmpty) return;

    final cubit = context.read<MissionSoulResourceCubit>();
    await cubit.createSoul(
      missionUlid: missionUlid,
      name: soulData.name.trim(),
      note: soulData.note,
    );
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Soul recorded');
  }

  Future<void> _deleteSoul(PRFMissionSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Soul cannot be deleted yet');
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(title: 'Delete Soul');
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionSoulResourceCubit>();
    await cubit.deleteSoul(soulUlid: soul.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, error);
      return;
    }
    PRFSnackbar.success(context, 'Soul deleted');
  }

  Future<void> _promptEditSoul(PRFMissionSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, 'Soul cannot be edited yet');
      return;
    }

    final updatedSoul = await _showSoulFormSheet(
      title: 'Edit Soul',
      submitLabel: 'Update',
      initialName: soul.name,
      initialNote: soul.note,
    );
    if (!mounted || updatedSoul == null || updatedSoul.name.trim().isEmpty) {
      return;
    }

    final cubit = context.read<MissionSoulResourceCubit>();
    await cubit.updateSoul(
      soulUlid: soul.ulid,
      name: updatedSoul.name.trim(),
      note: updatedSoul.note,
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
    final memberUlid = await _showMemberSubscriptionFormSheet();
    if (!mounted || memberUlid == null || memberUlid.trim().isEmpty) return;

    final cubit = context.read<MissionSubscriptionResourceCubit>();
    await cubit.subscribeMember(
      missionUlid: mission.ulid,
      memberUlid: memberUlid.trim(),
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
                          tabs: [
                            Tab(text: l10n.missionGround),
                            const Tab(text: 'People'),
                            const Tab(text: 'Questions'),
                            const Tab(text: 'Debrief'),
                            const Tab(text: 'Souls'),
                            const Tab(text: 'Operations'),
                            Tab(text: l10n.requisitions),
                            Tab(text: l10n.expenses),
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

                      if (state is ResourceListLoading<PRFMission>) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state case ResourceError<PRFMission>(
                        :final message,
                      )) {
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
                          MissionGroundView(mission: mission),
                          _buildMissionPeopleTab(mission),
                          _buildMissionQuestionsTab(),
                          _buildMissionDebriefTab(),
                          _buildMissionSoulsTab(),
                          _buildMissionOperationsTab(mission),
                          if (mission.accountingEvent != null)
                            RequisitionsView(
                              accountingEvent: mission.accountingEvent!,
                            )
                          else
                            PRFEmptyView(
                              label: l10n.requisitionUnavailable,
                              description: l10n.requisitionUnavailableDesc,
                            ),
                          if (mission.accountingEvent != null)
                            ExpensesView(
                              accountingEventUlid:
                                  mission.accountingEvent!.ulid,
                            )
                          else
                            PRFEmptyView(
                              label: l10n.expensesUnavailable,
                              description: l10n.expensesUnavailableDesc,
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
                0 when _canShowMissionActions() =>
                  FloatingActionButton.extended(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showMissionActions(mission),
                    label: const Text('Mission Actions'),
                  ),
                6 when Misc.userCan(PRFPermissions.createRequisition) =>
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

  Widget _buildMissionQuestionsTab() {
    return BlocBuilder<
      MissionQuestionResourceCubit,
      ResourceState<PRFMissionQuestion>
    >(
      builder: (context, state) {
        final questions = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return _buildMissionResourceTab(
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
                (question) => _buildMissionResourceCard(
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
    return BlocBuilder<
      MissionDebriefNoteResourceCubit,
      ResourceState<PRFMissionDebriefNote>
    >(
      builder: (context, state) {
        final notes = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return _buildMissionResourceTab(
          isLoading: state is ResourceListLoading<PRFMissionDebriefNote>,
          error: error,
          isEmpty: notes.isEmpty,
          onRefresh: () => context
              .read<MissionDebriefNoteResourceCubit>()
              .loadForMission(missionUlid: missionUlid),
          onAdd: _promptAddDebriefNote,
          addButtonLabel: 'Add Debrief Note',
          addButtonIcon: Icons.rate_review_outlined,
          emptyLabel: 'No debrief notes yet',
          emptyDescription:
              'Capture reflection notes from the mission team here.',
          items: notes
              .map(
                (note) => _buildMissionResourceCard(
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

  Widget _buildMissionSoulsTab() {
    return BlocBuilder<MissionSoulResourceCubit, ResourceState<PRFMissionSoul>>(
      builder: (context, state) {
        final souls = _itemsFromResourceState(state);
        final error = _resourceErrorMessage(state);

        return _buildMissionResourceTab(
          isLoading: state is ResourceListLoading<PRFMissionSoul>,
          error: error,
          isEmpty: souls.isEmpty,
          onRefresh: () =>
              context.read<MissionSoulResourceCubit>().loadForMission(
                missionUlid: missionUlid,
              ),
          onAdd: _promptAddSoul,
          addButtonLabel: 'Record Soul',
          addButtonIcon: Icons.favorite_outline,
          emptyLabel: 'No souls recorded yet',
          emptyDescription: 'Souls recorded during ministry will appear here.',
          items: souls
              .map(
                (soul) => _buildMissionResourceCard(
                  title: soul.name,
                  subtitle: soul.note?.trim().isNotEmpty ?? false
                      ? soul.note
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

  Widget _buildMissionResourceTab({
    required bool isLoading,
    required String? error,
    required bool isEmpty,
    required Future<void> Function() onRefresh,
    required VoidCallback onAdd,
    required String addButtonLabel,
    required IconData addButtonIcon,
    required String emptyLabel,
    required String emptyDescription,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);

    if (isLoading && isEmpty) {
      return const Center(child: PRFCircularProgressIndicator());
    }

    if (error != null && isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: PRFSpacingTokens.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.xl,
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          PRFSpacingTokens.lg,
          PRFSpacingTokens.lg,
          PRFSpacingTokens.lg,
          PRFSpacingTokens.xxxl,
        ),
        children: [
          _buildMissionSectionCard(
            title: 'Mission Records',
            subtitle: emptyDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: Icon(addButtonIcon),
                  label: Text(addButtonLabel),
                ),
                const SizedBox(height: PRFSpacingTokens.md),
                if (error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
                    padding: const EdgeInsets.all(PRFSpacingTokens.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    ),
                    child: Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                if (isEmpty)
                  PRFEmptyView(label: emptyLabel, description: emptyDescription)
                else
                  ...items,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          child,
        ],
      ),
    );
  }

  Widget _buildMissionResourceCard({
    required String title,
    required String? subtitle,
    required String editTooltip,
    required VoidCallback onEdit,
    required String deleteTooltip,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.sm),
            Tooltip(
              message: editTooltip,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.sm,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
                  ),
                  child: Text(
                    'Edit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.xs),
            Tooltip(
              message: deleteTooltip,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionPeopleTab(PRFMission mission) {
    final theme = Theme.of(context);
    final capacity = mission.capacity;
    final registrationsOpen = mission.missionSubscriptionsNeeded;
    final filled = (capacity - registrationsOpen).clamp(0, capacity);
    final progress = capacity == 0 ? 0.0 : filled / capacity;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Capacity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _peopleMetric(
                        label: 'Capacity',
                        value: '$capacity',
                        icon: Icons.groups_rounded,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.md),
                    Expanded(
                      child: _peopleMetric(
                        label: 'Filled',
                        value: '$filled',
                        icon: Icons.person_add_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.md),
                    Expanded(
                      child: _peopleMetric(
                        label: 'Open',
                        value: '$registrationsOpen',
                        icon: Icons.pending_actions_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xl),
                _buildMissionSubscriptionsSection(mission),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% filled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xl),
          Text(
            'People Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          _operationTile(
            icon: Icons.forum_outlined,
            title: 'Notify WhatsApp Group',
            subtitle: 'Send mission update to missionaries',
            onTap: () => _runMissionAction(
              successMessage: 'WhatsApp group notified successfully',
              action: () => context
                  .read<MissionResourceCubit>()
                  .notifyWhatsappGroup(missionUlid: mission.ulid),
            ),
          ),
          _operationTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notify School',
            subtitle: 'Send an update to school contacts',
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
        ],
      ),
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
        final theme = Theme.of(context);

        return _buildMissionSectionCard(
          title: 'Mission Subscriptions',
          subtitle: 'Manage members subscribed to this mission.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('${subscriptions.length} subscribed')),
                  FilledButton.icon(
                    onPressed: () => _promptSubscribeMember(mission),
                    icon: const Icon(Icons.person_add_alt_rounded),
                    label: const Text('Subscribe Member'),
                  ),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              if (error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
                  padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  ),
                  child: Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              if (subscriptions.isEmpty)
                const PRFEmptyView(
                  label: 'No subscriptions yet',
                  description:
                      'Subscribe members to this mission from the people tab.',
                )
              else
                ...subscriptions.map(
                  (subscription) => _buildMissionSubscriptionCard(
                    mission: mission,
                    subscription: subscription,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionSubscriptionCard({
    required PRFMission mission,
    required PRFMissionSubscription subscription,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Subscribed ${_formatDate(subscription.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove subscription',
              onPressed: () => _unsubscribeMember(
                mission: mission,
                subscription: subscription,
              ),
              icon: Icon(
                Icons.person_remove_alt_1,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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

  bool _canShowMissionActions() {
    return true;
  }

  void _showMissionActions(PRFMission mission) {
    final isMutating = _isMissionMutating;

    PRFBottomSheet.show<void>(
      context,
      title: 'Mission Actions',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: PRFSpacingTokens.sm),
            if (_canApproveMission(mission))
              _buildMissionActionTile(
                icon: Icons.verified_outlined,
                title: 'Approve Mission',
                subtitle: 'Mark mission as approved',
                onTap: () => _runMissionAction(
                  successMessage: 'Mission approved successfully',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .approveMission(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canRejectMission(mission))
              _buildMissionActionTile(
                icon: Icons.close_rounded,
                title: 'Reject Mission',
                subtitle: 'Reject this mission request',
                onTap: () => _rejectMission(mission),
                enabled: !isMutating,
              ),
            if (_canCancelMission(mission))
              _buildMissionActionTile(
                icon: Icons.event_busy_outlined,
                title: 'Cancel Mission',
                subtitle: 'Cancel this mission',
                onTap: () => _cancelMission(mission),
                enabled: !isMutating,
              ),
            if (_canCompleteMission(mission))
              _buildMissionActionTile(
                icon: Icons.task_alt_outlined,
                title: 'Complete Mission',
                subtitle: 'Mark mission as serviced',
                onTap: () => _confirmCompleteMission(mission),
                enabled: !isMutating,
              ),
            if (_canNotifySchool(mission))
              _buildMissionActionTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notify School',
                subtitle: 'Send mission notification to school',
                onTap: () => _runMissionAction(
                  successMessage: 'School notified successfully',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .notifySchool(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canRequestFeedback(mission))
              _buildMissionActionTile(
                icon: Icons.rate_review_outlined,
                title: 'Request School Feedback',
                subtitle: 'Ask school for mission feedback',
                onTap: () => _runMissionAction(
                  successMessage: 'Feedback requested successfully',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .requestSchoolFeedback(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canNotifyWhatsapp(mission))
              _buildMissionActionTile(
                icon: Icons.forum_outlined,
                title: 'Notify WhatsApp Group',
                subtitle: 'Send mission update to WhatsApp group',
                onTap: () => _runMissionAction(
                  successMessage: 'WhatsApp group notified successfully',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .notifyWhatsappGroup(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canGenerateSummary(mission))
              _buildMissionActionTile(
                icon: Icons.summarize_outlined,
                title: 'Generate Summary',
                subtitle: 'Generate mission summary',
                onTap: () => _runMissionAction(
                  successMessage: 'Mission summary generated successfully',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .generateSummary(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canUploadMedia(mission))
              _buildMissionActionTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Upload Media To Drive',
                subtitle: 'Upload mission media to Google Drive',
                onTap: () => _runMissionAction(
                  successMessage: 'Mission media upload started',
                  action: () => context
                      .read<MissionResourceCubit>()
                      .uploadMediaToDrive(missionUlid: mission.ulid),
                ),
                enabled: !isMutating,
              ),
            if (_canMakeZeroRequisition(mission))
              _buildMissionActionTile(
                icon: Icons.receipt_long_outlined,
                title: 'Make Zero Requisition',
                subtitle: 'Create a zero-value requisition for this mission',
                onTap: () => _confirmMakeZeroRequisition(mission),
                enabled: !isMutating,
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Mission'),
              subtitle: const Text('Update mission details'),
              onTap: () {
                Navigator.of(context).pop();
                PRFBottomSheet.show<void>(
                  context,
                  title: 'Edit Mission',
                  child: EditMissionView(mission: mission),
                ).then((_) {
                  if (!mounted) return;
                  context.read<MissionResourceCubit>().loadMission(
                    missionUlid: mission.ulid,
                  );
                });
              },
              enabled: !isMutating,
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Mission',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text('Remove this mission permanently'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDeleteMission(mission);
              },
              enabled: !isMutating,
            ),
            if (isMutating)
              Padding(
                padding: const EdgeInsets.only(top: PRFSpacingTokens.sm),
                child: Text(
                  'Please wait, mission action in progress...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: PRFSpacingTokens.sm),
          ],
        ),
      ),
    );
  }

  ListTile _buildMissionActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: enabled,
      onTap: enabled
          ? () {
              Navigator.of(context).pop();
              onTap();
            }
          : null,
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
      child: _MissionConfirmationSheet(
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
    final reasonInput = await _promptReason(
      title: 'Reject Mission',
      hintText: 'Optional reason',
      confirmLabel: 'Reject',
    );
    if (!mounted || reasonInput == null) return;

    await _runMissionAction(
      successMessage: 'Mission rejected successfully',
      action: () => context.read<MissionResourceCubit>().rejectMission(
        missionUlid: mission.ulid,
        reason: reasonInput.reason,
      ),
    );
  }

  Future<void> _cancelMission(PRFMission mission) async {
    final reasonInput = await _promptReason(
      title: 'Cancel Mission',
      hintText: 'Optional reason',
      confirmLabel: 'Cancel Mission',
    );
    if (!mounted || reasonInput == null) return;

    await _runMissionAction(
      successMessage: 'Mission cancelled successfully',
      action: () => context.read<MissionResourceCubit>().cancelMission(
        missionUlid: mission.ulid,
        reason: reasonInput.reason,
      ),
    );
  }

  Future<_MissionReasonInput?> _promptReason({
    required String title,
    required String hintText,
    required String confirmLabel,
  }) async {
    final result = await PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionSimpleTextFormSheet(
        label: 'Reason',
        hintText: hintText,
        maxLines: 3,
        isRequired: false,
        submitLabel: confirmLabel,
      ),
    );

    if (result == null) {
      return null;
    }

    return _MissionReasonInput(reason: result.trim().isEmpty ? null : result);
  }

  bool _canApproveMission(PRFMission mission) {
    return true;
  }

  bool _canRejectMission(PRFMission mission) {
    return true;
  }

  bool _canCancelMission(PRFMission mission) {
    return true;
  }

  bool _canCompleteMission(PRFMission mission) {
    return true;
  }

  bool _canNotifySchool(PRFMission mission) {
    return true;
  }

  bool _canRequestFeedback(PRFMission mission) {
    return true;
  }

  bool _canNotifyWhatsapp(PRFMission mission) {
    return true;
  }

  bool _canGenerateSummary(PRFMission mission) {
    return true;
  }

  bool _canUploadMedia(PRFMission mission) {
    return true;
  }

  bool _canMakeZeroRequisition(PRFMission mission) {
    return true;
  }

  Future<void> _confirmDeleteMission(PRFMission mission) async {
    final shouldDelete = await _showDeleteConfirmation(
      title: 'Delete Mission',
      message:
          'Are you sure you want to delete this mission? '
          'This cannot be undone.',
    );

    if (!shouldDelete || !mounted) return;

    await context.read<MissionResourceCubit>().deleteMission(
      missionUlid: mission.ulid,
    );

    if (!mounted) return;
    PRFSnackbar.success(context, 'Mission deleted successfully');
    context.router.popUntilRouteWithPath(PRFLeadershipRouter.missionsRoute);
  }
}

class _MissionReasonInput {
  const _MissionReasonInput({this.reason});

  final String? reason;
}

class _MissionConfirmationSheet extends StatelessWidget {
  const _MissionConfirmationSheet({
    required this.message,
    required this.confirmLabel,
    this.destructive = false,
  });

  final String message;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        const SizedBox(height: PRFSpacingTokens.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      )
                    : null,
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MissionMemberSubscriptionFormSheet extends StatefulWidget {
  const _MissionMemberSubscriptionFormSheet();

  @override
  State<_MissionMemberSubscriptionFormSheet> createState() =>
      _MissionMemberSubscriptionFormSheetState();
}

class _MissionMemberSubscriptionFormSheetState
    extends State<_MissionMemberSubscriptionFormSheet> {
  String? _selectedMemberUlid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetMembersCubit, GetMembersState>(
      builder: (context, state) {
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MissionSheetSection(
              title: 'Subscription',
              subtitle: 'Choose a member to add to this mission',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PRFFormFieldLabel(label: 'Member', isRequired: true),
                  const SizedBox(height: PRFSpacingTokens.xs),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: PRFSpacingTokens.md,
                      ),
                      child: PRFCircularProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMemberUlid,
                      decoration: const InputDecoration(
                        hintText: 'Select a member',
                        helperText: 'Only active members are shown',
                      ),
                      items: members
                          .map<DropdownMenuItem<String>>(
                            (member) => DropdownMenuItem<String>(
                              value: member.ulid,
                              child: Text(member.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMemberUlid = value;
                        });
                      },
                    ),
                  const SizedBox(height: PRFSpacingTokens.md),
                  if (errorMessage != null)
                    Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (!isLoading && members.isEmpty)
                    Text(
                      'No members found. Refresh and try again.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedMemberUlid == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedMemberUlid),
                child: const Text('Subscribe'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MissionSimpleTextFormSheet extends StatefulWidget {
  const _MissionSimpleTextFormSheet({
    required this.label,
    required this.hintText,
    required this.submitLabel,
    this.maxLines = 4,
    this.isRequired = true,
    this.initialValue,
  });

  final String label;
  final String hintText;
  final String submitLabel;
  final int maxLines;
  final bool isRequired;
  final String? initialValue;

  @override
  State<_MissionSimpleTextFormSheet> createState() =>
      _MissionSimpleTextFormSheetState();
}

class _MissionSimpleTextFormSheetState
    extends State<_MissionSimpleTextFormSheet> {
  late final TextEditingController _controller;

  bool get _canSubmit {
    if (!widget.isRequired) {
      return true;
    }

    return _controller.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '')
      ..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionSheetSection(
          title: widget.label,
          subtitle: widget.isRequired
              ? 'This field is required'
              : 'This field is optional',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFFormFieldLabel(
                label: widget.label,
                isRequired: widget.isRequired,
              ),
              if (widget.maxLines > 1)
                PRFTextAreaInput(
                  hintText: widget.hintText,
                  controller: _controller,
                )
              else
                PRFTextInput(
                  hintText: widget.hintText,
                  controller: _controller,
                ),
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canSubmit
                ? () => Navigator.of(context).pop(_controller.text.trim())
                : null,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}

class _MissionSoulFormSheet extends StatefulWidget {
  const _MissionSoulFormSheet({
    required this.submitLabel,
    this.initialName,
    this.initialNote,
  });

  final String submitLabel;
  final String? initialName;
  final String? initialNote;

  @override
  State<_MissionSoulFormSheet> createState() => _MissionSoulFormSheetState();
}

class _MissionSoulFormSheetState extends State<_MissionSoulFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_onChanged);
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  void _onChanged() => setState(() {});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionSheetSection(
          title: 'Soul Record',
          subtitle: 'Capture a decision and follow-up note',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PRFFormFieldLabel(
                label: 'Name / Identifier',
                isRequired: true,
              ),
              PRFTextInput(
                hintText: 'Enter a name or identifier',
                controller: _nameController,
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              const PRFFormFieldLabel(label: 'Decision Note'),
              PRFTextAreaInput(
                hintText: 'Optional details for follow-up',
                controller: _noteController,
              ),
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canSubmit
                ? () => Navigator.of(context).pop((
                    name: _nameController.text.trim(),
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  ))
                : null,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}

class _MissionSheetSection extends StatelessWidget {
  const _MissionSheetSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: PRFSpacingTokens.md),
          child,
        ],
      ),
    );
  }
}
