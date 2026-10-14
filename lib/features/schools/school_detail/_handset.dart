import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/schools/actions/school_form/_handset.dart';
import 'package:leadership/features/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/schools/cubit/school_cubit.dart';
import 'package:leadership/features/schools/widgets/school_contact_row.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:prf_design/prf_design.dart';

class SchoolDetailPageHandset extends StatefulWidget {
  const SchoolDetailPageHandset({required this.schoolUlid, super.key});

  final String schoolUlid;

  @override
  State<SchoolDetailPageHandset> createState() =>
      _SchoolDetailPageHandsetState();
}

class _SchoolDetailPageHandsetState extends State<SchoolDetailPageHandset> {
  /// Contacts are not school-keyed in Hive, so this page renders the contacts
  /// embedded in the school. After a successful contact save the school is
  /// refetched so those embedded contacts update.
  void _refreshSchool() {
    context.read<SchoolCubit>()
      ..invalidate()
      ..loadAll();
  }

  PRFSchool? _lastSchool;

  PRFSchool? get _school {
    final state = context.read<SchoolCubit>().state;
    final items = switch (state) {
      ResourceListLoaded<PRFSchool>(:final items) => items,
      ResourceListLoading<PRFSchool>(:final items) => items,
      ResourceMutating<PRFSchool>(:final items) => items,
      ResourceError<PRFSchool>(:final items) => items,
      _ => <PRFSchool>[],
    };
    final found = items.cast<PRFSchool?>().firstWhere(
      (s) => s!.ulid == widget.schoolUlid,
      orElse: () => null,
    );
    // A refresh can momentarily emit an empty list; keep the last school.
    if (found != null) _lastSchool = found;
    return found ?? (items.isEmpty ? _lastSchool : null);
  }

