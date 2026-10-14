import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/missions/actions/create_mission/create_mission.dart';
import 'package:leadership/features/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/features/missions/cubit/past_mission_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/load_more_on_scroll.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/debouncer.dart' as app_utils;
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:leadership/utils/router/router.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class MissionsPageHandset extends StatefulWidget {
  const MissionsPageHandset({super.key});

  @override
  State<MissionsPageHandset> createState() => _MissionsPageHandsetState();
}

class _MissionsPageHandsetState extends State<MissionsPageHandset>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final app_utils.Debouncer _debouncer = app_utils.Debouncer(milliseconds: 300);
  String _searchQuery = '';
  bool _isExporting = false;

  List<PRFMission> _missionsFromState(ResourceState<PRFMission> state) {
    return state.maybeWhen(
      listLoaded: (items, _, _) => items,
      mutating: (items, _) => items,
      error: (_, items) => items,
      orElse: () => const <PRFMission>[],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    context.read<MissionResourceCubit>().loadUpcomingMissions();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // TabController notifies twice per animated change; act once.
      if (_tabController.indexIsChanging) return;
      _loadTab(_tabController.index);
    });
  }

  void _loadTab(int index) {
    switch (index) {
      case 0:
        context.read<MissionResourceCubit>().loadUpcomingMissions();
      case 1:
        context.read<MissionResourceCubit>().loadPastMissions();
      default:
        context.read<PastMissionResourceCubit>().loadAll(
          filters: _schoolsFilters(),
        );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _exportAndShareSchedule() async {
    setState(() => _isExporting = true);
    try {
      await Misc.exportAndSharePdf(
        endpoint: '/missions/export-schedule',
        filename: 'missions_schedule',
      );
    } on Failure catch (e) {
      if (!mounted) return;
      PRFSnackbar.error(
        context,
        e.statusCode == 404
            ? context.l10n.missionsNoScheduleToShare
            : context.l10n.missionsShareScheduleFailed,
      );
    } catch (_) {
      if (!mounted) return;
      PRFSnackbar.error(context, context.l10n.missionsShareScheduleFailed);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          icon: _isExporting
              ? const SizedBox.square(
                  dimension: PRFSizeTokens.iconMd,
                  child: PRFCircularProgressIndicator(),
                )
              : const Icon(Icons.ios_share),
          label: Text(
            _isExporting
                ? l10n.missionsPreparingSchedule
                : l10n.missionsShareSchedule,
          ),
          onPressed: _isExporting ? null : _exportAndShareSchedule,
        ),
        body: Column(
          children: [
            ColoredBox(
              color: theme.colorScheme.primary,
              child: Column(
                children: [
                  PRFBrandedNavBar(
                    title: l10n.missions,
                    onBack: () => context.router.popUntilRouteWithPath(
                      PRFLeadershipRouter.landingRoute,
                    ),
                    actions: [
                      if (Misc.userCan(PRFPermissions.createMission))
                        PRFNavBarAction(
                          label: l10n.missionsNewMission,
                          icon: Icons.add,
                          tooltip: l10n.missionsNewMissionTooltip,
                          onPressed: _showCreateMissionForm,
                        ),
                      if (Misc.userCan(PRFPermissions.createMission))
                        const SizedBox(width: PRFSpacingTokens.sm),
                      BlocBuilder<
                        MissionResourceCubit,
                        ResourceState<PRFMission>
                      >(
                        builder: (context, state) => switch (state) {
                          ResourceListLoading<PRFMission>() =>
                            const SizedBox.square(
                              dimension: PRFSizeTokens.iconLg,
                              child: PRFCircularProgressIndicator(),
                            ),
                          _ => const SizedBox.shrink(),
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
                      PRFSpacingTokens.md,
                    ),
                    child:
                        BlocBuilder<
                          MissionResourceCubit,
                          ResourceState<PRFMission>
                        >(
                          builder: (context, state) {
                            final items = _missionsFromState(state);
                            final totalCapacity = items.fold<int>(
                              0,
                              (sum, mission) => sum + mission.capacity,
                            );
                            final openSlots = items.fold<int>(
                              0,
                              (sum, mission) =>
                                  sum + mission.missionSubscriptionsNeeded,
                            );

                            return Row(
                              children: [
                                Expanded(
                                  child: _buildHeaderStat(
                                    label: l10n.missions,
                                    value: '${items.length}',
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                Expanded(
                                  child: _buildHeaderStat(
                                    label: l10n.capacity,
                                    value: '$totalCapacity',
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                Expanded(
                                  child: _buildHeaderStat(
                                    label: l10n.missionsOpenSlots,
                                    value: '$openSlots',
                                    color: theme.colorScheme.errorContainer,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PRFSpacingTokens.lg,
                      0,
                      PRFSpacingTokens.lg,
                      PRFSpacingTokens.sm,
                    ),
                    child: Transform.translate(
                      offset: const Offset(0, -PRFSpacingTokens.xs),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: theme.colorScheme.onPrimary,
                          unselectedLabelColor: theme.colorScheme.onPrimary
                              .withValues(alpha: PRFOpacities.stronger),
                          indicatorColor: theme.colorScheme.secondary,
                          dividerColor: theme.colorScheme.onPrimary.withValues(
                            alpha: PRFOpacities.muted,
                          ),
                          labelStyle: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.sm,
                          ),
                          tabs: [
                            Tab(text: l10n.upcoming),
                            Tab(text: l10n.past),
                            Tab(text: l10n.bySchool),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PRFSpacingTokens.lg,
                PRFSpacingTokens.md,
                PRFSpacingTokens.lg,
                PRFSpacingTokens.sm,
              ),
              child: _buildSearchBar(theme),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMissionsTimeline(context),
                  _buildPastMissionsTimeline(context),
                  _buildSchoolsTimeline(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.sm,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: PRFOpacities.muted),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
        boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
      ),
      child: PRFTextField(
        hintText: context.l10n.missionsSearchHint,
        controller: _searchController,
        onChanged: (value) {
          _debouncer.run(() {
            if (!mounted) return;
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          });
        },
      ),
    );
  }

  List<PRFMission> _filterMissions(List<PRFMission> missions) {
    if (_searchQuery.isEmpty) {
      return missions;
    }

    return missions
        .where((mission) {
          final schoolName = mission.school?.name.toLowerCase() ?? '';
          final missionType = mission.missionType?.name.toLowerCase() ?? '';
          final missionTheme = (mission.theme ?? '').toLowerCase();

          return schoolName.contains(_searchQuery) ||
              missionType.contains(_searchQuery) ||
              missionTheme.contains(_searchQuery);
        })
        .toList(growable: false);
  }

  Widget _buildMissionsTimeline(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
      builder: (context, state) {
        return switch (state) {
          ResourceInitial<PRFMission>() || ResourceListLoading<PRFMission>() =>
            const Center(child: PRFCircularProgressIndicator()),
          ResourceError<PRFMission>() => _buildLoadError(
            context,
            onRetry: () =>
                context.read<MissionResourceCubit>().loadUpcomingMissions(),
          ),
          ResourceListLoaded<PRFMission>(:final items) ||
          ResourceMutating<PRFMission>(:final items) => (() {
            final missions = List<PRFMission>.from(items)
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
            final filtered = _filterMissions(missions);

            if (filtered.isEmpty) {
              return RefreshIndicator(
                onRefresh: () {
                  final cubit = context.read<MissionResourceCubit>()
                    ..invalidate();
                  return cubit.loadUpcomingMissions();
                },
                child: PRFEmptyView(
                  label: _searchQuery.isEmpty
                      ? l10n.noMissions
                      : l10n.missionsNoMatches,
                  description: _searchQuery.isEmpty
                      ? l10n.missionsEmptyDesc
                      : l10n.missionsNoMatchesDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () {
                final cubit = context.read<MissionResourceCubit>()
                  ..invalidate();
                return cubit.loadUpcomingMissions();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final mission = filtered[index];
                  final isLast = index == filtered.length - 1;

                  return TimelineMissionCard(
                        mission: mission,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router.push(
                          MissionsDetailsRoute(missionUlid: mission.ulid),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: _staggerDelay(context, index),
                        duration: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.enterShort,
                        ),
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: PRFMotionTokens.emphasized,
                      );
                },
              ),
            );
          })(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildPastMissionsTimeline(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
      builder: (context, state) {
        return switch (state) {
          ResourceInitial<PRFMission>() || ResourceListLoading<PRFMission>() =>
            const Center(child: PRFCircularProgressIndicator()),
          ResourceError<PRFMission>() => _buildLoadError(
            context,
            onRetry: () =>
                context.read<MissionResourceCubit>().loadPastMissions(),
          ),
          ResourceListLoaded<PRFMission>(:final items) ||
          ResourceMutating<PRFMission>(:final items) => (() {
            final missions = List<PRFMission>.from(items)
              ..sort((a, b) => b.startDate.compareTo(a.startDate));
            final filtered = _filterMissions(missions);
            final hasMore = context.read<MissionResourceCubit>().hasMorePages;

            if (filtered.isEmpty) {
              return RefreshIndicator(
                onRefresh: () {
                  final cubit = context.read<MissionResourceCubit>()
                    ..invalidate();
                  return cubit.loadPastMissions();
                },
                child: PRFEmptyView(
                  label: _searchQuery.isEmpty
                      ? l10n.noMissions
                      : l10n.missionsNoMatches,
                  description: _searchQuery.isEmpty
                      ? l10n.missionsEmptyDesc
                      : l10n.missionsNoMatchesDesc,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () {
                final cubit = context.read<MissionResourceCubit>()
                  ..invalidate();
                return cubit.loadPastMissions();
              },
              child: LoadMoreOnScroll(
                onEndReached: () =>
                    context.read<MissionResourceCubit>().loadNextPage(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                    vertical: PRFSpacingTokens.xl,
                  ),
                  itemCount: filtered.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filtered.length) {
                      return const Padding(
                        padding: EdgeInsets.all(PRFSpacingTokens.lg),
                        child: Center(child: PRFCircularProgressIndicator()),
                      );
                    }
                    final mission = filtered[index];
                    final isLast = index == filtered.length - 1;

                    return TimelineMissionCard(
                          mission: mission,
                          isLast: isLast,
                          index: index,
                          onTap: () => context.router.push(
                            MissionsDetailsRoute(missionUlid: mission.ulid),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: _staggerDelay(context, index),
                          duration: PRFMotionTokens.resolve(
                            context,
                            PRFMotionTokens.enterShort,
                          ),
                        )
                        .slideX(
                          begin: 0.3,
                          end: 0,
                          curve: PRFMotionTokens.emphasized,
                        );
                  },
                ),
              ),
            );
          })(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildSchoolsTimeline(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<PastMissionResourceCubit, ResourceState<PRFSchool>>(
      builder: (context, state) {
        final schools = context.read<PastMissionResourceCubit>().currentItems;
        final showInitialLoader =
            state is ResourceListLoading<PRFSchool> && schools.isEmpty;

        if (showInitialLoader) {
          return const Center(child: PRFCircularProgressIndicator());
        }

        final filtered = _filterSchools(schools);

        if (filtered.isEmpty) {
          final hasError = state.maybeWhen(
            error: (_, _) => true,
            orElse: () => false,
          );
          if (hasError) {
            return _buildLoadError(
              context,
              title: l10n.missionsSchoolsLoadErrorTitle,
              onRetry: () => context.read<PastMissionResourceCubit>().loadAll(
                filters: _schoolsFilters(),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () {
              final cubit = context.read<PastMissionResourceCubit>()
                ..invalidate();
              return cubit.loadAll(filters: _schoolsFilters());
            },
            child: PRFEmptyView(
              label: _searchQuery.isEmpty
                  ? l10n.noPastMissions
                  : l10n.missionsNoSchoolMatches,
              description: _searchQuery.isEmpty
                  ? l10n.missionsEmptyDesc
                  : l10n.missionsNoMatchesDesc,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            final cubit = context.read<PastMissionResourceCubit>()
              ..invalidate();
            return cubit.loadAll(filters: _schoolsFilters());
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.xl,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final school = filtered[index];
              final missionCount = school.missions.length;

              return PRFSchoolCard(
                    schoolName: school.name,
                    address: school.address,
                    missionCount: missionCount > 0 ? missionCount : null,
                    onTap: () => context.router.push(
                      SchoolPastMissionsRoute(schoolUlid: school.ulid),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: _staggerDelay(context, index),
                    duration: PRFMotionTokens.resolve(
                      context,
                      PRFMotionTokens.enterShort,
                    ),
                  )
                  .slideX(
                    begin: 0.3,
                    end: 0,
                    curve: PRFMotionTokens.emphasized,
                  );
            },
          ),
        );
      },
    );
  }

  Duration _staggerDelay(BuildContext context, int index) =>
      PRFMotionTokens.resolve(
        context,
        PRFMotionTokens.stagger2 * math.min(index, 8),
      );

  Widget _buildLoadError(
    BuildContext context, {
    required VoidCallback onRetry,
    String? title,
  }) {
    final l10n = context.l10n;
    return PRFErrorView(
      failure: PRFFailure(message: l10n.missionsLoadErrorMessage),
      title: title ?? l10n.missionsLoadErrorTitle,
      retryLabel: l10n.tryAgain,
      onRetry: onRetry,
    );
  }

  List<PRFSchool> _filterSchools(List<PRFSchool> schools) {
    if (_searchQuery.isEmpty) return schools;
    final query = _searchQuery.toLowerCase();
    return schools
        .where((school) => school.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  Map<String, dynamic> _schoolsFilters() {
    if (_searchQuery.isEmpty) return const {};
    return {'search': _searchQuery};
  }

  void _showCreateMissionForm() {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.missionsCreateTitle,
      child: const CreateMissionView(),
    );
  }
}

class TimelineMissionCard extends StatelessWidget with TimezoneMixin {
  const TimelineMissionCard({
    required this.mission,
    required this.isLast,
    required this.index,
    this.isSubscribed = false,
    this.onTap,
    super.key,
  });

  final PRFMission mission;
  final bool isLast;
  final int index;
  final bool isSubscribed;
  final VoidCallback? onTap;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColors = context.statusColors;
    final now = DateTime.now();
    final startDate = mission.startDate;
    final endDate = mission.endDate;
    // Day-inclusive, matching PRF Missions: a mission is ongoing when today
    // falls on or between its start and end days.
    final startedByToday =
        startDate.isBefore(now) || _isSameDay(startDate, now);
    final endsTodayOrLater = endDate.isAfter(now) || _isSameDay(endDate, now);
    final isOngoing = startedByToday && endsTodayOrLater;
    final isUpcoming = !startedByToday;
    final isPast = !endsTodayOrLater;
    final isMultiDay = !_isSameDay(startDate, endDate);
    final durationDays = endDate.difference(startDate).inDays + 1;
    final timeRange =
        '${Misc.formatTime(mission.startTime, timezone)} - '
        '${Misc.formatTime(mission.endTime, timezone)}';

    final statusColor = isSubscribed
        ? statusColors.success.main
        : isOngoing
        ? statusColors.inProgress.main
        : isUpcoming
        ? statusColors.scheduled.main
        : isPast
        ? statusColors.completed.main
        : statusColors.info.main;

    final statusText = isSubscribed
        ? l10n.subscribed
        : isOngoing
        ? l10n.missionsStatusOngoing
        : isUpcoming
        ? l10n.upcoming
        : isPast
        ? l10n.completed
        : l10n.missionsStatusAvailable;

    return PRFTimelineMissionCard(
      isLast: isLast,
      startDate: startDate,
      endDate: endDate,
      statusColor: statusColor,
      statusText: statusText,
      schoolName: mission.school?.name ?? '',
      missionTypeName: mission.missionType?.name ?? '',
      durationLabel: l10n.duration,
      durationValue: isMultiDay ? l10n.durationDesc(durationDays) : timeRange,
      capacityLabel: l10n.capacity,
      capacityValue: l10n.capacityDesc(mission.capacity),
      datePrimaryText: isMultiDay
          ? '${Misc.formatDate(startDate, timezone)} - '
                '${Misc.formatDate(endDate, timezone)}'
          : Misc.formatDate(startDate, timezone),
      dateSecondaryText: isMultiDay ? timeRange : null,
      showActiveIndicator: isOngoing,
      activeIndicatorColor: statusColors.active,
      actionLabel: l10n.viewDetails,
      onTap: onTap,
    );
  }
}
