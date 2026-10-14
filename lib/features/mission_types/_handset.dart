import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/mission_types/actions/mission_type_form/_handset.dart';
import 'package:leadership/features/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class MissionTypesPageHandset extends StatefulWidget {
  const MissionTypesPageHandset({super.key});

  @override
  State<MissionTypesPageHandset> createState() =>
      _MissionTypesPageHandsetState();
}

class _MissionTypesPageHandsetState extends State<MissionTypesPageHandset>
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
    context.read<MissionTypeResourceCubit>().loadAll();
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
      body:
          BlocBuilder<MissionTypeResourceCubit, ResourceState<PRFMissionType>>(
            builder: (context, state) {
              return switch (state) {
                ResourceListLoading<PRFMissionType>() => const Center(
                  child: PRFCircularProgressIndicator(),
                ),
                ResourceListLoaded<PRFMissionType>(:final items)
                    when items.isEmpty =>
                  PRFEmptyView(
                    label: l10n.missionTypesEmptyTitle,
                    description: l10n.missionTypesEmptyMessage,
                    icon: Icons.category_outlined,
                    navBarTitle: l10n.missionTypesTitle,
                    onBackPressed: _goBackToHome,
                    actionLabel: l10n.missionTypesAdd,
                    onActionPressed: () => _showForm(context, null),
                  ),
                ResourceListLoaded<PRFMissionType>(:final items) => _buildBody(
                  theme,
                  items,
                ),
                ResourceMutating<PRFMissionType>(:final items) => _buildBody(
                  theme,
                  items,
                ),
                ResourceError<PRFMissionType>(:final items)
                    when items.isNotEmpty =>
                  _buildBody(theme, items),
                ResourceError<PRFMissionType>() => PRFLeadershipErrorScreen(
                  navBarTitle: l10n.missionTypesTitle,
                  title: l10n.missionTypesLoadError,
                  onBack: _goBackToHome,
                  onRetry: _loadData,
                ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
    );
  }

  Widget _buildBody(ThemeData theme, List<PRFMissionType> items) {
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
                    icon: Icons.category_outlined,
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
            title: context.l10n.missionTypesTitle,
            onBack: _goBackToHome,
            actions: [
              PRFNavBarAction(
                label: context.l10n.commonNew,
                icon: Icons.add,
                tooltip: context.l10n.missionTypesAddTooltip,
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
                    label: context.l10n.missionTypesTotal,
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
        hintText: context.l10n.missionTypesSearchHint,
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

  void _showForm(BuildContext context, PRFMissionType? missionType) {
    PRFBottomSheet.show<void>(
      context,
      title: missionType == null
          ? context.l10n.missionTypesAdd
          : context.l10n.missionTypesEdit,
      child: MissionTypeFormViewHandset(
        missionType: missionType,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PRFMissionType missionType,
  ) async {
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.missionTypesDeleteTitle,
      message: l10n.lookupDeleteMessage(missionType.name),
      confirmLabel: l10n.missionTypesDeleteConfirm,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<MissionTypeResourceCubit>().deleteMissionType(
        ulid: missionType.ulid,
      );
    }
  }
}
