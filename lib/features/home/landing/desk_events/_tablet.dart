import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/desk_events/actions/create_event/create_event.dart';
import 'package:leadership/features/home/landing/desk_events/cubit/get_events_cubit.dart';
import 'package:leadership/features/home/landing/desk_events/cubit/get_past_events_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class DeskEventsTablet extends StatefulWidget {
  const DeskEventsTablet({super.key});

  @override
  State<DeskEventsTablet> createState() => _DeskEventsTabletState();
}

class _DeskEventsTabletState extends State<DeskEventsTablet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    context.read<GetEventsCubit>().getUpcomingEvents();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        context.read<GetEventsCubit>().getUpcomingEvents();
      } else {
        context.read<GetPastEventsCubit>().getPastEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            l10n.events,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          leading: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
              onPressed: () => context.router.popUntilRouteWithPath(
                PRFLeadershipRouter.landingRoute,
              ),
            ),
          ),
          actions: [
            BlocBuilder<GetEventsCubit, GetEventsState>(
              builder: (context, state) => state.maybeWhen(
                loading: () => const SizedBox.square(
                  dimension: 24,
                  child: PRFCircularProgressIndicator(),
                ),
                orElse: SizedBox.shrink,
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<GetPastEventsCubit, GetPastEventsState>(
              builder: (context, state) => state.maybeWhen(
                loading: () => const SizedBox.square(
                  dimension: 24,
                  child: PRFCircularProgressIndicator(),
                ),
                orElse: SizedBox.shrink,
              ),
            ),
            const SizedBox(width: 16),
          ],
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.all),
              Tab(text: l10n.subscribed),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEventsTimeline(context),
            _buildSubscribedEventsTimeline(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => WoltModalSheet.show<void>(
            context: context,
            pageListBuilder: (modalSheetContext) {
              return [
                WoltModalSheetPage(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.8,
                    child: const CreateEventView(),
                  ),
                ),
              ];
            },
          ),

          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventsTimeline(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetEventsCubit, GetEventsState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () => context.read<GetEventsCubit>().getUpcomingEvents(),
            child: PRFEmptyView(
              label: l10n.noEvents,
              description: l10n.pleaseWaitOS,
            ),
          ),
          loaded: (events) {
            // Sort events by start date for timeline
            final sortedEvents = List<PRFEvent>.from(events)
              ..sort((a, b) => a.startDate.compareTo(b.startDate));

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<GetEventsCubit>().getUpcomingEvents(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
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
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubscribedEventsTimeline(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<GetPastEventsCubit, GetPastEventsState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          empty: () => RefreshIndicator(
            onRefresh: () => context.read<GetPastEventsCubit>().getPastEvents(),
            child: PRFEmptyView(
              label: l10n.noEvents,
              description: l10n.pleaseWaitForOS,
            ),
          ),
          loaded: (events) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<GetPastEventsCubit>().getPastEvents(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isLast = index == events.length - 1;

                  return TimelineEventCard(
                        event: event,
                        isLast: isLast,
                        index: index,
                        isSubscribed: true,
                        onTap: () => context.router.push(
                          DeskEventDetailsRoute(event: event),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 600.ms,
                      )
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        curve: Curves.easeOutCubic,
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
    final now = DateTime.now();
    final startDate = event.startDate;
    final endDate = event.endDate;
    final isUpcoming = startDate.isAfter(now);
    final isPast = endDate.isBefore(now.subtract(const Duration(days: 1)));
    final isOngoing = startDate.isBefore(now) && endDate.isAfter(now);
    final isMultiDay = !_isSameDay(startDate, endDate);
    final duration = endDate.difference(startDate).inDays + 1;

    // Premium status color system
    final statusColor = isSubscribed
        ? const Color(PRFTheme.secondaryColor)
        : isOngoing
        ? const Color(PRFTheme.secondaryColor) // Active green
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
          width: 80,
          child: Column(
            children: [
              // Multi-day date badge
              Container(
                width: 70,
                height: isMultiDay ? 180 : 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor,
                      statusColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(startDate.month),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.7),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      // End date
                      Text(
                        endDate.day.toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(endDate.month),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      // Single day
                      Text(
                        startDate.day.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        Misc.getMonthAbbreviation(startDate.month),
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                  width: 3,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withValues(alpha: 0.6),
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(
                bottom: isLast ? 0 : 24,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.05),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          // Event name and status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  statusText,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Event venue with icon
                          if (event.venue != null)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    event.venue!,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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

                    // Event details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Duration and capacity info chips
                          Row(
                            children: [
                              Flexible(
                                child: _buildInfoChip(
                                  context,
                                  Icons.schedule_rounded,
                                  'Duration',
                                  isMultiDay ? '$duration days' : 'Single day',
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: _buildInfoChip(
                                  context,
                                  Icons.people_rounded,
                                  'Capacity',
                                  '${event.capacity} attendees',
                                  theme.colorScheme.secondaryContainer,
                                  theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Date range display
                          DateRangeView(
                            isMultiDay: isMultiDay,
                            startDate: startDate,
                            timezone: timezone,
                            endDate: endDate,
                            event: event,
                          ),

                          const SizedBox(height: 20),

                          // Description preview
                          if (event.description.isNotEmpty)
                            Text(
                              event.description.split('\n').first,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 20),

                          // Action button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withValues(alpha: 0.1),
                                  statusColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Details',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
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
    Color backgroundColor,
    Color textColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateRangeView extends StatelessWidget {
  const DateRangeView({
    required this.isMultiDay,
    required this.startDate,
    required this.timezone,
    required this.endDate,
    required this.event,
    super.key,
  });

  final bool isMultiDay;
  final DateTime startDate;
  final String timezone;
  final DateTime endDate;
  final PRFEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          16,
        ),
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
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMultiDay
                      ? '${Misc.formatDate(startDate, timezone)} - '
                            '${Misc.formatDate(endDate, timezone)}'
                      : Misc.formatDate(
                          startDate,
                          timezone,
                        ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Misc.formatTime(event.startTime, timezone)} -'
                  ' ${Misc.formatTime(event.endTime, timezone)} daily',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
