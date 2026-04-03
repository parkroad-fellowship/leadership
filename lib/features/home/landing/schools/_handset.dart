import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/school_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/features/home/landing/schools/widgets/school_card.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class SchoolsPageHandset extends StatefulWidget {
  const SchoolsPageHandset({super.key});

  @override
  State<SchoolsPageHandset> createState() => _SchoolsPageHandsetState();
}

class _SchoolsPageHandsetState extends State<SchoolsPageHandset>
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
    context.read<SchoolCubit>().loadAll();
    context.read<ContactTypeCubit>().loadAll();
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
      body: BlocBuilder<SchoolCubit, ResourceState<PRFSchool>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFSchool>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFSchool>(:final items) when items.isEmpty =>
              PRFEmptyView(
                label: 'No Schools Yet',
                description:
                    'Get started by adding your first school to the system',
                icon: Icons.school_outlined,
                navBarTitle: 'Schools',
                onBackPressed: _goBackToHome,
                actionLabel: 'Add School',
                onActionPressed: () => _showSchoolForm(context, null),
              ),
            ResourceListLoaded<PRFSchool>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFSchool>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutated<PRFSchool>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFSchool>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFSchool>(:final message) => PRFEmptyView(
              label: 'Error Loading Schools',
              description: message,
              icon: Icons.error_outline,
              navBarTitle: 'Schools',
              onBackPressed: _goBackToHome,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<PRFSchool> schools) {
    final totalStudents = schools.fold<int>(
      0,
      (sum, s) => sum + s.totalStudents,
    );
    final totalContacts = schools.fold<int>(
      0,
      (sum, s) => sum + s.contacts.length,
    );

    final filtered = _searchQuery.isEmpty
        ? schools
        : schools
              .where(
                (s) => s.name.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Navy branded header
          SliverToBoxAdapter(
            child: _buildHeader(
              theme,
              schools.length,
              totalStudents,
              totalContacts,
            ),
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
          // School list
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                  child: Text(
                    'No schools match your search',
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
                    final school = filtered[index];
                    return SchoolCard(
                      school: school,
                      index: index,
                      onTap: () => context.router.push(
                        SchoolDetailsRoute(schoolUlid: school.ulid),
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

  Widget _buildHeader(
    ThemeData theme,
    int schoolCount,
    int totalStudents,
    int totalContacts,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: 'Schools',
            onBack: _goBackToHome,
            actions: [
              PRFHeaderActionButton(
                label: 'New',
                icon: Icons.add,
                onTap: () => _showSchoolForm(context, null),
              ),
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
                    label: 'Schools',
                    value: '$schoolCount',
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.sm),
                Expanded(
                  child: _buildHeaderStat(
                    label: 'Students',
                    value: _formatNumber(totalStudents),
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.sm),
                Expanded(
                  child: _buildHeaderStat(
                    label: 'Contacts',
                    value: '$totalContacts',
                    color: theme.colorScheme.errorContainer,
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
        hintText: 'Search schools...',
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

  void _goBackToHome() {
    if (context.router.canPop()) {
      context.router.pop();
      return;
    }
    context.router.replace(const LandingRoute());
  }

  // ---------------------------------------------------------
  // Modal helpers
  // ---------------------------------------------------------

  void _showSchoolForm(BuildContext context, PRFSchool? school) {
    PRFBottomSheet.show<void>(
      context,
      title: school == null ? 'Add School' : 'Edit School',
      child: SchoolFormViewHandset(
        school: school,
        onSaved: _loadData,
      ),
    );
  }
}
