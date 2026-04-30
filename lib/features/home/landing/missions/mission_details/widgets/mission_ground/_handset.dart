import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/mixins/timezone_mixin.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:prf_design/prf_design.dart';

class MissionGroundViewHandset extends StatefulWidget {
  const MissionGroundViewHandset({required this.mission, super.key});

  final PRFMission mission;

  @override
  State<MissionGroundViewHandset> createState() =>
      _MissionGroundViewHandsetState();
}

class _MissionGroundViewHandsetState extends State<MissionGroundViewHandset>
    with TimezoneMixin {
  PRFMission get mission => widget.mission;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final school = mission.school;

    if (school == null) {
      return Padding(
        padding: const EdgeInsets.all(PRFSpacingTokens.lg),
        child: PRFEmptyView(
          label: l10n.missionDetails,
          description: 'Mission school details are unavailable.',
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            // Hero Mission Card
            _buildHeroCard(context, mission, school, l10n, theme),
            const SizedBox(height: 24),

            // Quick Actions Row
            _buildQuickActions(context, mission, l10n, theme),
            const SizedBox(height: 24),

            // Mission Intelligence Grid
            _buildIntelligenceGrid(context, mission, school, l10n, theme),
            const SizedBox(height: 24),

            // Contact Command Center
            _buildContactCenter(context, school, l10n, theme),
            const SizedBox(height: 24),

            // Location & Navigation Hub
            _buildLocationHub(context, mission, school, l10n, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    PRFMission mission,
    PRFSchool school,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mission.status.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  school.name.toUpperCase(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mission.theme!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildDateTimeChip(
                      context,
                      Icons.play_arrow_rounded,
                      l10n.missionStart(
                        Misc.formatMissionDate(mission.startDate, timezone),
                        Misc.formatTime(mission.startTime, timezone),
                      ),
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDateTimeChip(
                      context,
                      Icons.stop_rounded,
                      l10n.missionEnd(
                        Misc.formatMissionDate(mission.endDate, timezone),
                        Misc.formatTime(mission.endTime, timezone),
                      ),
                      theme,
                    ),
                  ],
                ),
                if (mission.missionPrepNotes?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  _buildPrepNotes(context, mission, l10n, theme),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDateTimeChip(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    PRFMission mission,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Row(
          children: [
            if (mission.whatsAppLink != null)
              Expanded(
                child: _buildActionButton(
                  context,
                  Icons.chat_rounded,
                  l10n.joinWhatsApp,
                  theme.colorScheme.secondary,
                  () => Misc.openUrl(Uri.parse(mission.whatsAppLink!)),
                  theme,
                ),
              ),
            if (mission.whatsAppLink != null) const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.map_rounded,
                l10n.navigate,
                theme.colorScheme.tertiary,
                () => _openMap(mission),
                theme,
              ),
            ),
          ],
        )
        .animate(delay: PRFMotionTokens.stagger2)
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligenceGrid(
    BuildContext context,
    PRFMission mission,
    PRFSchool school,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.missionIntelligence,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                if (school.totalStudents != 0)
                  _buildStatCard(
                    context,
                    Icons.people_rounded,
                    l10n.population,
                    school.totalStudents.toString(),
                    theme.colorScheme.primary,
                    theme,
                  ),
                _buildStatCard(
                  context,
                  Icons.person_add_rounded,
                  l10n.missionariesRequested,
                  mission.capacity.toString(),
                  theme.colorScheme.secondary,
                  theme,
                ),
                _buildStatCard(
                  context,
                  Icons.group_add_rounded,
                  l10n.missionariesNeeded,
                  mission.missionSubscriptionsNeeded.toString(),
                  theme.colorScheme.tertiary,
                  theme,
                ),
                _buildStatCard(
                  context,
                  Icons.route_rounded,
                  l10n.estimatedDistance,
                  school.distance,
                  theme.colorScheme.error,
                  theme,
                ),
              ],
            ),
          ],
        )
        .animate(delay: PRFMotionTokens.stagger4)
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCenter(
    BuildContext context,
    PRFSchool school,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.contact_phone_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.contactPersons,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (school.contacts.isEmpty)
                Text(
                  'No contact persons available for this school.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...school.contacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(
                                  alpha: 0.1,
                                ),
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  contact.contactType!.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () async {
                                final uri = Uri(
                                  scheme: 'tel',
                                  path: contact.phone,
                                );
                                await Misc.openUrl(uri);
                              },
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ).animate(
                            effects: const [
                              ShakeEffect(
                                duration: Duration(seconds: 2),
                                delay: PRFMotionTokens.stagger5,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate(delay: PRFMotionTokens.enterShort)
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildLocationHub(
    BuildContext context,
    PRFMission mission,
    PRFSchool school,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.tertiary.withValues(alpha: 0.1),
                theme.colorScheme.tertiary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.address,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _openMap(mission),
                      icon: const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ).animate(
                    effects: const [
                      ShakeEffect(
                        duration: Duration(seconds: 2),
                        delay: PRFMotionTokens.stagger5,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.address,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (school.directions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        school.directions,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTravelInfo(
                      context,
                      Icons.straighten_rounded,
                      l10n.estimatedDistance,
                      school.distance,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTravelInfo(
                      context,
                      Icons.schedule_rounded,
                      'Travel Time',
                      school.staticDuration,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.estimationDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: PRFMotionTokens.enterMedium)
        .fadeIn(duration: PRFMotionTokens.enterShort)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildTravelInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.tertiary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.tertiary,
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

  Widget _buildPrepNotes(
    BuildContext context,
    PRFMission mission,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_alt_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.missionPrepNotes,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              mission.missionPrepNotes!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(PRFMission mission) async {
    final school = mission.school!;

    final mapTypes = [MapType.google, MapType.googleGo, MapType.apple];

    for (final mapType in mapTypes) {
      final isAvailable = await MapLauncher.isMapAvailable(mapType);
      if (isAvailable) {
        await MapLauncher.showMarker(
          mapType: mapType,
          coords: Coords(school.latitude, school.longitude),
          title: school.name,
        );
        return;
      }
    }
  }
}
