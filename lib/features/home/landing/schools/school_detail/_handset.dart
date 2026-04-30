import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/school_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/features/home/landing/schools/widgets/school_contact_row.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:prf_design/prf_design.dart';

class SchoolDetailPageHandset extends StatefulWidget {
  const SchoolDetailPageHandset({
    required this.schoolUlid,
    super.key,
  });

  final String schoolUlid;

  @override
  State<SchoolDetailPageHandset> createState() =>
      _SchoolDetailPageHandsetState();
}

class _SchoolDetailPageHandsetState extends State<SchoolDetailPageHandset> {
  @override
  void initState() {
    super.initState();
    context.read<ContactCubit>().loadForSchool(widget.schoolUlid);
  }

  PRFSchool? get _school {
    final state = context.read<SchoolCubit>().state;
    final items = switch (state) {
      ResourceListLoaded<PRFSchool>(:final items) => items,
      ResourceMutating<PRFSchool>(:final items) => items,
      ResourceMutated<PRFSchool>(:final items) => items,
      ResourceError<PRFSchool>(:final items) => items,
      _ => <PRFSchool>[],
    };
    return items.cast<PRFSchool?>().firstWhere(
      (s) => s!.ulid == widget.schoolUlid,
      orElse: () => null,
    );
  }

  List<PRFContactType> get _contactTypes {
    final state = context.read<ContactTypeCubit>().state;
    return switch (state) {
      ResourceListLoaded<PRFContactType>(:final items) => items,
      ResourceMutated<PRFContactType>(:final items) => items,
      ResourceMutating<PRFContactType>(:final items) => items,
      ResourceError<PRFContactType>(:final items) => items,
      _ => <PRFContactType>[],
    };
  }

