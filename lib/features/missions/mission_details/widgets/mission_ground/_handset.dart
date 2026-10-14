import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/utils/misc.dart';
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
          description: l10n.mgSchoolUnavailable,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.sm),
        child: Column(
          children: [
            // Hero Mission Card
            _buildHeroCard(context, mission, school, l10n, theme),
            const SizedBox(height: PRFSpacingTokens.xl),

            // Quick Actions Row
            _buildQuickActions(context, mission, l10n, theme),
            const SizedBox(height: PRFSpacingTokens.xl),

            // Mission Intelligence Grid
            _buildIntelligenceGrid(context, mission, school, l10n, theme),
            const SizedBox(height: PRFSpacingTokens.xl),

            // Contact Command Center
            _buildContactCenter(context, school, l10n, theme),
            const SizedBox(height: PRFSpacingTokens.xl),

            // Location & Navigation Hub
            _buildLocationHub(context, mission, school, l10n, theme),
            const SizedBox(height: PRFSpacingTokens.xl),
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
                theme.colorScheme.primary.withValues(
                  alpha: PRFOpacities.stronger,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
            boxShadow: PRFShadowTokens.heroGlow(theme.colorScheme.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PRFSpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.md,
                        vertical: PRFSpacingTokens.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                      ),
                      child: Text(
                        mission.status.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: PRFOpacities.muted,
                        ),
                        borderRadius: BorderRadius.circular(
                          PRFRadiusTokens.smd,
                        ),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: PRFSizeTokens.iconMd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                Text(
                  school.name.toUpperCase(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                if (mission.theme?.isNotEmpty ?? false) ...[
                  const SizedBox(height: PRFSpacingTokens.sm),
                  Text(
                    mission.theme!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: PRFOpacities.nearOpaque,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: PRFSpacingTokens.xl),
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
                const SizedBox(height: PRFSpacingTokens.sm),
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
                  const SizedBox(height: PRFSpacingTokens.lg),
                  _buildPrepNotes(context, mission, l10n, theme),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDateTimeChip(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary.withValues(
            alpha: PRFOpacities.hairline,
          ),
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onPrimary,
              size: PRFSizeTokens.iconSm,
            ),
            const SizedBox(width: PRFSpacingTokens.sm),
            Flexible(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
                  theme.colorScheme.onSecondary,
                  () => Misc.openUrl(Uri.parse(mission.whatsAppLink!)),
                  theme,
                ),
              ),
            if (mission.whatsAppLink != null)
              const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: _buildActionButton(
                context,
                Icons.map_rounded,
                l10n.navigate,
                theme.colorScheme.tertiary,
                theme.colorScheme.onTertiary,
                () => _openMap(mission),
                theme,
              ),
            ),
          ],
        )
        .animate(
          delay: PRFMotionTokens.resolve(context, PRFMotionTokens.stagger2),
        )
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Color onColor,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    final radius = BorderRadius.circular(PRFRadiusTokens.md);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: PRFShadowTokens.badge(color),
        ),
        child: Material(
          color: color,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PRFSizeTokens.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PRFSpacingTokens.lg,
                  horizontal: PRFSpacingTokens.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: onColor, size: PRFSizeTokens.iconMd),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: onColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            const SizedBox(height: PRFSpacingTokens.lg),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: PRFSpacingTokens.md,
              crossAxisSpacing: PRFSpacingTokens.md,
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
        .animate(
          delay: PRFMotionTokens.resolve(context, PRFMotionTokens.stagger4),
        )
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
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
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: PRFOpacities.subtle),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(color: color.withValues(alpha: PRFOpacities.muted)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(PRFSpacingTokens.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: PRFOpacities.muted),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
            ),
            child: Icon(icon, color: color, size: PRFSizeTokens.iconMd),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
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
          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: PRFOpacities.subtle,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: PRFOpacities.subtle,
                      ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      Icons.contact_phone_rounded,
                      color: theme.colorScheme.primary,
                      size: PRFSizeTokens.iconMd,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Text(
                    l10n.contactPersons,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              if (school.contacts.isEmpty)
                Text(
                  l10n.mgNoContacts,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...school.contacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
                    child: Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          PRFRadiusTokens.smd,
                        ),
                        boxShadow: PRFShadowTokens.card(
                          theme.colorScheme.shadow,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: PRFOpacities.subtle),
                            child: Text(
                              contact.name.isNotEmpty
                                  ? contact.name.substring(0, 1).toUpperCase()
                                  : '?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: PRFSpacingTokens.md),
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
                                  contact.contactType?.name ?? '',
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
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.sm,
                              ),
                            ),
                            child: IconButton(
                              tooltip: l10n.mgCallContact(contact.name),
                              onPressed: () async {
                                final uri = Uri(
                                  scheme: 'tel',
                                  path: contact.phone,
                                );
                                await Misc.openUrl(uri);
                              },
                              icon: Icon(
                                Icons.phone,
                                color: theme.colorScheme.onPrimary,
                                size: PRFSizeTokens.iconMd,
                              ),
                            ),
                          ).animate(
                            effects: [
                              ShakeEffect(
                                duration: PRFMotionTokens.resolve(
                                  context,
                                  const Duration(seconds: 2),
                                ),
                                delay: PRFMotionTokens.resolve(
                                  context,
                                  PRFMotionTokens.stagger5,
                                ),
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
        .animate(
          delay: PRFMotionTokens.resolve(context, PRFMotionTokens.enterShort),
        )
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
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
          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.tertiary.withValues(
                  alpha: PRFOpacities.subtle,
                ),
                theme.colorScheme.tertiary.withValues(
                  alpha: PRFOpacities.faint,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(
                alpha: PRFOpacities.muted,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(
                        alpha: PRFOpacities.muted,
                      ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: theme.colorScheme.tertiary,
                      size: PRFSizeTokens.iconMd,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
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
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: IconButton(
                      tooltip: l10n.mgOpenInMaps,
                      onPressed: () => _openMap(mission),
                      icon: Icon(
                        Icons.map_rounded,
                        color: theme.colorScheme.onTertiary,
                        size: PRFSizeTokens.iconMd,
                      ),
                    ),
                  ).animate(
                    effects: [
                      ShakeEffect(
                        duration: PRFMotionTokens.resolve(
                          context,
                          const Duration(seconds: 2),
                        ),
                        delay: PRFMotionTokens.resolve(
                          context,
                          PRFMotionTokens.stagger5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.smd),
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
                      const SizedBox(height: PRFSpacingTokens.sm),
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
              const SizedBox(height: PRFSpacingTokens.lg),
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
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: _buildTravelInfo(
                      context,
                      Icons.schedule_rounded,
                      l10n.mgTravelTime,
                      school.staticDuration,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: PRFSizeTokens.iconSm,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
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
        .animate(
          delay: PRFMotionTokens.resolve(context, PRFMotionTokens.enterMedium),
        )
        .fadeIn(
          duration: PRFMotionTokens.resolve(
            context,
            PRFMotionTokens.enterShort,
          ),
        )
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
      padding: const EdgeInsets.all(PRFSpacingTokens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.tertiary,
            size: PRFSizeTokens.iconMd,
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
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
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.subtle,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.subtle,
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Icon(
                  Icons.note_alt_rounded,
                  color: theme.colorScheme.primary,
                  size: PRFSizeTokens.iconMd,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.md),
              Text(
                l10n.missionPrepNotes,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Container(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(PRFRadiusTokens.smd),
            ),
            child: Text(
              mission.missionPrepNotes!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(PRFMission mission) async {
    final school = mission.school;
    if (school == null) return;

    // Open the first installed app, in preference order. Asking for each app
    // separately used to open several in turn and crash when one was missing.
    final maps = await MapLauncher.marker(
      LocationCoords(school.latitude, school.longitude, title: school.name),
    ).getSupportedMaps([MapApp.google, MapApp.googleGo, MapApp.apple]);

    if (maps.isEmpty) {
      if (mounted) PRFSnackbar.info(context, context.l10n.mgNoMapsApp);
      return;
    }

    await maps.first.show();
  }
}
