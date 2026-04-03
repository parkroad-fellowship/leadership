import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/gifts/actions/gift_form/_handset.dart';
import 'package:leadership/features/home/landing/gifts/cubit/gift_resource_cubit.dart';
import 'package:leadership/features/home/landing/gifts/widgets/gift_card.dart';
import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class GiftsPageHandset extends StatefulWidget {
  const GiftsPageHandset({super.key});

  @override
  State<GiftsPageHandset> createState() => _GiftsPageHandsetState();
}

class _GiftsPageHandsetState extends State<GiftsPageHandset>
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
    context.read<GiftResourceCubit>().loadAll();
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
      body: BlocBuilder<GiftResourceCubit, ResourceState<PRFGift>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFGift>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFGift>(:final items) when items.isEmpty =>
              PRFEmptyView(
                label: 'No Gifts Yet',
                description:
                    'Get started by adding your first gift to the system',
                icon: Icons.card_giftcard_outlined,
                navBarTitle: 'Gifts',
                onBackPressed: _goBackToHome,
                actionLabel: 'Add Gift',
                onActionPressed: () => _showForm(context, null),
              ),
            ResourceListLoaded<PRFGift>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFGift>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutated<PRFGift>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFGift>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFGift>(:final message) => PRFEmptyView(
              label: 'Error Loading Gifts',
              description: message,
              icon: Icons.error_outline,
              navBarTitle: 'Gifts',
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

  Widget _buildBody(ThemeData theme, List<PRFGift> items) {
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
                    'No gifts match your search',
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
                    return GiftCard(
                      gift: item,
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
            title: 'Gifts',
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
        hintText: 'Search gifts...',
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

  void _showForm(BuildContext context, PRFGift? gift) {
    PRFBottomSheet.show<void>(
      context,
      title: gift == null ? 'Add Gift' : 'Edit Gift',
      child: GiftFormViewHandset(
        gift: gift,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PRFGift gift,
  ) async {
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: 'Delete Gift',
      message:
          'Are you sure you want to delete "${gift.name}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<GiftResourceCubit>().deleteGift(
        ulid: gift.ulid,
      );
    }
  }
}
