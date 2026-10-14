import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/schools/actions/contact_form/_handset.dart';
import 'package:leadership/features/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/schools/cubit/school_cubit.dart';
import 'package:leadership/features/schools/widgets/school_contact_row.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:prf_design/prf_design.dart';

class SchoolContactsPageHandset extends StatefulWidget {
  const SchoolContactsPageHandset({required this.schoolUlid, super.key});

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: PRFBrandedNavBar(
        title: l10n.schoolContactsTitle,
        onBack: () => context.router.maybePop(),
        actions: [
          PRFNavBarAction(
            label: l10n.commonNew,
            icon: Icons.add,
            tooltip: l10n.schoolContactsAddTooltip,
            onPressed: () => _showContactForm(null),
          ),
        ],
      ),
      body: BlocConsumer<ContactCubit, ResourceState<PRFContact>>(
        listener: (context, state) {
          if (state case ResourceError<PRFContact>(
            :final items,
          ) when items.isNotEmpty) {
            PRFSnackbar.error(context, l10n.schoolContactsActionFailed);
          }
        },
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFContact>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFContact>(:final items) when items.isEmpty =>
              PRFEmptyView(
                label: l10n.schoolContactsEmptyTitle,
                description: l10n.schoolContactsEmptyMessage,
                icon: Icons.contacts_outlined,
                actionLabel: l10n.schoolContactsAdd,
                onActionPressed: () => _showContactForm(null),
              ),
            ResourceListLoaded<PRFContact>(:final items) => _buildList(
              theme,
              items,
            ),
            ResourceMutating<PRFContact>(:final items) => _buildList(
              theme,
              items,
            ),
            ResourceError<PRFContact>(:final items) when items.isNotEmpty =>
              _buildList(theme, items),
            ResourceError<PRFContact>() => PRFErrorView.fromMessage(
              title: l10n.schoolContactsLoadError,
              message: l10n.commonLoadErrorMessage,
              retryLabel: l10n.commonTryAgain,
              onRetry: () =>
                  context.read<ContactCubit>().loadForSchool(widget.schoolUlid),
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(ThemeData theme, List<PRFContact> contacts) {
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
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: PRFSizeTokens.iconXxl,
            height: PRFSizeTokens.iconXxl,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: PRFOpacities.hairline,
              ),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            ),
            child: Icon(
              Icons.contacts_rounded,
              color: theme.colorScheme.primary,
              size: PRFSizeTokens.iconMd,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.schoolsContactCount(count),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  context.l10n.schoolContactsTapToEdit,
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
        schoolUlid: widget.schoolUlid,
        contactTypes: contactTypes,
        onSaved: () {
          context.read<ContactCubit>().loadForSchool(widget.schoolUlid);
          context.read<SchoolCubit>().loadAll();
        },
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
}
