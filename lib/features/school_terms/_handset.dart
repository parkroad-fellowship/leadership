import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/features/school_terms/actions/school_term_form/_handset.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
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
    final l10n = context.l10n;

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
                label: l10n.schoolTermsEmptyTitle,
                description: l10n.schoolTermsEmptyMessage,
                icon: Icons.calendar_today_outlined,
                navBarTitle: l10n.schoolTermsTitle,
                onBackPressed: _goBackToHome,
                actionLabel: l10n.schoolTermsAdd,
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
            ResourceError<PRFSchoolTerm>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFSchoolTerm>() => PRFLeadershipErrorScreen(
              navBarTitle: l10n.schoolTermsTitle,
              title: l10n.schoolTermsLoadError,
              onBack: _goBackToHome,
              onRetry: _loadData,
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
              .where((t) => t.name.toLowerCase().contains(_searchQuery))
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          // Navy branded header
          SliverToBoxAdapter(child: _buildHeader(theme, terms.length)),
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
          // School term list
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
                  final term = filtered[index];
                  return PRFListItemCard(
                    title: term.name,
                    subtitle: '${term.year}',
                    icon: Icons.calendar_today_outlined,
                    isActive: term.isActive == PRFActiveStatus.active,
                    activeLabel: context.l10n.commonActive,
                    inactiveLabel: context.l10n.commonInactive,
                    deleteLabel: context.l10n.delete,
                    onTap: () => _showForm(context, term),
                    onDelete: () => _confirmDelete(context, term),
                    animationIndex: index,
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

  Widget _buildHeader(ThemeData theme, int totalCount) {
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: context.l10n.schoolTermsTitle,
            onBack: _goBackToHome,
            actions: [
              PRFNavBarAction(
                label: context.l10n.commonNew,
                icon: Icons.add,
                tooltip: context.l10n.schoolTermsAddTooltip,
                onPressed: () => _showForm(context, null),
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
                    label: context.l10n.schoolTermsTotal,
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
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
        boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
      ),
      child: PRFTextField(
        hintText: context.l10n.schoolTermsSearchHint,
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
      title: term == null
          ? context.l10n.schoolTermsAdd
          : context.l10n.schoolTermsEdit,
      child: SchoolTermFormViewHandset(term: term, onSaved: _loadData),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PRFSchoolTerm term) async {
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.schoolTermsDeleteTitle,
      message: l10n.lookupDeleteMessage('${term.name} (${term.year})'),
      confirmLabel: l10n.schoolTermsDeleteConfirm,
      cancelLabel: l10n.cancel,
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
