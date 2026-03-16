import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/features/home/landing/schools/widgets/school_contact_row.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/_index.dart';
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
          PRFHeaderActionButton(
            label: 'New',
            icon: Icons.add,
            onTap: () => _showContactForm(null),
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
              PRFSpacingTokens.lg,
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
                child: SchoolContactRow(
                  contact: contact,
                  onTapEdit: () => _showContactForm(contact),
                  onTapCall: contact.phone.isEmpty
                      ? null
                      : () => _callPhoneNumber(contact.phone),
                ),
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
                const SizedBox(height: PRFSpacingTokens.xs),
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
}
