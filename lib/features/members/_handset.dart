import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/members/actions/member_form/_handset.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/members/widgets/member_card.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/misc.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class MembersPageHandset extends StatefulWidget {
  const MembersPageHandset({super.key});

  @override
  State<MembersPageHandset> createState() => _MembersPageHandsetState();
}

class _MembersPageHandsetState extends State<MembersPageHandset>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<MemberResourceCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFMember>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFMember>(:final items) when items.isEmpty =>
              PRFEmptyView(
                navBarTitle: l10n.membersTitle,
                onBackPressed: _goBackToHome,
                label: l10n.membersEmptyTitle,
                description: l10n.membersEmptyMessage,
                icon: Icons.people_outline,
                actionLabel: Misc.userCan(PRFPermissions.createMember)
                    ? l10n.membersAdd
                    : null,
                onActionPressed: Misc.userCan(PRFPermissions.createMember)
                    ? _showCreateMemberForm
                    : null,
              ),
            ResourceListLoaded<PRFMember>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFMember>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFMember>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFMember>() => PRFLeadershipErrorScreen(
              navBarTitle: l10n.membersTitle,
              title: l10n.membersLoadError,
              onBack: _goBackToHome,
              onRetry: _loadData,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<PRFMember> members) {
    final filtered = _searchQuery.isEmpty
        ? members
        : members
              .where((m) => m.fullName.toLowerCase().contains(_searchQuery))
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Navy branded header
          SliverToBoxAdapter(child: _buildHeader(theme, members.length)),
          // Floating search bar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.sm,
            ),
            sliver: SliverToBoxAdapter(child: _buildSearchBar(theme)),
          ),
          // Member list
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                  child: Text(
                    context.l10n.commonNoSearchMatches,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final member = filtered[index];
                  return MemberCard(
                    member: member,
                    index: index,
                    onTap: () => context.router.push(
                      MemberDetailsRoute(memberUlid: member.ulid),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: PRFSpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navy branded header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(ThemeData theme, int memberCount) {
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: context.l10n.membersTitle,
            onBack: _goBackToHome,
            actions: [
              if (Misc.userCan(PRFPermissions.createMember))
                PRFNavBarAction(
                  label: context.l10n.commonNew,
                  icon: Icons.add,
                  tooltip: context.l10n.membersAddTooltip,
                  onPressed: _showCreateMemberForm,
                ),
              if (Misc.userCan(PRFPermissions.createMember))
                const SizedBox(width: PRFSpacingTokens.sm),
              BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
                builder: (context, state) => switch (state) {
                  ResourceListLoading<PRFMember>() => Semantics(
                    label: context.l10n.membersLoading,
                    child: const SizedBox.square(
                      dimension: PRFSizeTokens.iconLg,
                      child: PRFCircularProgressIndicator(),
                    ),
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
              const SizedBox(width: PRFSpacingTokens.lg),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              0,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeaderStat(
                    label: context.l10n.membersTotal,
                    value: _formatNumber(memberCount),
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Floating search bar
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
        boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
      ),
      child: PRFTextField(
        hintText: context.l10n.membersSearchHint,
        controller: _searchController,
        onChanged: (value) {
          _debouncer.run(() {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // Stat helpers
  // ---------------------------------------------------------

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.sm,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: PRFOpacities.muted),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return '$n';
  }

  void _showCreateMemberForm() {
    PRFBottomSheet.show<void>(
      context,
      title: context.l10n.membersAdd,
      child: MemberFormViewHandset(onSaved: _loadData),
    );
  }

  void _goBackToHome() {
    if (context.router.canPop()) {
      context.router.pop();
      return;
    }
    context.router.replace(const LandingRoute());
  }
}
