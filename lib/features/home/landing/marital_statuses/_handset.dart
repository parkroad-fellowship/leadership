import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/marital_statuses/actions/marital_status_form/_handset.dart';
import 'package:leadership/features/home/landing/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/features/home/landing/marital_statuses/widgets/marital_status_card.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class MaritalStatusesPageHandset extends StatefulWidget {
  const MaritalStatusesPageHandset({super.key});

  @override
  State<MaritalStatusesPageHandset> createState() =>
      _MaritalStatusesPageHandsetState();
}

class _MaritalStatusesPageHandsetState extends State<MaritalStatusesPageHandset>
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
    context.read<MaritalStatusResourceCubit>().loadAll();
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
      body:
          BlocBuilder<
            MaritalStatusResourceCubit,
            ResourceState<PRFMaritalStatus>
          >(
            builder: (context, state) {
              return switch (state) {
                ResourceListLoading<PRFMaritalStatus>() => const Center(
                  child: PRFCircularProgressIndicator(),
                ),
                ResourceListLoaded<PRFMaritalStatus>(:final items)
                    when items.isEmpty =>
                  PRFEmptyView(
                    label: 'No Marital Statuses Yet',
                    description:
                        'Get started by adding your first marital status to the system',
                    icon: Icons.favorite_outlined,
                    navBarTitle: 'Marital Statuses',
                    onBackPressed: _goBackToHome,
                    actionLabel: 'Add Marital Status',
                    onActionPressed: () => _showForm(context, null),
                  ),
                ResourceListLoaded<PRFMaritalStatus>(:final items) =>
                  _buildBody(
                    theme,
                    items,
                  ),
                ResourceMutating<PRFMaritalStatus>(:final items) => _buildBody(
                  theme,
                  items,
                ),
                ResourceMutated<PRFMaritalStatus>(:final items) => _buildBody(
                  theme,
                  items,
                ),
                ResourceError<PRFMaritalStatus>(:final items)
                    when items.isNotEmpty =>
                  _buildBody(theme, items),
                ResourceError<PRFMaritalStatus>(:final message) => PRFEmptyView(
                  label: 'Error Loading Marital Statuses',
                  description: message,
                  icon: Icons.error_outline,
                  navBarTitle: 'Marital Statuses',
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

  Widget _buildBody(ThemeData theme, List<PRFMaritalStatus> items) {
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
                    'No marital statuses match your search',
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
                    return MaritalStatusCard(
                      maritalStatus: item,
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
            title: 'Marital Statuses',
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
        hintText: 'Search marital statuses...',
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

  void _showForm(BuildContext context, PRFMaritalStatus? maritalStatus) {
    PRFBottomSheet.show<void>(
      context,
      title: maritalStatus == null
          ? 'Add Marital Status'
          : 'Edit Marital Status',
      child: MaritalStatusFormViewHandset(
        maritalStatus: maritalStatus,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PRFMaritalStatus maritalStatus,
  ) async {
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: 'Delete Marital Status',
      message:
          'Are you sure you want to delete "${maritalStatus.name}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<MaritalStatusResourceCubit>().deleteMaritalStatus(
        ulid: maritalStatus.ulid,
      );
    }
  }
}
