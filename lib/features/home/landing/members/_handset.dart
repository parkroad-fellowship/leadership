import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_permissions.dart';
import 'package:leadership/features/home/landing/members/actions/member_form/_handset.dart';
import 'package:leadership/features/home/landing/members/cubit/member_resource_cubit.dart';
import 'package:leadership/features/home/landing/members/widgets/member_card.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_widgets/header_action_button.dart';
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
                navBarTitle: 'Members',
                onBackPressed: _goBackToHome,
                label: 'No Members Yet',
                description:
                    'There are no members registered in the system yet',
                icon: Icons.people_outline,
              ),
            ResourceListLoaded<PRFMember>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFMember>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutated<PRFMember>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFMember>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFMember>(:final message) => PRFEmptyView(
              label: 'Error Loading Members',
              description: message,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
              navBarTitle: 'Members',
              onBackPressed: _goBackToHome,
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
              .where(
                (m) => m.fullName.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Navy branded header
          SliverToBoxAdapter(
            child: _buildHeader(theme, members.length),
          ),
          // Floating search bar
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildSearchBar(theme),
            ),
          ),
          // Member list
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                  child: Text(
                    'No members match your search',
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = filtered[index];
                    return MemberCard(
                      member: member,
                      index: index,
                      onTap: () => context.router.push(
                        MemberDetailsRoute(memberUlid: member.ulid),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
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
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: 'Members',
            onBack: _goBackToHome,
            actions: [
              if (Misc.userCan(PRFPermissions.createMember))
                PRFHeaderActionButton(
                  label: '+ New',
                  onTap: _showCreateMemberForm,
                ),
              if (Misc.userCan(PRFPermissions.createMember))
                const SizedBox(width: PRFSpacingTokens.sm),
              BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
                builder: (context, state) => switch (state) {
                  ResourceListLoading<PRFMember>() => const SizedBox.square(
                    dimension: 24,
                    child: PRFCircularProgressIndicator(),
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
                    label: 'Total Members',
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
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PRFTextInput(
        hintText: 'Search members...',
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
        color: color.withValues(alpha: 0.2),
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
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
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
      title: 'Add Member',
      child: MemberFormViewHandset(
        onSaved: _loadData,
      ),
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