  List<PRFContactType> get _contactTypes {
    final state = context.read<ContactTypeCubit>().state;
    return switch (state) {
      ResourceListLoaded<PRFContactType>(:final items) => items,
      ResourceMutating<PRFContactType>(:final items) => items,
      ResourceError<PRFContactType>(:final items) => items,
      _ => <PRFContactType>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<SchoolCubit, ResourceState<PRFSchool>>(
      builder: (context, state) {
        final school = _school;
        if (school == null) {
          return Scaffold(
            appBar: PRFAppBar(
              title: l10n.schoolsDetailTitle,
              onBack: () => context.router.maybePop(),
            ),
            body: const Center(child: PRFCircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                ColoredBox(
                  color: theme.colorScheme.primary,
                  child: Column(
                    children: [
                      PRFBrandedNavBar(
                        title: l10n.schoolsTitle,
                        onBack: () => context.router.maybePop(),
                        actions: [
                          PRFNavBarAction(
                            label: l10n.edit,
                            icon: Icons.edit_outlined,
                            tooltip: l10n.schoolsEditTooltip,
                            variant: PRFNavBarActionVariant.neutral,
                            onPressed: () => _showEditForm(school),
                          ),
                          const SizedBox(width: PRFSpacingTokens.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: PRFOpacities.hairline,
                              ),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.md,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: PRFOpacities.muted,
                                ),
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              tooltip: l10n.schoolsMoreOptions,
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onPrimary,
                                size: PRFSizeTokens.iconMd,
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(school);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: PRFSizeTokens.iconMd,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(
                                        width: PRFSpacingTokens.sm,
                                      ),
                                      Text(
                                        l10n.schoolsDeleteSchool,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor: theme.colorScheme.onPrimary,
                              unselectedLabelColor: theme.colorScheme.onPrimary
                                  .withValues(alpha: PRFOpacities.stronger),
                              indicatorColor: theme.colorScheme.secondary,
                              dividerColor: theme.colorScheme.onPrimary
                                  .withValues(alpha: PRFOpacities.muted),
                              labelStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: PRFSpacingTokens.sm,
                              ),
                              tabs: [
                                Tab(text: l10n.schoolsTabOverview),
                                Tab(text: l10n.schoolsTabContacts),
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
                    children: [
                      _buildOverviewTab(theme, school),
                      _buildContactsTab(theme, school),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(ThemeData theme, PRFSchool school) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(theme, school),
          Transform.translate(
            offset: const Offset(0, -PRFSpacingTokens.md),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PRFSpacingTokens.lg,
                0,
                PRFSpacingTokens.lg,
                PRFSpacingTokens.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(theme, school),
                  if (school.latitude != 0.0 || school.longitude != 0.0) ...[
                    const SizedBox(height: PRFSpacingTokens.lg),
                    _buildLocationRow(theme, school),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab(ThemeData theme, PRFSchool school) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.lg,
        PRFSpacingTokens.xxxl,
      ),
      child: _buildContactsPreview(theme, school),
    );
  }

  // -----------------------------------------------------------
  // Hero section
  // -----------------------------------------------------------

  Widget _buildHeroSection(ThemeData theme, PRFSchool school) {
    final initials = _getInitials(school.name);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary,
            primary,
            Color.lerp(primary, theme.colorScheme.surface, 0.12)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PRFSpacingTokens.xxl),
        child: Column(
          children: [
            // Avatar
            Container(
              width: PRFSizeTokens.iconHero,
              height: PRFSizeTokens.iconHero,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: PRFOpacities.muted),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                border: Border.all(
                  color: onPrimary.withValues(alpha: PRFOpacities.muted),
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.md),
            // School name
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.xxl,
              ),
              child: Text(
                school.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.sm),
            // Type + student count badges
            Wrap(
              alignment: WrapAlignment.center,
              spacing: PRFSpacingTokens.sm,
              runSpacing: PRFSpacingTokens.sm,
              children: [
                // Institution type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.md,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                  ),
                  child: Text(
                    school.institutionType.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Students badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.md,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: onPrimary.withValues(alpha: PRFOpacities.muted),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                  ),
                  child: Text(
                    context.l10n.schoolsStudentCount(school.totalStudents),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            Container(
              height: PRFSpacingTokens.lg,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(
                      alpha: PRFOpacities.stronger,
                    ),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // School Information
  // -----------------------------------------------------------

  Widget _buildInfoSection(ThemeData theme, PRFSchool school) {
    return _buildSectionCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              context.l10n.schoolsInfoHeading,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          _infoRow(theme, context.l10n.schoolsAddressLabel, school.address),
          if (school.description.isNotEmpty && school.description != 'N/A')
            _infoRow(
              theme,
              context.l10n.schoolsDescriptionLabel,
              school.description,
            ),
          if (school.directions.isNotEmpty && school.directions != 'N/A')
            _infoRow(
              theme,
              context.l10n.schoolsDirectionsLabel,
              school.directions,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Location row
  // -----------------------------------------------------------

  Widget _buildLocationRow(ThemeData theme, PRFSchool school) {
    final l10n = context.l10n;
    return _buildSectionCard(
      theme: theme,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: l10n.schoolsOpenInMaps,
        hint: l10n.schoolsOpenInMapsHint,
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _openSchoolInMaps(school),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            child: Padding(
              padding: const EdgeInsets.all(PRFSpacingTokens.md),
              child: Row(
                children: [
                  // Location icon container
                  Container(
                    width: PRFSizeTokens.iconXxl,
                    height: PRFSizeTokens.iconXxl,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: PRFSizeTokens.iconMd,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.schoolsOpenInMaps,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: PRFSpacingTokens.xs / 2),
                        Text(
                          _coordsText(school),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                    size: PRFSizeTokens.iconLg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSchoolInMaps(PRFSchool school) async {
    final mapTypes = [MapApp.google, MapApp.googleGo, MapApp.apple];

    final availableMaps = await MapLauncher.marker(
      LocationCoords(school.latitude, school.longitude, title: school.name),
    ).getSupportedMaps(mapTypes);

    if (availableMaps.isEmpty) {
      if (!mounted) return;
      PRFSnackbar.error(context, context.l10n.schoolsNoMapApps);
      return;
    }

    if (availableMaps.length == 1) {
      await availableMaps.first.show();
      return;
    }

    if (!mounted) return;
    await PRFBottomSheet.show<void>(
      context,
      title: context.l10n.schoolsChooseMapApp,
      child: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: availableMaps
              .map(
                (map) => ListTile(
                  minTileHeight: PRFSizeTokens.minTouchTarget,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    map.show();
                  },
                  title: Text(map.name),
                  leading: const Icon(Icons.map, size: PRFSizeTokens.iconLg),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // Contacts preview
  // -----------------------------------------------------------

  Widget _buildContactsPreview(ThemeData theme, PRFSchool school) {
    final contacts = school.contacts;
    final l10n = context.l10n;

    return _buildSectionCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.schoolContactsHeading(contacts.length),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              PRFNavBarAction(
                label: l10n.commonNew,
                icon: Icons.add,
                tooltip: l10n.schoolContactsAddTooltip,
                onPressed: () => _showContactForm(null, school),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          // Body
          if (contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: PRFSpacingTokens.lg,
              ),
              child: Center(
                child: Text(
                  l10n.schoolContactsEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...contacts.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
                child: SchoolContactRow(
                  contact: c,
                  onTapEdit: () => _showContactForm(c, school),
                  onTapCall: c.phone.isEmpty
                      ? null
                      : () => _callPhoneNumber(c.phone),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(PRFSpacingTokens.lg),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
      ),
      child: child,
    );
  }

  // -----------------------------------------------------------
  // Actions
  // -----------------------------------------------------------

  void _showEditForm(PRFSchool school) {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.schoolsEdit,
      child: SchoolFormViewHandset(school: school, onSaved: () {}),
    );
  }

  void _showDeleteDialog(PRFSchool school) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    PRFConfirmationDialog.show(
      context,
      title: l10n.schoolsDeleteTitle,
      isDestructive: true,
      confirmLabel: l10n.schoolsDeleteSchool,
      cancelLabel: l10n.cancel,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(
                alpha: PRFOpacities.glow,
              ),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              border: Border.all(
                color: theme.colorScheme.error.withValues(
                  alpha: PRFOpacities.glow,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  school.institutionType.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Text(
            l10n.schoolsCannotUndo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onConfirm: () {
        context.read<SchoolCubit>().deleteSchool(ulid: school.ulid);
        context.router.maybePop();
      },
    );
  }

  void _showContactForm(PRFContact? contact, PRFSchool school) {
    final contactTypes = _contactTypes;
    if (contactTypes.isEmpty) {
      PRFSnackbar.error(context, context.l10n.schoolContactsTypesLoading);
      return;
    }

    PRFBottomSheet.show<void>(
      context,
      title: contact == null
          ? context.l10n.schoolContactsAdd
          : context.l10n.schoolContactsEdit,
      child: ContactFormViewHandset(
        contact: contact,
        schoolUlid: school.ulid,
        contactTypes: contactTypes,
        onSaved: _refreshSchool,
      ),
    );
  }

  Future<void> _callPhoneNumber(String phone) async {
    final sanitized = phone.trim();
    if (sanitized.isEmpty) {
      if (!mounted) return;
      PRFSnackbar.error(context, context.l10n.schoolContactsNoPhone);
      return;
    }

    final callUri = Uri(scheme: 'tel', path: sanitized);
    final didLaunch = await Misc.openUrl(callUri);

    if (!didLaunch && mounted) {
      PRFSnackbar.error(context, context.l10n.schoolContactsCallFailed);
    }
  }

  String _coordsText(PRFSchool school) {
    final lat = school.latitude.toStringAsFixed(4);
    final lng = school.longitude.toStringAsFixed(4);
    return '$lat, $lng';
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
