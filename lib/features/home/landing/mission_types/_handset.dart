import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/mission_types/actions/mission_type_form/_handset.dart';
import 'package:leadership/features/home/landing/mission_types/widgets/mission_type_card.dart';
import 'package:leadership/features/home/landing/missions/cubit/mission_type_resource_cubit.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/shared_widgets/_index.dart';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<MissionTypeResourceCubit, ResourceState<PRFMissionType>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFMissionType>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFMissionType>(:final items)
                when items.isEmpty =>
              PRFEmptyView(
                label: 'No Mission Types Yet',
                description:
                    'Get started by adding your first mission type to the system',
                icon: Icons.category_outlined,
                navBarTitle: 'Mission Types',
                onBackPressed: _goBackToHome,
                actionLabel: 'Add Mission Type',
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
            ResourceMutated<PRFMissionType>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFMissionType>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFMissionType>(:final message) => PRFEmptyView(
              label: 'Error Loading Mission Types',
              description: message,
              icon: Icons.error_outline,
              navBarTitle: 'Mission Types',
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

  Widget _buildBody(ThemeData theme, List<PRFMissionType> items) {
    final filtered = _searchQuery.isEmpty
        ? items
        : items
              .where(
                (item) => item.name.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(theme, items.length),
          ),
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
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                  child: Text(
                    'No mission types match your search',
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
                    final item = filtered[index];
                    return MissionTypeCard(
                      missionType: item,
                      index: index,
                      onTap: () => _showForm(context, item),
                      onDelete: () => _confirmDelete(context, item),
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

  Widget _buildHeader(ThemeData theme, int totalCount) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PRFBrandedNavBar(
            title: 'Mission Types',
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
        hintText: 'Search mission types...',
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

  void _showForm(BuildContext context, PRFMissionType? missionType) {
    PRFBottomSheet.show<void>(
      context,
      title: missionType == null ? 'Add Mission Type' : 'Edit Mission Type',
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
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: 'Delete Mission Type',
      message:
          'Are you sure you want to delete "${missionType.name}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<MissionTypeResourceCubit>().deleteMissionType(
        ulid: missionType.ulid,
      );
    }
  }
}
