import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_type_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/school_form/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/school_cubit.dart';
import 'package:leadership/features/home/landing/schools/widgets/school_card.dart';
import 'package:leadership/features/home/landing/schools/widgets/school_detail_modal.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SchoolsPageHandset extends StatefulWidget {
  const SchoolsPageHandset({super.key});

  @override
  State<SchoolsPageHandset> createState() => _SchoolsPageHandsetState();
}

class _SchoolsPageHandsetState extends State<SchoolsPageHandset>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'schools';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: PRFAppBar(
        title: 'Schools & Contacts',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: PRFSpacingTokens.sm),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: _loadData,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSelector(theme),
          Expanded(
            child: _selectedTab == 'schools'
                ? _buildSchoolsContent(theme)
                : _buildContactTypesContent(theme),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab selector
  // ---------------------------------------------------------------------------

  Widget _buildTabSelector(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.lg,
        vertical: PRFSpacingTokens.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              theme,
              'Schools',
              'schools',
              Icons.school_outlined,
            ),
          ),
          const SizedBox(width: PRFSpacingTokens.md),
          Expanded(
            child: _buildTabButton(
              theme,
              'Contact Types',
              'contact_types',
              Icons.category_outlined,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: PRFMotionTokens.slow);
  }

  Widget _buildTabButton(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: PRFMotionTokens.slow,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.85),
                  ],
                )
              : null,
          color: !isSelected ? theme.colorScheme.surfaceContainerHighest : null,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: PRFSpacingTokens.sm),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Schools tab
  // ---------------------------------------------------------------------------

  Widget _buildSchoolsContent(ThemeData theme) {
    return BlocBuilder<SchoolCubit, ResourceState<PRFSchool>>(
      builder: (context, state) {
        return switch (state) {
          ResourceListLoading<PRFSchool>() =>
            const Center(child: PRFCircularProgressIndicator()),
          ResourceListLoaded<PRFSchool>(:final items) when items.isEmpty =>
            PRFEmptyView(
              label: 'No Schools Yet',
              description:
                  'Get started by adding your first school to the system',
              icon: Icons.school_outlined,
              actionLabel: 'Add School',
              onActionPressed: () => _showSchoolForm(context, null),
            ),
          ResourceListLoaded<PRFSchool>(:final items) =>
            _buildSchoolsList(theme, items),
          ResourceMutating<PRFSchool>(:final items) =>
            _buildSchoolsList(theme, items),
          ResourceMutated<PRFSchool>(:final items) =>
            _buildSchoolsList(theme, items),
          ResourceError<PRFSchool>(:final items)
              when items.isNotEmpty =>
            _buildSchoolsList(theme, items),
          ResourceError<PRFSchool>(:final message) => PRFEmptyView(
              label: 'Error Loading Schools',
              description: message,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildSchoolsList(ThemeData theme, List<PRFSchool> schools) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(PRFSpacingTokens.lg),
          child: Column(
            children: [
              PRFTextInput(
                hintText: 'Search schools...',
                controller: _searchController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: PRFSpacingTokens.md),
              SizedBox(
                width: double.infinity,
                child: PRFPrimaryButton(
                  onPressed: () => _showSchoolForm(context, null),
                  title: 'Add New School',
                  disabled: false,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(PRFSpacingTokens.lg),
              child: Column(
                children: [
                  ...List.generate(schools.length, (index) {
                    final school = schools[index];
                    final searchQuery = _searchController.text.toLowerCase();
                    if (searchQuery.isNotEmpty &&
                        !school.name.toLowerCase().contains(searchQuery)) {
                      return const SizedBox.shrink();
                    }
                    return SchoolCard(
                      school: school,
                      index: index,
                      onEdit: () => _showSchoolForm(context, school),
                      onDelete: () =>
                          _showDeleteSchoolDialog(context, school),
                      onTap: () => _showSchoolDetails(context, school),
                    );
                  }),
                  const SizedBox(height: PRFSpacingTokens.lg),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Contact types tab
  // ---------------------------------------------------------------------------

  Widget _buildContactTypesContent(ThemeData theme) {
    return BlocBuilder<ContactTypeCubit, ResourceState<PRFContactType>>(
      builder: (context, state) {
        return switch (state) {
          ResourceListLoading<PRFContactType>() =>
            const Center(child: PRFCircularProgressIndicator()),
          ResourceListLoaded<PRFContactType>(:final items)
              when items.isEmpty =>
            PRFEmptyView(
              label: 'No Contact Types',
              description: 'Create your first contact type to get started',
              icon: Icons.category_outlined,
              actionLabel: 'Add Contact Type',
              onActionPressed: () => _showContactTypeForm(context, null),
            ),
          ResourceListLoaded<PRFContactType>(:final items) =>
            _buildContactTypesList(theme, items),
          ResourceMutating<PRFContactType>(:final items) =>
            _buildContactTypesList(theme, items),
          ResourceMutated<PRFContactType>(:final items) =>
            _buildContactTypesList(theme, items),
          ResourceError<PRFContactType>(:final items)
              when items.isNotEmpty =>
            _buildContactTypesList(theme, items),
          ResourceError<PRFContactType>(:final message) => PRFEmptyView(
              label: 'Error Loading Contact Types',
              description: message,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onActionPressed: _loadData,
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildContactTypesList(
    ThemeData theme,
    List<PRFContactType> contactTypes,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(PRFSpacingTokens.lg),
          child: SizedBox(
            width: double.infinity,
            child: PRFPrimaryButton(
              onPressed: () => _showContactTypeForm(context, null),
              title: 'Add Contact Type',
              disabled: false,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(PRFSpacingTokens.lg),
              child: Column(
                children: [
                  ...List.generate(contactTypes.length, (index) {
                    final contactType = contactTypes[index];
                    return _buildContactTypeCard(theme, contactType, index);
                  }),
                  const SizedBox(height: PRFSpacingTokens.lg),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTypeCard(
    ThemeData theme,
    PRFContactType contactType,
    int index,
  ) {
    return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
          child: InkWell(
            onTap: () => _showContactTypeForm(context, contactType),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(PRFSpacingTokens.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary
                                .withValues(alpha: 0.15),
                            theme.colorScheme.secondary
                                .withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(PRFRadiusTokens.md),
                      ),
                      child: Icon(
                        Icons.label_outline,
                        color: theme.colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contactType.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Created ${Misc.formatDate(
                              contactType.createdAt,
                              'Africa/Nairobi',
                            )}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            _showContactTypeForm(context, contactType),
                        borderRadius:
                            BorderRadius.circular(PRFRadiusTokens.md),
                        child: Container(
                          padding:
                              const EdgeInsets.all(PRFSpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    // Delete Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showDeleteContactTypeDialog(
                          context,
                          contactType,
                        ),
                        borderRadius:
                            BorderRadius.circular(PRFRadiusTokens.md),
                        child: Container(
                          padding:
                              const EdgeInsets.all(PRFSpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: index * 80),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: index * 80),
          duration: 500.ms,
        );
  }

  // ---------------------------------------------------------------------------
  // Modal helpers
  // ---------------------------------------------------------------------------

  void _showSchoolForm(BuildContext context, PRFSchool? school) {
    final theme = Theme.of(context);

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            school == null ? 'Add School' : 'Edit School',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(modalContext),
          ),
          child: SchoolFormViewHandset(
            school: school,
            onSaved: _loadData,
          ),
        ),
      ],
    );
  }

  void _showDeleteSchoolDialog(BuildContext context, PRFSchool school) {
    final theme = Theme.of(context);

    PRFConfirmationDialog.show(
      context,
      title: 'Delete School',
      isDestructive: true,
      confirmLabel: 'Delete',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this school?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  school.institutionType.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (school.address.isNotEmpty) ...[
                  const SizedBox(height: PRFSpacingTokens.sm),
                  Text(
                    school.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onConfirm: () {
        context.read<SchoolCubit>().deleteSchool(ulid: school.ulid);
      },
    );
  }

  void _showSchoolDetails(BuildContext context, PRFSchool school) {
    final contactTypesState = context.read<ContactTypeCubit>().state;
    final contactTypes = switch (contactTypesState) {
      ResourceListLoaded<PRFContactType>(:final items) => items,
      ResourceMutated<PRFContactType>(:final items) => items,
      ResourceMutating<PRFContactType>(:final items) => items,
      ResourceError<PRFContactType>(:final items) => items,
      _ => <PRFContactType>[],
    };

    showSchoolDetailModal(
      context,
      school,
      contactTypes: contactTypes,
      onDataChanged: _loadData,
    );
  }

  void _showContactTypeForm(
    BuildContext context,
    PRFContactType? contactType,
  ) {
    final theme = Theme.of(context);

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            contactType == null ? 'Add Contact Type' : 'Edit Contact Type',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(modalContext),
          ),
          child: ContactTypeFormViewHandset(
            contactType: contactType,
            onSaved: _loadData,
          ),
        ),
      ],
    );
  }

  void _showDeleteContactTypeDialog(
    BuildContext context,
    PRFContactType contactType,
  ) {
    final theme = Theme.of(context);

    PRFConfirmationDialog.show(
      context,
      title: 'Delete Contact Type',
      isDestructive: true,
      confirmLabel: 'Delete',
      
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this contact type?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactType.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  'Created ${Misc.formatDate(
                    contactType.createdAt,
                    'Africa/Nairobi',
                  )}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onConfirm: () {
        context
            .read<ContactTypeCubit>()
            .deleteContactType(ulid: contactType.ulid);
      },
    );
  }
}
