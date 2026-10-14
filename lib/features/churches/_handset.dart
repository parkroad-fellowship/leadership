import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/churches/actions/church_form/_handset.dart';
import 'package:leadership/features/churches/cubit/church_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class ChurchesPageHandset extends StatefulWidget {
  const ChurchesPageHandset({super.key});

  @override
  State<ChurchesPageHandset> createState() => _ChurchesPageHandsetState();
}

class _ChurchesPageHandsetState extends State<ChurchesPageHandset>
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
    context.read<ChurchResourceCubit>().loadAll();
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
      body: BlocBuilder<ChurchResourceCubit, ResourceState<PRFChurch>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFChurch>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFChurch>(:final items) when items.isEmpty =>
              PRFEmptyView(
                label: l10n.churchesEmptyTitle,
                description: l10n.churchesEmptyMessage,
                icon: Icons.church_outlined,
                navBarTitle: l10n.churchesTitle,
                onBackPressed: _goBackToHome,
                actionLabel: l10n.churchesAdd,
                onActionPressed: () => _showForm(context, null),
              ),
            ResourceListLoaded<PRFChurch>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFChurch>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFChurch>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFChurch>() => PRFLeadershipErrorScreen(
              navBarTitle: l10n.churchesTitle,
              title: l10n.churchesLoadError,
              onBack: _goBackToHome,
              onRetry: _loadData,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<PRFChurch> items) {
    final filtered = _searchQuery.isEmpty
        ? items
        : items
              .where((item) => item.name.toLowerCase().contains(_searchQuery))
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(theme, items.length)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PRFSpacingTokens.lg,
              PRFSpacingTokens.md,
              PRFSpacingTokens.lg,
              PRFSpacingTokens.sm,
            ),
            sliver: SliverToBoxAdapter(child: _buildSearchBar(theme)),
          ),
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
                  final item = filtered[index];
                  return PRFListItemCard(
                    title: item.name,
                    icon: Icons.church_outlined,
                    isActive: item.isActive == PRFActiveStatus.active,
                    activeLabel: context.l10n.commonActive,
                    inactiveLabel: context.l10n.commonInactive,
                    deleteLabel: context.l10n.delete,
                    onTap: () => _showForm(context, item),
                    onDelete: () => _confirmDelete(context, item),
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

  Widget _buildHeader(ThemeData theme, int totalCount) {
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: context.l10n.churchesTitle,
            onBack: _goBackToHome,
            actions: [
              PRFNavBarAction(
                label: context.l10n.commonNew,
                icon: Icons.add,
                tooltip: context.l10n.churchesAddTooltip,
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
                    label: context.l10n.churchesTotal,
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
        hintText: context.l10n.churchesSearchHint,
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

  void _showForm(BuildContext context, PRFChurch? church) {
    PRFBottomSheet.show<void>(
      context,
      title: church == null
          ? context.l10n.churchesAdd
          : context.l10n.churchesEdit,
      child: ChurchFormViewHandset(church: church, onSaved: _loadData),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PRFChurch church) async {
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.churchesDeleteTitle,
      message: l10n.lookupDeleteMessage(church.name),
      confirmLabel: l10n.churchesDeleteConfirm,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<ChurchResourceCubit>().deleteChurch(ulid: church.ulid);
    }
  }
}
