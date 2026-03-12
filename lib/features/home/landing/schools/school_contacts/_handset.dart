import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class SchoolContactsPageHandset extends StatefulWidget {
  const SchoolContactsPageHandset({
    required this.schoolUlid,
    super.key,
  });

  final String schoolUlid;

  @override
  State<SchoolContactsPageHandset> createState() =>
      _SchoolContactsPageHandsetState();
}

class _SchoolContactsPageHandsetState extends State<SchoolContactsPageHandset> {
  @override
  void initState() {
    super.initState();
    context.read<ContactCubit>().loadForSchool(widget.schoolUlid);
  }

  List<PRFContactType> get _contactTypes {
    final state = context.read<ContactTypeCubit>().state;
    return switch (state) {
      ResourceListLoaded<PRFContactType>(
        :final items,
      ) =>
        items,
      ResourceMutated<PRFContactType>(
        :final items,
      ) =>
        items,
      ResourceMutating<PRFContactType>(
        :final items,
      ) =>
        items,
      ResourceError<PRFContactType>(
        :final items,
      ) =>
        items,
      _ => <PRFContactType>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: PRFBrandedNavBar(
        title: 'Contacts',
        onBack: () => context.router.maybePop(),
        actions: [
          GestureDetector(
            onTap: () => _showContactForm(null),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.md,
                vertical: PRFSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: PRFColorPalette.lime900.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: PRFColorPalette.lime300,
                  ),
                  SizedBox(width: PRFSpacingTokens.xs),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: PRFColorPalette.lime300,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ContactCubit, ResourceState<PRFContact>>(
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
          return switch (state) {
            ResourceListLoading<PRFContact>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFContact>(
              :final items,
            )
                when items.isEmpty =>
              PRFEmptyView(
                label: 'No Contacts',
                description: 'Add a contact for this school',
                icon: Icons.contacts_outlined,
                actionLabel: 'Add Contact',
                onActionPressed: () => _showContactForm(null),
              ),
            ResourceListLoaded<PRFContact>(
              :final items,
            ) =>
              _buildList(theme, items),
            ResourceMutating<PRFContact>(
              :final items,
            ) =>
              _buildList(theme, items),
            ResourceMutated<PRFContact>(
              :final items,
            ) =>
              _buildList(theme, items),
            ResourceError<PRFContact>(
              :final items,
            )
                when items.isNotEmpty =>
              _buildList(theme, items),
            ResourceError<PRFContact>(
              :final message,
            ) =>
              PRFErrorView.fromMessage(
                message: message,
                onRetry: () => context.read<ContactCubit>().loadForSchool(
                  widget.schoolUlid,
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(
    ThemeData theme,
    List<PRFContact> contacts,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
            ),
            child: _buildListHeader(theme, contacts.length),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            PRFSpacingTokens.lg,
            0,
            PRFSpacingTokens.lg,
            PRFSpacingTokens.xxxl,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final contact = contacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
                child: _buildContactRow(theme, contact),
              );
            }, childCount: contacts.length),
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader(ThemeData theme, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            ),
            child: Icon(
              Icons.contacts_rounded,
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
                  '$count contacts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xs / 2),
                Text(
                  'Tap a contact to edit details quickly',
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildContactRow(
    ThemeData theme,
    PRFContact contact,
  ) {
    final initials = _getInitials(contact.name);

    // Build subtitle: "Type . Phone"
    final parts = <String>[];
    if (contact.contactType != null) {
      parts.add(contact.contactType!.name);
    }
    if (contact.phone.isNotEmpty) {
      parts.add(contact.phone);
    }
    final subtitle = parts.join(' \u00B7 ');

    return GestureDetector(
      onTap: () => _showContactForm(contact),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.14,
              ),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(
              width: PRFSpacingTokens.md,
            ),
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.sm,
                vertical: PRFSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
              ),
              child: Text(
                'Edit',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.sm),
            // Call button
            if (contact.phone.isNotEmpty)
              GestureDetector(
                onTap: () => _callPhoneNumber(
                  contact.phone,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.sm,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: PRFColorPalette.lime100,
                    border: Border.all(
                      color: PRFColorPalette.lime300,
                    ),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call,
                        size: 14,
                        color: PRFColorPalette.lime800,
                      ),
                      SizedBox(width: PRFSpacingTokens.xs / 2),
                      Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PRFColorPalette.lime800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------
  // Actions
  // -------------------------------------------

  void _showContactForm(PRFContact? contact) {
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
        schoolUlid: widget.schoolUlid,
        contactTypes: contactTypes,
        onSaved: () {
          context.read<ContactCubit>().loadForSchool(
            widget.schoolUlid,
          );
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

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