  void _reloadData() {
    context.read<SchoolCubit>().loadAll();
    context.read<ContactCubit>().loadForSchool(widget.schoolUlid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SchoolCubit, ResourceState<PRFSchool>>(
      builder: (context, state) {
        final school = _school;
        if (school == null) {
          return Scaffold(
            appBar: PRFAppBar(
              title: 'School Details',
              onBack: () => context.router.maybePop(),
            ),
            body: const Center(
              child: PRFCircularProgressIndicator(),
            ),
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
                        title: 'Schools',
                        onBack: () => context.router.maybePop(),
                        actions: [
                          PRFHeaderActionButton(
                            label: 'Edit',
                            variant: PRFHeaderActionButtonVariant.neutral,
                            onTap: () => _showEditForm(school),
                          ),
                          const SizedBox(width: PRFSpacingTokens.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.14,
                              ),
                              borderRadius: BorderRadius.circular(
                                PRFRadiusTokens.md,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onPrimary,
                                size: 20,
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(school);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: PRFSpacingTokens.sm,
                                      ),
                                      Text('Delete School'),
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
                                  .withValues(alpha: 0.65),
                              indicatorColor: theme.colorScheme.secondary,
                              dividerColor: theme.colorScheme.onPrimary
                                  .withValues(
                                    alpha: 0.2,
                                  ),
                              labelStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: PRFSpacingTokens.sm,
                              ),
                              tabs: const [
                                Tab(text: 'Overview'),
                                Tab(text: 'Contacts'),
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

  Widget _buildOverviewTab(
    ThemeData theme,
    PRFSchool school,
  ) {
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
                  _buildInfoSection(
                    theme,
                    school,
                  ),
                  if (school.latitude != 0.0 || school.longitude != 0.0) ...[
                    const SizedBox(
                      height: PRFSpacingTokens.lg,
                    ),
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

  Widget _buildContactsTab(
    ThemeData theme,
    PRFSchool school,
  ) {
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

  Widget _buildHeroSection(
    ThemeData theme,
    PRFSchool school,
  ) {
    final initials = _getInitials(school.name);
    final mode = theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    final onPrimary = mode == ThemeMode.dark
        ? PRFColors.gray100
        : theme.colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            PRFColorPalette.navy600,
            PRFColorPalette.navy400,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PRFSpacingTokens.xxl,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  PRFRadiusTokens.xl,
                ),
                border: Border.all(
                  color: onPrimary.withValues(alpha: 0.2),
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
            const SizedBox(
              height: PRFSpacingTokens.md,
            ),
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
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: PRFSpacingTokens.sm,
            ),
            // Type + student count badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Institution type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.md,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: PRFColors.limeGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      PRFRadiusTokens.sm,
                    ),
                  ),
                  child: Text(
                    school.institutionType.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: mode == ThemeMode.dark
                          ? PRFColors.gray100
                          : theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  width: PRFSpacingTokens.sm,
                ),
                // Students badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.md,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      PRFRadiusTokens.sm,
                    ),
                  ),
                  child: Text(
                    '${school.totalStudents}'
                    ' students',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: onPrimary.withValues(alpha: 0.95),
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
                    theme.colorScheme.surface.withValues(alpha: 0.8),
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

  Widget _buildInfoSection(
    ThemeData theme,
    PRFSchool school,
  ) {
    return _buildSectionCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCHOOL INFORMATION',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          _infoRow(theme, 'Address', school.address),
          if (school.description.isNotEmpty && school.description != 'N/A')
            _infoRow(
              theme,
              'Description',
              school.description,
            ),
          if (school.directions.isNotEmpty && school.directions != 'N/A')
            _infoRow(
              theme,
              'Directions',
              school.directions,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(
    ThemeData theme,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: PRFSpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Location row
  // -----------------------------------------------------------

  Widget _buildLocationRow(
    ThemeData theme,
    PRFSchool school,
  ) {
    final mode = theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return _buildSectionCard(
      theme: theme,
      padding: const EdgeInsets.all(PRFSpacingTokens.md),
      child: InkWell(
        onTap: () => _openSchoolInMaps(school),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        child: Row(
          children: [
            // Location icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PRFColorPalette.navy50,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.location_on,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(
              width: PRFSpacingTokens.md,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View on Map',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mode == ThemeMode.dark
                          ? PRFColors.gray100
                          : PRFColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _coordsText(school),
                    style: TextStyle(
                      fontSize: 11,
                      color: mode == ThemeMode.dark
                          ? PRFColors.gray500
                          : PRFColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSchoolInMaps(
    PRFSchool school,
  ) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      if (!mounted) return;
      PRFSnackbar.error(
        context,
        'No map apps available',
      );
      return;
    }

    if (availableMaps.length == 1) {
      await availableMaps.first.showMarker(
        coords: Coords(
          school.latitude,
          school.longitude,
        ),
        title: school.name,
      );
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: availableMaps
                .map(
                  (map) => ListTile(
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                      );
                      map.showMarker(
                        coords: Coords(
                          school.latitude,
                          school.longitude,
                        ),
                        title: school.name,
                      );
                    },
                    title: Text(map.mapName),
                    leading: const Icon(Icons.map),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // Contacts preview
  // -----------------------------------------------------------

  Widget _buildContactsPreview(
    ThemeData theme,
    PRFSchool school,
  ) {
    return BlocConsumer<ContactCubit, ResourceState<PRFContact>>(
      listener: (context, state) {
        if (state case ResourceMutated<PRFContact>()) {
          context.read<ContactCubit>().loadForSchool(widget.schoolUlid);
          context.read<SchoolCubit>().loadAll();
        }
        if (state case ResourceError<PRFContact>(
          :final message,
        )) {
          PRFSnackbar.error(context, message);
        }
      },
      builder: (context, state) {
        final contacts = switch (state) {
          ResourceListLoaded<PRFContact>(:final items) => items,
          ResourceMutating<PRFContact>(:final items) => items,
          ResourceMutated<PRFContact>(:final items) => items,
          ResourceError<PRFContact>(:final items) => items,
          _ => school.contacts,
        };

        return _buildSectionCard(
          theme: theme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CONTACTS'
                      ' (${contacts.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  PRFHeaderActionButton(
                    label: 'New',
                    icon: Icons.add,
                    onTap: () => _showContactForm(
                      null,
                      school,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: PRFSpacingTokens.md,
              ),
              // Body
              if (state is ResourceListLoading<PRFContact>)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(
                      PRFSpacingTokens.lg,
                    ),
                    child: PRFCircularProgressIndicator(),
                  ),
                )
              else if (contacts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: PRFSpacingTokens.lg,
                  ),
                  child: Center(
                    child: Text(
                      'No contacts yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...contacts.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: PRFSpacingTokens.sm,
                    ),
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
      },
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
          color: theme.colorScheme.outline.withValues(alpha: 0.34),
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
      title: 'Edit School',
      child: SchoolFormViewHandset(
        school: school,
        onSaved: _reloadData,
      ),
    );
  }

  void _showDeleteDialog(PRFSchool school) {
    final theme = Theme.of(context);

    PRFConfirmationDialog.show(
      context,
      title: 'Delete School',
      isDestructive: true,
      confirmLabel: 'Delete',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete '
            'this school?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(
            height: PRFSpacingTokens.lg,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              PRFSpacingTokens.lg,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                PRFRadiusTokens.md,
              ),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
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
                const SizedBox(
                  height: PRFSpacingTokens.sm,
                ),
                Text(
                  school.institutionType.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: PRFSpacingTokens.lg,
          ),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
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

  void _showContactForm(
    PRFContact? contact,
    PRFSchool school,
  ) {
    final contactTypes = _contactTypes;
    if (contactTypes.isEmpty) {
      PRFSnackbar.error(
        context,
        'Contact types are still loading. '
        'Please retry in a moment.',
      );
      return;
    }

    PRFBottomSheet.show<void>(
      context,
      title: contact == null ? 'Add Contact' : 'Edit Contact',
      child: ContactFormViewHandset(
        contact: contact,
        schoolUlid: school.ulid,
        contactTypes: contactTypes,
        onSaved: () {
          context.read<ContactCubit>().loadForSchool(school.ulid);
          context.read<SchoolCubit>().loadAll();
        },
      ),
    );
  }

  Future<void> _callPhoneNumber(
    String phone,
  ) async {
    final sanitized = phone.trim();
    if (sanitized.isEmpty) {
      if (!mounted) return;
      PRFSnackbar.error(
        context,
        'No phone number available',
      );
      return;
    }

    final callUri = Uri(
      scheme: 'tel',
      path: sanitized,
    );
    final didLaunch = await Misc.openUrl(callUri);

    if (!didLaunch && mounted) {
      PRFSnackbar.error(
        context,
        'Could not launch your phone dialer',
      );
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
