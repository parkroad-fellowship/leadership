import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/home/landing/school_terms/actions/school_term_form/_handset.dart';
import 'package:leadership/features/home/landing/school_terms/widgets/school_term_card.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class SchoolTermsPageHandset extends StatefulWidget {
  const SchoolTermsPageHandset({super.key});

  @override
  State<SchoolTermsPageHandset> createState() => _SchoolTermsPageHandsetState();
}

class _SchoolTermsPageHandsetState extends State<SchoolTermsPageHandset>
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
    context.read<SchoolTermResourceCubit>().loadAll();
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
      body: BlocBuilder<SchoolTermResourceCubit, ResourceState<PRFSchoolTerm>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFSchoolTerm>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFSchoolTerm>(:final items)
                when items.isEmpty =>
              PRFEmptyView(
                label: 'No School Terms Yet',
                description:
                    'Get started by adding your first school term to the system',
                icon: Icons.calendar_today_outlined,
                navBarTitle: 'School Terms',
                onBackPressed: _goBackToHome,
                actionLabel: 'Add School Term',
                onActionPressed: () => _showForm(context, null),
              ),
            ResourceListLoaded<PRFSchoolTerm>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFSchoolTerm>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutated<PRFSchoolTerm>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFSchoolTerm>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFSchoolTerm>(:final message) => PRFEmptyView(
              label: 'Error Loading School Terms',
              description: message,
              icon: Icons.error_outline,
              navBarTitle: 'School Terms',
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

  Widget _buildBody(ThemeData theme, List<PRFSchoolTerm> terms) {
    final filtered = _searchQuery.isEmpty
        ? terms
        : terms
              .where(
                (t) => t.name.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Navy branded header
          SliverToBoxAdapter(
            child: _buildHeader(theme, terms.length),
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
          // School term list
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                  child: Text(
                    'No school terms match your search',
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
                    final term = filtered[index];
                    return SchoolTermCard(
                      term: term,
                      index: index,
                      onTap: () => _showForm(context, term),
                      onDelete: () => _confirmDelete(context, term),
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

  Widget _buildHeader(ThemeData theme, int totalCount) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: 'School Terms',
            onBack: _goBackToHome,
            actions: [
              PRFHeaderActionButton(
                label: 'New',
                icon: Icons.add,
                onTap: () => _showForm(context, null),
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
                    label: 'Total',
                    value: '$totalCount',
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
        hintText: 'Search school terms...',
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

  void _showForm(BuildContext context, PRFSchoolTerm? term) {
    PRFBottomSheet.show<void>(
      context,
      title: term == null ? 'Add School Term' : 'Edit School Term',
      child: SchoolTermFormViewHandset(
        term: term,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PRFSchoolTerm term,
  ) async {
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: 'Delete School Term',
      message:
          'Are you sure you want to delete "${term.name}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      // ignore: use_build_context_synchronously
      await context.read<SchoolTermResourceCubit>().deleteSchoolTerm(
        ulid: term.ulid,
      );
    }
  }
}
