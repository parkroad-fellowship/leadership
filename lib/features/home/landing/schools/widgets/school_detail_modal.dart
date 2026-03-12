import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:prf_design/prf_design.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showSchoolDetailModal(
  BuildContext context,
  PRFSchool school, {
  required List<PRFContactType> contactTypes,
  required VoidCallback onDataChanged,
}) {
  final theme = Theme.of(context);
  context.read<ContactCubit>().loadForSchool(school.ulid);

  WoltModalSheet.show<void>(
    context: context,
    pageListBuilder: (modalContext) => [
      WoltModalSheetPage(
        backgroundColor: Colors.white,
        topBarTitle: Text(
          school.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(modalContext),
        ),
        child: _SchoolDetailContent(
          school: school,
          contactTypes: contactTypes,
          onDataChanged: onDataChanged,
        ),
      ),
    ],
  );
}

class _SchoolDetailContent extends StatelessWidget {
  const _SchoolDetailContent({
    required this.school,
    required this.contactTypes,
    required this.onDataChanged,
  });

  final PRFSchool school;
  final List<PRFContactType> contactTypes;
  final VoidCallback onDataChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection(
            theme,
            'School Information',
            Icons.school,
            [
              _buildDetailRow(theme, 'Name', school.name),
              _buildDetailRow(
                theme,
                'Institution Type',
                school.institutionType.name,
              ),
              _buildDetailRow(
                theme,
                'Total Students',
                school.totalStudents.toString(),
              ),
              _buildDetailRow(theme, 'Address', school.address),
              _buildDetailRow(
                theme,
                'Description',
                school.description != 'N/A'
                    ? school.description
                    : 'No description',
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          _buildDetailSection(
            theme,
            'Location',
            Icons.map,
            [
              LocationDisplay(
                latitude: school.latitude,
                longitude: school.longitude,
                schoolName: school.name,
                onOpenInMaps: () => _openSchoolInMaps(context),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          _ContactsSection(
            school: school,
            contactTypes: contactTypes,
            onDataChanged: onDataChanged,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _openSchoolInMaps(BuildContext context) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No map apps available')),
      );
      return;
    }

    if (availableMaps.length == 1) {
      await availableMaps.first.showMarker(
        coords: Coords(school.latitude, school.longitude),
        title: school.name,
      );
      return;
    }

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: availableMaps
                .map(
                  (map) => ListTile(
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      map.showMarker(
                        coords: Coords(school.latitude, school.longitude),
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

  Widget _buildDetailSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: PRFElevationTokens.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      ),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PRFSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.md,
                  vertical: PRFSpacingTokens.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  const _ContactsSection({
    required this.school,
    required this.contactTypes,
    required this.onDataChanged,
  });

  final PRFSchool school;
  final List<PRFContactType> contactTypes;
  final VoidCallback onDataChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ContactCubit, ResourceState<PRFContact>>(
      listener: (context, state) {
        if (state case ResourceMutated<PRFContact>()) {
          context.read<ContactCubit>().loadForSchool(school.ulid);
          onDataChanged();
        }
        if (state case ResourceError<PRFContact>(:final message)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
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

        return Card(
          elevation: PRFElevationTokens.sm,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactsHeader(context, theme, contacts),
                Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                  child: _buildContactsBody(context, theme, state, contacts),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsHeader(
    BuildContext context,
    ThemeData theme,
    List<PRFContact> contacts,
  ) {
    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.primary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              Icons.contacts,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  '${contacts.length} linked to this school',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<ContactCubit>().loadForSchool(school.ulid),
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Refresh contacts',
          ),
          const SizedBox(width: PRFSpacingTokens.xs),
          TextButton.icon(
            onPressed: () => _showContactForm(context, null),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add Contact'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.md,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsBody(
    BuildContext context,
    ThemeData theme,
    ResourceState<PRFContact> state,
    List<PRFContact> contacts,
  ) {
    if (state is ResourceListLoading<PRFContact>) {
      return const Center(child: PRFCircularProgressIndicator());
    }

    if (state case ResourceError<PRFContact>(:final message)
        when contacts.isEmpty) {
      return PRFEmptyView(
        label: 'Could not load contacts',
        description: message,
        icon: Icons.error_outline,
        actionLabel: 'Retry',
        onActionPressed: () =>
            context.read<ContactCubit>().loadForSchool(school.ulid),
      );
    }

    if (contacts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No contacts added yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'Add at least one contact so teams '
            'can reach the right person fast.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: PRFPrimaryButton(
              onPressed: () => _showContactForm(context, null),
              title: 'Add Contact',
              disabled: false,
            ),
          ),
        ],
      );
    }

    return Column(
      children: contacts
          .map((contact) => _ContactCard(
                contact: contact,
                school: school,
                contactTypes: contactTypes,
                onDataChanged: onDataChanged,
              ))
          .toList(),
    );
  }

  void _showContactForm(BuildContext context, PRFContact? contact) {
    if (contactTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contact types are still loading. Please retry in a moment.',
          ),
        ),
      );
      return;
    }

    final theme = Theme.of(context);

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            contact == null ? 'Add Contact' : 'Edit Contact',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(modalContext),
          ),
          child: ContactFormViewHandset(
            contact: contact,
            schoolUlid: school.ulid,
            contactTypes: contactTypes,
            onSaved: () {
              context.read<ContactCubit>().loadForSchool(school.ulid);
              onDataChanged();
            },
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.school,
    required this.contactTypes,
    required this.onDataChanged,
  });

  final PRFContact contact;
  final PRFSchool school;
  final List<PRFContactType> contactTypes;
  final VoidCallback onDataChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameRow(theme),
                        const SizedBox(height: PRFSpacingTokens.md),
                        _buildPhoneRow(context, theme),
                        if (contact.email != null) ...[
                          const SizedBox(height: PRFSpacingTokens.sm),
                          _buildEmailRow(theme),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            contact.name,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (contact.contactType != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.sm,
              vertical: PRFSpacingTokens.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              contact.contactType!.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.phone,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            contact.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCallButton(context, theme),
            _buildContactActions(context, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailRow(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.email,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            contact.email!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton(BuildContext context, ThemeData theme) {
    return FilledButton.tonalIcon(
      onPressed: () => _callPhoneNumber(context, contact.phone),
      icon: const Icon(Icons.call, size: 16),
      label: const Text('Call'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildContactActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit contact',
          icon: Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => _showEditContactForm(context),
        ),
        IconButton(
          tooltip: 'Delete contact',
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
          onPressed: () => _showDeleteContactDialog(context),
        ),
      ],
    );
  }

  void _showEditContactForm(BuildContext context) {
    if (contactTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contact types are still loading. Please retry in a moment.',
          ),
        ),
      );
      return;
    }

    final theme = Theme.of(context);

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            'Edit Contact',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(modalContext),
          ),
          child: ContactFormViewHandset(
            contact: contact,
            schoolUlid: school.ulid,
            contactTypes: contactTypes,
            onSaved: () {
              context.read<ContactCubit>().loadForSchool(school.ulid);
              onDataChanged();
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteContactDialog(BuildContext context) {
    final contactCubit = context.read<ContactCubit>();

    PRFConfirmationDialog.show(
      context,
      title: 'Delete Contact',
      isDestructive: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete ${contact.name}?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          Text(
            'This cannot be undone.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
      confirmLabel: 'Delete',
      onConfirm: () => contactCubit.deleteContact(ulid: contact.ulid),
    );
  }

  Future<void> _callPhoneNumber(BuildContext context, String phone) async {
    final sanitized = phone.trim();
    if (sanitized.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available for this contact'),
        ),
      );
      return;
    }

    final callUri = Uri(scheme: 'tel', path: sanitized);
    final didLaunch = await Misc.openUrl(callUri);

    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch your phone dialer'),
        ),
      );
    }
  }
}
