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
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/missions/actions/edit_mission/edit_mission.dart';
import 'package:leadership/features/missions/cubit/class_group_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/debrief_note_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_detail_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_offline_member_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_question_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_session_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/mission_subscription_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/soul_resource_cubit.dart';
import 'package:leadership/features/missions/mission_details/widgets/feedback_data_section.dart';
import 'package:leadership/features/missions/mission_details/widgets/finance_section.dart';
import 'package:leadership/features/missions/mission_details/widgets/mission_ground/mission_ground.dart';
import 'package:leadership/features/missions/mission_details/widgets/overview_section.dart';
import 'package:leadership/features/missions/mission_details/widgets/people_data_section.dart';
import 'package:leadership/features/missions/mission_details/widgets/record_sections.dart';
import 'package:leadership/features/missions/widgets/mission_selectable_chip.dart';
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
import 'package:leadership/shared/expenses/expenses.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_requisition/create_requisition.dart';
import 'package:leadership/shared/requisitions/requisitions.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/router/router.dart';
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

  // Indices follow the TabBar order: Overview, People, Feedback, Finance.
  // Sessions live inside People (nested tab) and load with it; debrief notes,
  // souls and questions live inside Feedback.
  static const int _peopleTab = 1;
  static const int _feedbackTab = 2;

  final Set<int> _loadedTabs = {};

  void _ensureTabLoaded(int index) {
    if (!_loadedTabs.add(index)) return;
    final ulid = missionUlid;
    switch (index) {
      case _peopleTab:
        context.read<MissionSubscriptionResourceCubit>().loadForMission(
          missionUlid: ulid,
        );
        context.read<MissionOfflineMemberResourceCubit>().loadForMission(
          missionUlid: ulid,
        );
        context.read<MissionSessionResourceCubit>().loadForMission(
          missionUlid: ulid,
        );
      case _feedbackTab:
        context.read<MissionQuestionResourceCubit>().loadForMission(
          missionUlid: ulid,
        );
        context.read<DebriefNoteResourceCubit>().loadForMission(
          missionUlid: ulid,
        );
        context.read<SoulResourceCubit>().loadForMission(missionUlid: ulid);
        // Class groups are only used by souls (Feedback tab).
        final mission = _currentMissionFromState(
          context.read<MissionDetailCubit>().state,
        );
        if (mission != null) {
          _loadClassGroupsForMission(mission);
        }
    }
  }

  PRFInstitutionType? _loadedClassGroupInstitutionType;

  void _changeTab() {
    setState(() {
      _currentTab = _tabController.index;
    });
    // TabController notifies twice per animated change; load once.
    if (_tabController.indexIsChanging) return;
    _ensureTabLoaded(_tabController.index);
  }

  Future<void> _showEditMissionSheet(PRFMission mission) async {
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.mdEditMission,
      child: EditMissionView(mission: mission),
    );
  }

  @override
  void initState() {
    super.initState();

    // Mission lists carry a lean payload, so always fetch the full mission
    // (contacts, accounting event, weather) once on open. The cached copy
    // still renders immediately through the Hive watch.
    context.read<MissionDetailCubit>().loadOne(
      id: missionUlid,
      matchById: (m) => m.ulid == missionUlid,
      refresh: true,
    );

    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_changeTab);
    _ensureTabLoaded(_tabController.index);
  }

  PRFMission? _currentMissionFromState(ResourceState<PRFMission> state) {
    // `itemLoading` keeps the cached mission on screen while the on-open
    // refresh runs. The cubit is app-scoped, so its item may still be the
    // previously viewed mission; only show it when it is this one.
    return state.mapOrNull(
      itemLoaded: (s) => s.item,
      itemError: (s) => s.item,
      itemLoading: (s) => s.item?.ulid == missionUlid ? s.item : null,
    );
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_changeTab)
      ..dispose();
    super.dispose();
  }

  /// Pull-to-refresh: forget freshness so every sub-cubit refetches.
  Future<void> _refreshMissionSubdomainData() {
    context.read<MissionQuestionResourceCubit>().invalidate();
    context.read<DebriefNoteResourceCubit>().invalidate();
    context.read<SoulResourceCubit>().invalidate();
    context.read<MissionSubscriptionResourceCubit>().invalidate();
    context.read<MissionSessionResourceCubit>().invalidate();
    context.read<MissionOfflineMemberResourceCubit>().invalidate();
    return _loadMissionSubdomainData();
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

  /// The sub-resource cubits are app-global, so right after opening another
  /// mission they still hold the previous mission's rows. Every builder
  /// filters by this mission's ulid so those rows are never painted here.
  List<T> _itemsFromResourceState<T>(ResourceState<T> state) {
    return state.maybeWhen(
      listLoaded: (items, _, _) => items,
      mutating: (items, _) => items,
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
    String? submitLabel,
  }) {
    final l10n = context.l10n;
    return PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionTextFormBody(
        title: l10n.mdQuestion,
        subtitle: l10n.mdQuestionSubtitle,
        labelText: l10n.mdQuestion,
        helperText: l10n.mdRequired,
        validationErrorText: l10n.mdQuestionRequired,
        hintText: l10n.addQuestionDesc,
        isRequired: true,
        initialValue: initialValue,
        submitLabel: submitLabel ?? l10n.mdSave,
      ),
    );
  }

  Future<String?> _showDebriefNoteFormSheet({
    required String title,
    String? initialValue,
    String? submitLabel,
  }) {
    final l10n = context.l10n;
    return PRFBottomSheet.show<String>(
      context,
      title: title,
      child: _MissionTextFormBody(
        title: l10n.mdDebriefNote,
        subtitle: l10n.mdDebriefNoteSubtitle,
        labelText: l10n.mdDebriefNote,
        helperText: l10n.mdRequired,
        validationErrorText: l10n.mdDebriefNoteRequired,
        hintText: l10n.mdDebriefNoteHint,
        isRequired: true,
        minLines: 4,
        maxLines: 8,
        initialValue: initialValue,
        submitLabel: submitLabel ?? l10n.mdSave,
      ),
    );
  }

  Future<List<PRFClassGroup>> _availableClassGroups() async {
    final mission = _currentMissionFromState(
      context.read<MissionDetailCubit>().state,
    );
    final missionInstitutionType = mission?.school?.institutionType;
    final cubit = context.read<ClassGroupResourceCubit>();

    List<PRFClassGroup> usable(List<PRFClassGroup> groups) {
      final result =
          groups
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

    // Class groups are persisted locally (Hive). The cubit's in-memory state
    // may not yet be populated (e.g. the mission/active load is still in
    // flight) or may only hold groups for a different institution type. So
    // whenever the filtered result is empty, fall back to the authoritative
    // local cache — regardless of what the raw in-memory list contains.
    var classGroups = usable(_itemsFromResourceState(cubit.state));
    if (classGroups.isEmpty) {
      try {
        classGroups = usable(await cubit.loadCachedList());
      } catch (_) {
        classGroups = const [];
      }
    }

    // Last resort: kick off the active load (cache-first, background API
    // refresh) so the correct groups for this mission's institution type are
    // available on the next attempt, then re-read from the local cache.
    if (classGroups.isEmpty) {
      if (missionInstitutionType != null) {
        await cubit.loadActiveForInstitutionType(missionInstitutionType);
      } else {
        await cubit.loadActive();
      }
      try {
        classGroups = usable(await cubit.loadCachedList());
      } catch (_) {
        classGroups = const [];
      }
    }

    return classGroups;
  }

  Future<PRFSoulDTO?> _showSoulFormSheet({
    required String title,
    required String submitLabel,
    String? initialName,
    String? initialNote,
    String? initialClassGroupUlid,
    PRFSoulDecisionType initialDecisionType = PRFSoulDecisionType.salvation,
  }) async {
    return await PRFBottomSheet.show<PRFSoulDTO>(
      context,
      title: title,
      child: _MissionSoulFormBody(
        missionUlid: missionUlid,
        classGroups: await _availableClassGroups(),
        initialName: initialName,
        initialNote: initialNote,
        initialClassGroupUlid: initialClassGroupUlid,
        initialDecisionType: initialDecisionType,
        submitLabel: submitLabel,
      ),
    );
  }

  Future<Object?> _showMemberSubscriptionFormSheet() {
    context.read<MemberResourceCubit>().getMembers();

    return PRFBottomSheet.show<Object>(
      context,
      title: context.l10n.missionSubscribeMember,
      child: _MissionMemberSubscriptionFormBody(missionUlid: missionUlid),
    );
  }

  Future<bool> _showDeleteConfirmation({
    required String title,
    String? message,
    String? confirmLabel,
  }) async {
    final shouldDelete = await PRFConfirmationDialog.show(
      context,
      title: title,
      message: message ?? context.l10n.mdConfirmContinue,
      confirmLabel: confirmLabel ?? context.l10n.delete,
      isDestructive: true,
    );

    return shouldDelete ?? false;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return context.l10n.mdUnknownDate;
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Future<void> _promptAddQuestion() async {
    final questionValue = await _showQuestionFormSheet(
      title: context.l10n.mdAddQuestion,
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
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdQuestionRecorded);
  }

  Future<void> _deleteQuestion(PRFMissionQuestion question) async {
    final questionUlid = question.ulid;
    if (questionUlid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: context.l10n.mdDeleteQuestion,
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionQuestionResourceCubit>();
    await cubit.deleteQuestion(questionUlid: questionUlid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdQuestionDeleted);
  }

  Future<void> _promptEditQuestion(PRFMissionQuestion question) async {
    if (question.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final updatedQuestion = await _showQuestionFormSheet(
      title: context.l10n.mdEditQuestion,
      initialValue: question.question,
      submitLabel: context.l10n.mdUpdate,
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
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdQuestionUpdated);
  }

  Future<void> _promptAddDebriefNote() async {
    final noteValue = await _showDebriefNoteFormSheet(
      title: context.l10n.addDebriefNote,
    );
    if (!mounted || noteValue == null || noteValue.isEmpty) return;

    final cubit = context.read<DebriefNoteResourceCubit>();
    await cubit.createNote(missionUlid: missionUlid, note: noteValue);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdDebriefNoteAdded);
  }

  Future<void> _deleteDebriefNote(PRFDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: context.l10n.mdDeleteDebriefNote,
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<DebriefNoteResourceCubit>();
    await cubit.deleteNote(noteUlid: note.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdDebriefNoteDeleted);
  }

  Future<void> _promptEditDebriefNote(PRFDebriefNote note) async {
    if (note.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final updatedNote = await _showDebriefNoteFormSheet(
      title: context.l10n.mdEditDebriefNote,
      initialValue: note.note,
      submitLabel: context.l10n.mdUpdate,
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
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdDebriefNoteUpdated);
  }

  Future<void> _promptAddSoul() async {
    final classGroups = await _availableClassGroups();
    if (classGroups.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNoClassGroups);
      return;
    }

    final soulData = await _showSoulFormSheet(
      title: context.l10n.mdRecordSoul,
      submitLabel: context.l10n.record,
    );
    if (!mounted || soulData == null || soulData.fullName.trim().isEmpty) {
      return;
    }

    final cubit = context.read<SoulResourceCubit>();
    await cubit.createSoul(dto: soulData);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdSoulRecorded);
  }

  Future<void> _deleteSoul(PRFSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: context.l10n.mdDeleteSoul,
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<SoulResourceCubit>();
    await cubit.deleteSoul(soulUlid: soul.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdSoulDeleted);
  }

  Future<void> _promptEditSoul(PRFSoul soul) async {
    if (soul.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final updatedSoul = await _showSoulFormSheet(
      title: context.l10n.mdEditSoul,
      submitLabel: context.l10n.mdUpdate,
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
    await cubit.updateSoul(soulUlid: soul.ulid, dto: updatedSoul);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }
    PRFSnackbar.success(context, context.l10n.mdSoulUpdated);
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
        PRFSnackbar.error(context, context.l10n.mdActionFailed);
        return;
      }

      await context.read<MissionDetailCubit>().loadOne(
        id: mission.ulid,
        matchById: (m) => m.ulid == mission.ulid,
      );
      if (!mounted) return;

      PRFSnackbar.success(context, context.l10n.mdMemberSubscribed);
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
        PRFSnackbar.error(context, context.l10n.mdActionFailed);
        return;
      }

      await context.read<MissionDetailCubit>().loadOne(
        id: mission.ulid,
        matchById: (m) => m.ulid == mission.ulid,
      );
      if (!mounted) return;

      PRFSnackbar.success(context, context.l10n.mdMissionerAdded);
    }
  }

  Future<void> _unsubscribeMember({
    required PRFMission mission,
    required PRFMissionSubscription subscription,
  }) async {
    if (subscription.ulid.isEmpty) {
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: context.l10n.mdRemoveSubscription,
      confirmLabel: context.l10n.missionRemove,
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionSubscriptionResourceCubit>();
    await cubit.unsubscribeMember(subscriptionUlid: subscription.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }

    await context.read<MissionDetailCubit>().loadOne(
      id: mission.ulid,
      matchById: (m) => m.ulid == mission.ulid,
    );
    if (!mounted) return;

    PRFSnackbar.success(context, context.l10n.mdSubscriptionRemoved);
  }

  Future<void> _viewSubscriberDetails(PRFMissionSubscription subscription) {
    return PRFBottomSheet.show<void>(
      context,
      title: context.l10n.mdSubscriberDetails,
      child: _MissionSubscriberDetailsBody(subscription: subscription),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocListener<MissionDetailCubit, ResourceState<PRFMission>>(
      listener: (context, state) {
        final mission = _currentMissionFromState(state);
        // Class groups are needed only once the Feedback tab has been shown.
        if (mission != null && _loadedTabs.contains(_feedbackTab)) {
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
                          MissionDetailCubit,
                          ResourceState<PRFMission>
                        >(
                          builder: (context, state) {
                            final isBusy =
                                state is ResourceItemLoading<PRFMission>;
                            if (isBusy) {
                              return const SizedBox.square(
                                dimension: PRFSizeTokens.iconMd,
                                child: PRFCircularProgressIndicator(),
                              );
                            }

                            final mission = context
                                .read<MissionDetailCubit>()
                                .currentItem;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (mission != null)
                                  PRFNavBarAction(
                                    label: l10n.edit,
                                    icon: Icons.edit_rounded,
                                    tooltip: l10n.mdEditMission,
                                    variant: PRFNavBarActionVariant.neutral,
                                    onPressed: () =>
                                        _showEditMissionSheet(mission),
                                  ),
                                IconButton(
                                  tooltip: l10n.mdRefreshMission,
                                  onPressed: () => context
                                      .read<MissionDetailCubit>()
                                      .loadOne(
                                        id: missionUlid,
                                        matchById: (m) => m.ulid == missionUlid,
                                        refresh: true,
                                      ),
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
                        offset: const Offset(0, -PRFSpacingTokens.xs),
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
                                .withValues(alpha: PRFOpacities.stronger),
                            indicatorColor: theme.colorScheme.secondary,
                            dividerColor: theme.colorScheme.onPrimary
                                .withValues(alpha: PRFOpacities.muted),
                            labelStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            tabs: [
                              Tab(text: l10n.missionDetailsOverview),
                              Tab(text: l10n.missionDetailsPeople),
                              Tab(text: l10n.missionDetailsFeedback),
                              Tab(text: l10n.missionDetailsFinance),
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
                    BlocBuilder<MissionDetailCubit, ResourceState<PRFMission>>(
                      builder: (context, state) {
                        final mission = _currentMissionFromState(state);

                        if (state is ResourceItemLoading<PRFMission> &&
                            mission == null) {
                          return const Center(
                            child: PRFCircularProgressIndicator(),
                          );
                        }

                        if (mission == null &&
                            state is ResourceItemError<PRFMission>) {
                          return PRFErrorView(
                            failure: PRFFailure(
                              message: l10n.missionsLoadErrorMessage,
                            ),
                            title: l10n.mdLoadErrorTitle,
                            retryLabel: l10n.tryAgain,
                            onRetry: () =>
                                context.read<MissionDetailCubit>().loadOne(
                                  id: missionUlid,
                                  matchById: (m) => m.ulid == missionUlid,
                                ),
                          );
                        }

                        if (mission == null) {
                          return const Center(
                            child: PRFCircularProgressIndicator(),
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
            BlocBuilder<MissionDetailCubit, ResourceState<PRFMission>>(
              builder: (context, state) {
                final mission = _currentMissionFromState(state);
                if (mission == null) {
                  return const SizedBox.shrink();
                }

                return switch (_currentTab) {
                  3 when Misc.userCan(PRFPermissions.createRequisition) =>
                    FloatingActionButton.extended(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
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
      onRefresh: _refreshMissionSubdomainData,
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
        final questions = _itemsFromResourceState(
          state,
        ).where((q) => q.mission?.ulid == missionUlid).toList();
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFMissionQuestion>,
          error: error,
          isEmpty: questions.isEmpty,
          onRefresh: () {
            final cubit = context.read<MissionQuestionResourceCubit>()
              ..invalidate();
            return cubit.loadForMission(missionUlid: missionUlid);
          },
          onAdd: _promptAddQuestion,
          addButtonLabel: context.l10n.mdAddQuestion,
          addButtonIcon: Icons.add_comment_outlined,
          emptyLabel: context.l10n.mdQuestionsEmpty,
          emptyDescription: context.l10n.mdQuestionsEmptyDesc,
          items: questions
              .map(
                (question) => MissionResourceCard(
                  title: question.question.isEmpty
                      ? context.l10n.mdUntitledQuestion
                      : question.question,
                  subtitle: context.l10n.missionAddedOnDate(
                    _formatDate(question.createdAt),
                  ),
                  editTooltip: context.l10n.mdEditQuestion,
                  onEdit: () => _promptEditQuestion(question),
                  deleteTooltip: context.l10n.mdDeleteQuestion,
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
        final notes = _itemsFromResourceState(
          state,
        ).where((n) => n.mission?.ulid == missionUlid).toList();
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFDebriefNote>,
          error: error,
          isEmpty: notes.isEmpty,
          onRefresh: () {
            final cubit = context.read<DebriefNoteResourceCubit>()
              ..invalidate();
            return cubit.loadForMission(missionUlid: missionUlid);
          },
          onAdd: _promptAddDebriefNote,
          addButtonLabel: context.l10n.addDebriefNote,
          addButtonIcon: Icons.rate_review_outlined,
          emptyLabel: context.l10n.mdDebriefEmpty,
          emptyDescription: context.l10n.mdDebriefEmptyDesc,
          items: notes
              .map(
                (note) => MissionResourceCard(
                  title: note.note.isEmpty
                      ? context.l10n.mdUntitledNote
                      : note.note,
                  subtitle: context.l10n.missionAddedOnDate(
                    _formatDate(note.createdAt),
                  ),
                  editTooltip: context.l10n.mdEditDebriefNote,
                  onEdit: () => _promptEditDebriefNote(note),
                  deleteTooltip: context.l10n.mdDeleteDebriefNote,
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
        final souls = _itemsFromResourceState(
          state,
        ).where((s) => s.mission?.ulid == missionUlid).toList();
        final error = _resourceErrorMessage(state);

        return MissionResourceTabView(
          isLoading: state is ResourceListLoading<PRFSoul>,
          error: error,
          isEmpty: souls.isEmpty,
          onRefresh: () {
            final cubit = context.read<SoulResourceCubit>()..invalidate();
            return cubit.loadForMission(missionUlid: missionUlid);
          },
          onAdd: _promptAddSoul,
          addButtonLabel: context.l10n.mdRecordSoul,
          addButtonIcon: Icons.favorite_outline,
          emptyLabel: context.l10n.mdSoulsEmpty,
          emptyDescription: context.l10n.mdSoulsEmptyDesc,
          items: souls
              .map(
                (soul) => MissionResourceCard(
                  title: soul.fullName,
                  subtitle: soul.notes?.trim().isNotEmpty ?? false
                      ? soul.notes
                      : context.l10n.missionAddedOnDate(
                          _formatDate(soul.createdAt),
                        ),
                  editTooltip: context.l10n.mdEditSoul,
                  onEdit: () => _promptEditSoul(soul),
                  deleteTooltip: context.l10n.mdDeleteSoul,
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
        final subscriptions = _itemsFromResourceState(
          state,
        ).where((s) => s.mission?.ulid == mission.ulid).toList();
        final error = _resourceErrorMessage(state);
        return MissionSubscriptionsSection(
          subscriptions: subscriptions,
          error: error,
          onSubscribe: () => _promptSubscribeMember(mission),
          onViewSubscriber: _viewSubscriberDetails,
          onUnsubscribe: (subscription) =>
              _unsubscribeMember(mission: mission, subscription: subscription),
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
        final members = _itemsFromResourceState(
          state,
        ).where((m) => m.mission?.ulid == mission.ulid).toList();
        final error = _resourceErrorMessage(state);
        return MissionOfflineMembersSection(
          offlineMembers: members,
          error: error,
          onAdd: () => _promptSubscribeMember(mission),
          onRemove: (member) =>
              _removeOfflineMember(mission: mission, member: member),
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
      PRFSnackbar.error(context, context.l10n.mdNotSyncedYet);
      return;
    }

    final shouldDelete = await _showDeleteConfirmation(
      title: context.l10n.mdRemoveMissioner,
      confirmLabel: context.l10n.missionRemove,
    );
    if (!shouldDelete || !mounted) return;

    final cubit = context.read<MissionOfflineMemberResourceCubit>();
    await cubit.removeOfflineMember(ulid: member.ulid);
    if (!mounted) return;

    final error = _resourceErrorMessage(cubit.state);
    if (error != null) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }

    await context.read<MissionDetailCubit>().loadOne(
      id: mission.ulid,
      matchById: (m) => m.ulid == mission.ulid,
    );
    if (!mounted) return;

    PRFSnackbar.success(context, context.l10n.mdMissionerRemoved);
  }

  Widget _buildMissionOperationsTab(PRFMission mission) {
    final operationTiles = <Widget>[
      _operationTile(
        icon: Icons.verified_outlined,
        title: context.l10n.mdOpApprove,
        subtitle: context.l10n.mdOpApproveDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpApproveDone,
          action: () => context.read<MissionDetailCubit>().approveMission(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.close_rounded,
        title: context.l10n.mdOpReject,
        subtitle: context.l10n.mdOpRejectDesc,
        onTap: () => _rejectMission(mission),
      ),
      _operationTile(
        icon: Icons.event_busy_outlined,
        title: context.l10n.mdOpCancel,
        subtitle: context.l10n.mdOpCancelDesc,
        onTap: () => _cancelMission(mission),
      ),
      _operationTile(
        icon: Icons.task_alt_outlined,
        title: context.l10n.mdOpComplete,
        subtitle: context.l10n.mdOpCompleteDesc,
        onTap: () => _confirmCompleteMission(mission),
      ),
      _operationTile(
        icon: Icons.notifications_active_outlined,
        title: context.l10n.mdOpNotifySchool,
        subtitle: context.l10n.mdOpNotifySchoolDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpNotifySchoolDone,
          action: () => context.read<MissionDetailCubit>().notifySchool(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.rate_review_outlined,
        title: context.l10n.mdOpRequestFeedback,
        subtitle: context.l10n.mdOpRequestFeedbackDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpRequestFeedbackDone,
          action: () => context
              .read<MissionDetailCubit>()
              .requestSchoolFeedback(missionUlid: mission.ulid),
        ),
      ),
      _operationTile(
        icon: Icons.forum_outlined,
        title: context.l10n.mdOpNotifyWhatsapp,
        subtitle: context.l10n.mdOpNotifyWhatsappDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpNotifyWhatsappDone,
          action: () => context.read<MissionDetailCubit>().notifyWhatsappGroup(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.summarize_outlined,
        title: context.l10n.mdOpSummary,
        subtitle: context.l10n.mdOpSummaryDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpSummaryDone,
          action: () => context.read<MissionDetailCubit>().generateSummary(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.cloud_upload_outlined,
        title: context.l10n.mdOpUploadDrive,
        subtitle: context.l10n.mdOpUploadDriveDesc,
        onTap: () => _runMissionAction(
          successMessage: context.l10n.mdOpUploadDriveDone,
          action: () => context.read<MissionDetailCubit>().uploadMediaToDrive(
            missionUlid: mission.ulid,
          ),
        ),
      ),
      _operationTile(
        icon: Icons.receipt_long_outlined,
        title: context.l10n.mdOpZeroReq,
        subtitle: context.l10n.mdOpZeroReqDesc,
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
            color: theme.colorScheme.outline.withValues(
              alpha: PRFOpacities.muted,
            ),
          ),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: disabled
              ? const SizedBox.square(
                  dimension: PRFSizeTokens.iconMd,
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
      PRFSnackbar.error(context, context.l10n.mdOpInProgress);
      return;
    }

    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }

    if (!mounted) return;

    final state = context.read<MissionDetailCubit>().state;
    if (state case ResourceItemError<PRFMission>()) {
      PRFSnackbar.error(context, context.l10n.mdActionFailed);
      return;
    }

    PRFSnackbar.success(context, successMessage);
  }

  Future<void> _confirmCompleteMission(PRFMission mission) async {
    final shouldComplete = await _confirmAction(
      title: context.l10n.mdOpComplete,
      content: context.l10n.mdCompleteConfirm,
      confirmLabel: context.l10n.mdComplete,
    );

    if (shouldComplete != true || !mounted) return;

    await _runMissionAction(
      successMessage: context.l10n.mdOpCompleteDone,
      action: () => context.read<MissionDetailCubit>().completeMission(
        missionUlid: mission.ulid,
      ),
    );
  }

  Future<void> _confirmMakeZeroRequisition(PRFMission mission) async {
    final shouldCreate = await _confirmAction(
      title: context.l10n.mdOpZeroReq,
      content: context.l10n.mdZeroReqConfirm,
      confirmLabel: context.l10n.mdCreateRequisition,
    );

    if (shouldCreate != true || !mounted) return;

    await _runMissionAction(
      successMessage: context.l10n.mdOpZeroReqDone,
      action: () => context.read<MissionDetailCubit>().makeZeroRequisition(
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
    return context.read<MissionDetailCubit>().state
        is ResourceItemLoading<PRFMission>;
  }

  Future<void> _rejectMission(PRFMission mission) async {
    final reason = await _promptReason(
      title: context.l10n.mdOpReject,
      hintText: context.l10n.mdReasonOptional,
      confirmLabel: context.l10n.mdOpReject,
    );
    if (!mounted || reason == null) return;

    await _runMissionAction(
      successMessage: context.l10n.mdOpRejectDone,
      action: () => context.read<MissionDetailCubit>().rejectMission(
        missionUlid: mission.ulid,
        reason: reason,
      ),
    );
  }

  Future<void> _cancelMission(PRFMission mission) async {
    final reason = await _promptReason(
      title: context.l10n.mdOpCancel,
      hintText: context.l10n.mdReasonOptional,
      confirmLabel: context.l10n.mdOpCancel,
    );
    if (!mounted || reason == null) return;

    await _runMissionAction(
      successMessage: context.l10n.mdOpCancelDone,
      action: () => context.read<MissionDetailCubit>().cancelMission(
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
        title: context.l10n.mdReason,
        subtitle: context.l10n.mdReasonSubtitle,
        labelText: context.l10n.mdReason,
        helperText: context.l10n.mdOptional,
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
        final sessions = _itemsFromResourceState(
          state,
        ).where((s) => s.mission?.ulid == missionUlid).toList();
        final error = _resourceErrorMessage(state);
        final theme = Theme.of(context);

        if (state is ResourceListLoading<PRFMissionSession> &&
            sessions.isEmpty) {
          return const Center(child: PRFCircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () {
            final cubit = context.read<MissionSessionResourceCubit>()
              ..invalidate();
            return cubit.loadForMission(missionUlid: missionUlid);
          },
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
                title: context.l10n.mdSessionsTitle,
                subtitle: context.l10n.mdSessionsSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null) const MissionSectionErrorBanner(),
                    if (sessions.isEmpty)
                      PRFEmptyView(
                        label: context.l10n.mdSessionsEmpty,
                        description: context.l10n.mdSessionsEmptyDesc,
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
                                  alpha: PRFOpacities.prominent,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.classGroup?.name ??
                                      context.l10n.mdSessionFallback,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: PRFSpacingTokens.xs),
                                Text(
                                  '${_formatDateTime(session.startsAt)} - '
                                  '${_formatDateTime(session.endsAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: PRFSpacingTokens.xs),
                                Text(
                                  context.l10n.mdFacilitator(
                                    session.facilitator?.fullName ??
                                        context.l10n.mdUnassigned,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  context.l10n.mdSpeaker(
                                    session.speaker?.fullName ??
                                        context.l10n.mdUnassigned,
                                  ),
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
      _error = isValid
          ? null
          : (widget.validationErrorText ?? context.l10n.mdRequired);
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.mdFillRequired);
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
              theme.colorScheme.primary.withValues(alpha: PRFOpacities.faint),
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
                    .slideY(
                      begin: -0.3,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.enterShort,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: PRFOpacities.muted,
                          ),
                        ),
                        boxShadow: PRFShadowTokens.card(
                          theme.colorScheme.shadow,
                        ),
                      ),
                      child: PRFFormSection(
                        icon: Icons.edit_note_outlined,
                        title: widget.title,
                        subtitle: widget.subtitle,
                        isRequired: widget.isRequired,
                        margin: EdgeInsets.zero,
                        child: PRFTextField(
                          hintText: widget.hintText,
                          labelText: widget.labelText,
                          helperText: widget.helperText,
                          errorText: _showValidation ? _error : null,
                          controller: _controller,
                          type: PRFTextFieldType.textArea,
                          minLines: widget.minLines,
                          maxLines: widget.maxLines,
                        ),
                      ),
                    )
                    .animate(
                      delay: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.stagger3,
                      ),
                    )
                    .slideX(
                      begin: -0.2,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.slow,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFButton(
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.badge(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: PRFSizeTokens.iconXl,
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
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
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
      _selectionError = context.l10n.mdSelectMemberError;
    });
    return false;
  }

  void _submit() {
    if (!_validateSelection()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.mdFillRequired);
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
      title: context.l10n.missionAddMissioner,
      child: _OfflineMemberFormBody(missionUlid: widget.missionUlid),
    );

    if (!mounted || dto == null) return;

    Gaimon.success();
    Navigator.of(context).pop(dto);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final members = state.maybeWhen(
          listLoaded: (members, _, _) => members,
          orElse: () => <PRFMember>[],
        );
        final isLoading = state.maybeWhen(
          listLoading: (items) => true,
          orElse: () => false,
        );
        final errorMessage = state.maybeWhen(
          error: (message, _) => message,
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
                    alpha: PRFOpacities.faint,
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
                      .slideY(
                        begin: -0.3,
                        duration: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.enterShort,
                        ),
                      )
                      .fadeIn(),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                      ),
                      boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
                    ),
                    child: PRFFormSection(
                      icon: Icons.group_add_outlined,
                      title: context.l10n.mdSelectMember,
                      subtitle: context.l10n.mdSelectMemberSubtitle,
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
                              hintText: context.l10n.mdSearchMember,
                              emptyText: context.l10n.mdNoMembersFound,
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
                                context.l10n.mdMembersLoadError,
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
                                context.l10n.mdNoMembersRefresh,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: PRFSpacingTokens.lg),
                          _buildAddMissionerButton(theme),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: PRFButton(
                      onPressed: _submit,
                      title: context.l10n.missionSubscribeMember,
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
    return PRFButton(
      onPressed: _promptAddOfflineMember,
      title: context.l10n.mdAddNonMember,
      icon: Icons.add,
      variant: PRFButtonVariant.outlined,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.badge(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            context.l10n.missionSubscribeMember,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            context.l10n.mdSubscribeMemberSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
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
      initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
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
      _nameError = hasName ? null : context.l10n.mdNameRequired;
    });
    return hasName && hasPhone;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.mdFillRequired);
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
              theme.colorScheme.primary.withValues(alpha: PRFOpacities.faint),
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
                    .slideY(
                      begin: -0.3,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.enterShort,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: PRFOpacities.muted,
                          ),
                        ),
                        boxShadow: PRFShadowTokens.card(
                          theme.colorScheme.shadow,
                        ),
                      ),
                      child: Column(
                        children: [
                          PRFFormSection(
                            icon: Icons.person_outline,
                            title: context.l10n.mdFullName,

                            isRequired: true,
                            margin: EdgeInsets.zero,
                            child: PRFTextField(
                              hintText: context.l10n.mdEnterFullName,
                              labelText: context.l10n.mdFullName,
                              helperText: context.l10n.mdRequired,
                              controller: _nameController,
                              errorText: _showValidation ? _nameError : null,
                            ),
                          ),
                          const SizedBox(height: PRFSpacingTokens.xl),
                          PRFFormSection(
                            icon: Icons.phone_outlined,
                            title: context.l10n.mdPhoneNumber,

                            isRequired: true,
                            margin: EdgeInsets.zero,
                            child: PRFPhoneInput(
                              hintText: context.l10n.mdEnterPhone,
                              controller: _phoneController,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(
                      delay: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.stagger3,
                      ),
                    )
                    .slideX(
                      begin: -0.2,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.slow,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFButton(
                    onPressed: _submit,
                    title: context.l10n.missionAddMissioner,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.badge(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_alt_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            context.l10n.missionAddMissioner,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            context.l10n.mdAddMissionerSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
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
      _nameError = hasName ? null : context.l10n.mdSoulNameRequired;
    });

    return hasName && hasClassGroup;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.mdFillRequired);
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
              theme.colorScheme.primary.withValues(alpha: PRFOpacities.faint),
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
                    .slideY(
                      begin: -0.3,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.enterShort,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: PRFOpacities.muted,
                          ),
                        ),
                        boxShadow: PRFShadowTokens.card(
                          theme.colorScheme.shadow,
                        ),
                      ),
                      child: Column(
                        children: [
                          PRFFormSection(
                            icon: Icons.person_outline,
                            title: context.l10n.mdSoulName,
                            isRequired: true,

                            margin: const EdgeInsets.only(
                              bottom: PRFSpacingTokens.md,
                            ),
                            child: PRFTextField(
                              hintText: context.l10n.mdSoulNameHint,
                              labelText: context.l10n.mdSoulName,
                              helperText: context.l10n.mdRequired,
                              errorText: _showValidation ? _nameError : null,
                              controller: _nameController,
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.class_outlined,
                            title: context.l10n.mdClassGroup,
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
                              hintText: context.l10n.mdSearchClassGroup,
                              emptyText: context.l10n.mdNoClassGroupsForType,
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.favorite_outline,
                            title: context.l10n.mdDecisionType,
                            subtitle: context.l10n.mdSelectOne,
                            margin: const EdgeInsets.only(
                              bottom: PRFSpacingTokens.md,
                            ),
                            child: Wrap(
                              spacing: PRFSpacingTokens.sm,
                              runSpacing: PRFSpacingTokens.sm,
                              children: PRFSoulDecisionType.values.map((value) {
                                final isSelected =
                                    _selectedDecisionType == value;
                                return MissionSelectableChip(
                                  label: value.name,
                                  selected: isSelected,
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.7,
                                  onTap: () {
                                    setState(() {
                                      _selectedDecisionType = value;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          PRFFormSection(
                            icon: Icons.notes_outlined,
                            title: context.l10n.mdNotes,

                            margin: EdgeInsets.zero,
                            child: PRFTextField(
                              hintText: context.l10n.mdNotesHint,
                              labelText: context.l10n.mdNotes,
                              helperText: context.l10n.mdOptional,
                              controller: _noteController,
                              type: PRFTextFieldType.textArea,
                              minLines: 3,
                              maxLines: 6,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(
                      delay: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.stagger3,
                      ),
                    )
                    .slideX(
                      begin: -0.2,
                      duration: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.slow,
                      ),
                    )
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFButton(
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.badge(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            context.l10n.mdRecordSoul,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            context.l10n.mdRecordSoulSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
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
          case ResourceListLoaded<PRFMissionSubscription>() when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.success();
            Navigator.of(context).pop(true);
            PRFSnackbar.success(context, context.l10n.mdSubscriberUpdated);
          case ResourceError<PRFMissionSubscription>() when _isLoading:
            setState(() => _isLoading = false);
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.mdActionFailed);
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
              _detailRow(context.l10n.name, member?.fullName),
              _detailRow(context.l10n.email, member?.email),
              _detailRow(context.l10n.mdPhone, member?.phoneNumber),
              _detailRow(context.l10n.mdResidence, member?.residence),
              _detailRow(context.l10n.mdPastor, member?.pastor),
              const SizedBox(height: PRFSpacingTokens.md),
              _buildChipSelector<PRFMissionRole>(
                theme: theme,
                label: context.l10n.mdRole,
                icon: Icons.badge_outlined,
                values: PRFMissionRole.values,
                selected: _selectedRole,
                nameOf: (v) => v.name,
                onSelected: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              _buildChipSelector<PRFMissionSubscriptionStatus>(
                theme: theme,
                label: context.l10n.mdStatus,
                icon: Icons.flag_outlined,
                values: PRFMissionSubscriptionStatus.values,
                selected: _selectedStatus,
                nameOf: (v) => v.name,
                onSelected: (v) => setState(() => _selectedStatus = v),
              ),
              const SizedBox(height: PRFSpacingTokens.xxl),
              SizedBox(
                width: double.infinity,
                child: PRFButton(
                  onPressed: _submit,
                  title: context.l10n.mdUpdateSubscriber,
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
          return MissionSelectableChip(
            label: nameOf(value),
            selected: isSelected,
            onTap: _isLoading ? null : () => onSelected(value),
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
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(safeValue, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
