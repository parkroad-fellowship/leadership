import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/landing/missions/actions/create_mission/create_mission.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/debouncer.dart' as app_utils;
import 'package:leadership/utils/mixins/timezone_mixin.dart';
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
  final app_utils.Debouncer _debouncer = app_utils.Debouncer(
    milliseconds: 300,
  );
  String _searchQuery = '';
  bool _isExporting = false;

  List<PRFMission> _missionsFromState(ResourceState<PRFMission> state) {
    return state.maybeWhen(
      listLoaded: (items, _, _) => items,
      mutating: (items, _) => items,
      mutated: (items, _, _) => items,
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

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        context.read<MissionResourceCubit>().loadUpcomingMissions();
      } else {
        context.read<MissionResourceCubit>().loadPastMissions();
      }
    });
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
        e.statusCode == 404 ? 'No scheduled missions to export' : e.message,
      );
    } catch (e) {
      if (!mounted) return;
      PRFSnackbar.error(context, 'Failed to export schedule');
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
          backgroundColor: PRFColorPalette.lime300,
          foregroundColor: PRFColorPalette.navy900,
          icon: _isExporting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share),
          label: Text(_isExporting ? 'Exporting...' : 'Share Schedule'),
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
                        PRFHeaderActionButton(
                          label: '+ New',
                          onTap: _showCreateMissionForm,
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
                              dimension: 24,
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
                                    label: 'Missions',
                                    value: '${items.length}',
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                Expanded(
                                  child: _buildHeaderStat(
                                    label: 'Capacity',
                                    value: '$totalCapacity',
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.sm),
                                Expanded(
                                  child: _buildHeaderStat(
                                    label: 'Open Slots',
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
                      offset: const Offset(0, -6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          controller: _tabController,
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
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.sm,
                          ),
                          tabs: [
                            Tab(text: l10n.upcoming),
                            Tab(text: l10n.past),
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
        color: color.withValues(alpha: 0.2),
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
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
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
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PRFTextInput(
        hintText: 'Search missions by school, type, or theme...',
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
    final theme = Theme.of(context);

    return BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
      builder: (context, state) {
        return switch (state) {
          ResourceInitial<PRFMission>() ||
          ResourceListLoading<PRFMission>() => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          ResourceError<PRFMission>(:final message) => Center(
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
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          ResourceListLoaded<PRFMission>(:final items) ||
          ResourceMutated<PRFMission>(:final items) => (() {
            final missions = List<PRFMission>.from(items)
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
            final filtered = _filterMissions(missions);

            if (filtered.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<MissionResourceCubit>().loadUpcomingMissions(),
                child: PRFEmptyView(
                  label: _searchQuery.isEmpty
                      ? l10n.noMissions
                      : 'No matching missions',
                  description: _searchQuery.isEmpty
                      ? l10n.pleaseWait
                      : 'Try a different search term.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<MissionResourceCubit>().loadUpcomingMissions(),
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
                        delay: Duration(milliseconds: index * 100),
                        duration: PRFMotionTokens.enterShort,
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
    final theme = Theme.of(context);

    return BlocBuilder<MissionResourceCubit, ResourceState<PRFMission>>(
      builder: (context, state) {
        return switch (state) {
          ResourceInitial<PRFMission>() ||
          ResourceListLoading<PRFMission>() => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          ResourceError<PRFMission>(:final message) => Center(
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
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          ResourceListLoaded<PRFMission>(:final items) ||
          ResourceMutated<PRFMission>(:final items) => (() {
            final missions = List<PRFMission>.from(items)
              ..sort((a, b) => b.startDate.compareTo(a.startDate));
            final filtered = _filterMissions(missions);

            if (filtered.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<MissionResourceCubit>().loadPastMissions(),
                child: PRFEmptyView(
                  label: _searchQuery.isEmpty
                      ? l10n.noMissions
                      : 'No matching missions',
                  description: _searchQuery.isEmpty
                      ? l10n.pleaseWait
                      : 'Try a different search term.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<MissionResourceCubit>().loadPastMissions(),
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
                        delay: Duration(milliseconds: index * 100),
                        duration: PRFMotionTokens.enterShort,
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

  void _showCreateMissionForm() {
    PRFBottomSheet.show<void>(
      context,
      title: 'Create Mission',
      child: const CreateMissionView(),
    ).then((_) {
      if (!mounted) return;
      if (_tabController.index == 0) {
        context.read<MissionResourceCubit>().loadUpcomingMissions();
      } else {
        context.read<MissionResourceCubit>().loadPastMissions();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final now = DateTime.now();
    final startDate = mission.startDate;
    final endDate = mission.endDate;
    final isUpcoming = startDate.isAfter(now);
    final isPast = endDate.isBefore(now.subtract(const Duration(days: 1)));
    final isOngoing = startDate.isBefore(now) && endDate.isAfter(now);
    final isMultiDay = !_isSameDay(startDate, endDate);
    final duration = endDate.difference(startDate).inDays + 1;

    // Premium status color system
    final statusColor = isSubscribed
        ? PRFColors.limeGreen
        : isOngoing
        ? PRFColors.limeGreen
        : isUpcoming
        ? theme.colorScheme.primary
        : isPast
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.secondary;

    final statusText = isSubscribed
        ? 'Subscribed'
        : isOngoing
        ? 'Active'
        : isUpcoming
        ? 'Upcoming'
        : isPast
        ? 'Completed'
        : 'Available';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Column(
            children: [
              // Multi-day date badge
              Container(
                width: 50,
                height: isMultiDay ? 100 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor,
                      statusColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMultiDay) ...[
                      // Start date
                      Text(
                        startDate.day.toString(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(startDate.month),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.7),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      // End date
                      Text(
                        endDate.day.toString(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(endDate.month),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      // Single day
                      Text(
                        startDate.day.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(startDate.month),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Timeline line with flexible height
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(
                    vertical: PRFSpacingTokens.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withValues(alpha: 0.6),
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: PRFSpacingTokens.lg),

        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium header with gradient
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withValues(alpha: 0.1),
                            statusColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // School name and status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mission.school?.name ?? '',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PRFSpacingTokens.sm,
                                  vertical: PRFSpacingTokens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.md,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  statusText,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: PRFSpacingTokens.md),

                          // Mission type with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Expanded(
                                child: Text(
                                  mission.missionType?.name ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content section
                    Padding(
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Duration and timing info
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  context,
                                  Icons.access_time_rounded,
                                  l10n.duration,
                                  isMultiDay
                                      ? l10n.durationDesc(duration)
                                      // ignore: lines_longer_than_80_chars
                                      : '${Misc.formatTime(mission.startTime, timezone)} - ${Misc.formatTime(mission.endTime, timezone)}',
                                  theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: PRFSpacingTokens.sm),
                              Expanded(
                                child: _buildInfoChip(
                                  context,
                                  Icons.people_rounded,
                                  l10n.capacity,
                                  l10n.capacityDesc(mission.capacity),
                                  theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: PRFSpacingTokens.md),

                          // Date range display
                          DateRangeView(
                            isMultiDay: isMultiDay,
                            startDate: startDate,
                            timezone: timezone,
                            endDate: endDate,
                            mission: mission,
                            isOngoing: isOngoing,
                          ),

                          const SizedBox(height: PRFSpacingTokens.md),

                          // Action button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: PRFSpacingTokens.lg,
                              vertical: PRFSpacingTokens.sm,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.sm,
                              ),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Details',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: PRFSpacingTokens.xs),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: statusColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: color,
              ),
              const SizedBox(width: PRFSpacingTokens.xs),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class DateRangeView extends StatelessWidget {
  const DateRangeView({
    required this.isMultiDay,
    required this.startDate,
    required this.timezone,
    required this.endDate,
    required this.mission,
    required this.isOngoing,
    super.key,
  });

  final bool isMultiDay;
  final DateTime startDate;
  final String timezone;
  final DateTime endDate;
  final PRFMission mission;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMultiDay
                      // ignore: lines_longer_than_80_chars
                      ? '${Misc.formatDate(startDate, timezone)} - ${Misc.formatDate(endDate, timezone)}'
                      : Misc.formatDate(
                          startDate,
                          timezone,
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMultiDay)
                  Text(
                    // ignore: lines_longer_than_80_chars
                    '${Misc.formatTime(mission.startTime, timezone)} - ${Misc.formatTime(mission.endTime, timezone)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Progress indicator for ongoing missions
          if (isOngoing)
            Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF10B981,
                        ).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                ),
        ],
      ),
    );
  }
}
