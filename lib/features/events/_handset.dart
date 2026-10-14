import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/events/actions/create_event/create_event.dart';
import 'package:leadership/features/events/cubit/event_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/services/api/event_service.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/db/event_hive_db_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:leadership/utils/router/router.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class EventsHandset extends StatefulWidget {
  const EventsHandset({super.key});

  @override
  State<EventsHandset> createState() => _EventsHandsetState();
}

class _EventsHandsetState extends State<EventsHandset>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final EventResourceCubit _upcomingCubit;
  late final EventResourceCubit _pastCubit;

  @override
  void initState() {
    super.initState();

    _upcomingCubit = EventResourceCubit(
      eventService: getIt<EventService>(),
      requisitionService: getIt<RequisitionService>(),
      hiveService: getIt<HiveService>(),
      hiveDbService: getIt<EventHiveDbService>(),
    )..loadUpcomingEvents();

    _pastCubit = EventResourceCubit(
      eventService: getIt<EventService>(),
      requisitionService: getIt<RequisitionService>(),
      hiveService: getIt<HiveService>(),
      hiveDbService: getIt<EventHiveDbService>(),
    )..loadPastEvents();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _upcomingCubit.loadUpcomingEvents();
      } else {
        _pastCubit.loadPastEvents();
      }
    });
  }

  @override
  void dispose() {
    _upcomingCubit.close();
    _pastCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          ColoredBox(
            color: theme.colorScheme.primary,
            child: Column(
              children: [
                PRFBrandedNavBar(
                  title: l10n.activities,
                  onBack: () => context.router.popUntilRouteWithPath(
                    PRFLeadershipRouter.landingRoute,
                  ),
                  actions: [
                    if (Misc.userCan(PRFPermissions.createEvent))
                      PRFNavBarAction(
                        label: l10n.eventsNewActivity,
                        icon: Icons.add,
                        tooltip: l10n.eventsNewActivityTooltip,
                        onPressed: _showCreateEventForm,
                      ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BlocProvider.value(
                  value: _upcomingCubit,
                  child: _buildEventsTimeline(context),
                ),
                BlocProvider.value(
                  value: _pastCubit,
                  child: _buildPastEventTimeline(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateEventForm() {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.createNewActivity,
      child: const CreateEventView(),
    );
  }

  Widget _buildLoadError(BuildContext context, VoidCallback onRetry) {
    final l10n = context.l10n;
    return PRFErrorView(
      failure: PRFFailure(message: l10n.missionsLoadErrorMessage),
      title: l10n.eventsLoadErrorTitle,
      retryLabel: l10n.tryAgain,
      onRetry: onRetry,
    );
  }

  Widget _buildEventsTimeline(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EventResourceCubit, ResourceState<PRFEvent>>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => const Center(child: PRFCircularProgressIndicator()),
          error: (_, _) => _buildLoadError(
            context,
            () => context.read<EventResourceCubit>().loadUpcomingEvents(),
          ),
          listLoaded: (events, _, _) {
            if (events.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<EventResourceCubit>().loadUpcomingEvents(),
                child: PRFEmptyView(
                  label: l10n.noActivities,
                  description: l10n.createActivity,
                ),
              );
            }
            // Sort events by start date for timeline
            final sortedEvents = List<PRFEvent>.from(events)
              ..sort((a, b) => a.startDate.compareTo(b.startDate));

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<EventResourceCubit>().loadUpcomingEvents(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
                ),
                itemCount: sortedEvents.length,
                itemBuilder: (context, index) {
                  final event = sortedEvents[index];
                  final isLast = index == sortedEvents.length - 1;

                  return TimelineEventCard(
                        event: event,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router.push(
                          DeskEventDetailsRoute(event: event),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.stagger2 * math.min(index, 8),
                        ),
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
      },
    );
  }

  Widget _buildPastEventTimeline(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EventResourceCubit, ResourceState<PRFEvent>>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => const Center(child: PRFCircularProgressIndicator()),
          error: (_, _) => _buildLoadError(
            context,
            () => context.read<EventResourceCubit>().loadPastEvents(),
          ),
          listLoaded: (events, _, _) {
            if (events.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<EventResourceCubit>().loadPastEvents(),
                child: PRFEmptyView(
                  label: l10n.noActivities,
                  description: l10n.eventsEmptyPastDesc,
                ),
              );
            }

            final sorted = events.reversed.toList();
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<EventResourceCubit>().loadPastEvents(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.xl,
                ),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final event = sorted[index];
                  final isLast = index == events.length - 1;

                  return TimelineEventCard(
                        event: event,
                        isLast: isLast,
                        index: index,
                        onTap: () => context.router.push(
                          DeskEventDetailsRoute(event: event),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.stagger2 * math.min(index, 8),
                        ),
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
      },
    );
  }
}

class TimelineEventCard extends StatelessWidget with TimezoneMixin {
  const TimelineEventCard({
    required this.event,
    required this.isLast,
    required this.index,
    this.isSubscribed = false,
    this.onTap,
    super.key,
  });

  final PRFEvent event;
  final bool isLast;
  final int index;
  final bool isSubscribed;
  final VoidCallback? onTap;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final statusColors = context.statusColors;
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final startDate = event.startDate;
    final endDate = event.endDate;
    // Day-inclusive: an activity is ongoing when today falls on or between
    // its start and end days.
    final startedByToday =
        startDate.isBefore(now) || _isSameDay(startDate, now);
    final endsTodayOrLater = endDate.isAfter(now) || _isSameDay(endDate, now);
    final isOngoing = startedByToday && endsTodayOrLater;
    final isUpcoming = !startedByToday;
    final isMultiDay = !_isSameDay(startDate, endDate);

    final statusSet = isSubscribed
        ? statusColors.success
        : isOngoing
        ? statusColors.inProgress
        : isUpcoming
        ? statusColors.scheduled
        : statusColors.completed;
    final statusColor = statusSet.main;
    final actionColor = statusSet.foreground;

    final dateText = isMultiDay
        ? '${Misc.formatDate(startDate, timezone)} - '
              '${Misc.formatDate(endDate, timezone)}'
        : Misc.formatDate(startDate, timezone);
    final timeText = l10n.eventsTimeRangeDaily(
      Misc.formatTime(event.startTime, timezone),
      Misc.formatTime(event.endTime, timezone),
    );
    final radius = BorderRadius.circular(PRFRadiusTokens.md);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PRFTimelineDateBadge(
          startDate: startDate,
          endDate: isMultiDay ? endDate : null,
          statusColor: statusColor,
          isLast: isLast,
          badgeWidth: 40,
          connectorHeight: 34,
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : PRFSpacingTokens.sm),
            child: Semantics(
              button: true,
              label: '${event.name}, $dateText',
              hint: l10n.viewDetails,
              excludeSemantics: true,
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: statusColor.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                      ),
                      boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.md),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor.withValues(
                                  alpha: PRFOpacities.subtle,
                                ),
                                statusColor.withValues(
                                  alpha: PRFOpacities.faint,
                                ),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                event.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (event.venue != null) ...[
                                const SizedBox(height: PRFSpacingTokens.sm),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        PRFSpacingTokens.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          PRFRadiusTokens.sm,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        size: PRFSizeTokens.iconSm,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: PRFSpacingTokens.sm),
                                    Expanded(
                                      child: Text(
                                        event.venue!,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(PRFSpacingTokens.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  PRFSpacingTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: radius,
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: PRFOpacities.muted,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: PRFSizeTokens.iconMd,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: PRFSpacingTokens.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            dateText,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: PRFSpacingTokens.xs,
                                          ),
                                          Text(
                                            timeText,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: PRFSpacingTokens.md),
                              if (event.description.isNotEmpty)
                                Text(
                                  event.description.split('\n').first,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: PRFSpacingTokens.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PRFSpacingTokens.lg,
                                  vertical: PRFSpacingTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(
                                    alpha: isDark
                                        ? PRFOpacities.muted
                                        : PRFOpacities.subtle,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    PRFRadiusTokens.sm,
                                  ),
                                  border: Border.all(
                                    color: statusColor.withValues(
                                      alpha: PRFOpacities.glow,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.viewDetails,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: actionColor,
                                          ),
                                    ),
                                    const SizedBox(width: PRFSpacingTokens.xs),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: PRFSizeTokens.iconSm,
                                      color: actionColor,
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
          ),
        ),
      ],
    );
  }
}
