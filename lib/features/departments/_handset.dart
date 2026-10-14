import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/departments/actions/department_form/_handset.dart';
import 'package:leadership/features/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class DepartmentsPageHandset extends StatefulWidget {
  const DepartmentsPageHandset({super.key});

  @override
  State<DepartmentsPageHandset> createState() => _DepartmentsPageHandsetState();
}

class _DepartmentsPageHandsetState extends State<DepartmentsPageHandset>
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
    context.read<DepartmentResourceCubit>().loadAll();
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
      body: BlocBuilder<DepartmentResourceCubit, ResourceState<PRFDepartment>>(
        builder: (context, state) {
          return switch (state) {
            ResourceListLoading<PRFDepartment>() => const Center(
              child: PRFCircularProgressIndicator(),
            ),
            ResourceListLoaded<PRFDepartment>(:final items)
                when items.isEmpty =>
              PRFEmptyView(
                label: l10n.departmentsEmptyTitle,
                description: l10n.departmentsEmptyMessage,
                icon: Icons.group_work_outlined,
                navBarTitle: l10n.departmentsTitle,
                onBackPressed: _goBackToHome,
                actionLabel: l10n.departmentsAdd,
                onActionPressed: () => _showForm(context, null),
              ),
            ResourceListLoaded<PRFDepartment>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceMutating<PRFDepartment>(:final items) => _buildBody(
              theme,
              items,
            ),
            ResourceError<PRFDepartment>(:final items) when items.isNotEmpty =>
              _buildBody(theme, items),
            ResourceError<PRFDepartment>() => PRFLeadershipErrorScreen(
              navBarTitle: l10n.departmentsTitle,
              title: l10n.departmentsLoadError,
              onBack: _goBackToHome,
              onRetry: _loadData,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<PRFDepartment> items) {
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
                    icon: Icons.group_work_outlined,
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
            title: context.l10n.departmentsTitle,
            onBack: _goBackToHome,
            actions: [
              PRFNavBarAction(
                label: context.l10n.commonNew,
                icon: Icons.add,
                tooltip: context.l10n.departmentsAddTooltip,
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
                    label: context.l10n.departmentsTotal,
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
        hintText: context.l10n.departmentsSearchHint,
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

  void _showForm(BuildContext context, PRFDepartment? department) {
    PRFBottomSheet.show<void>(
      context,
      title: department == null
          ? context.l10n.departmentsAdd
          : context.l10n.departmentsEdit,
      child: DepartmentFormViewHandset(
        department: department,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PRFDepartment department,
  ) async {
    final l10n = context.l10n;
    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.departmentsDeleteTitle,
      message: l10n.lookupDeleteMessage(department.name),
      confirmLabel: l10n.departmentsDeleteConfirm,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if ((confirmed ?? false) && mounted) {
      await context.read<DepartmentResourceCubit>().deleteDepartment(
        ulid: department.ulid,
      );
    }
  }
}
