import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_types/add_contact_type/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_types/delete_contact_type/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/contact_types/edit_contact_type/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/contacts/add_contact/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/contacts/edit_contact/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/schools/add_school/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/schools/delete_school/_handset.dart';
import 'package:leadership/features/home/landing/schools/actions/schools/edit_school/_handset.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/create_contact_type_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/delete_contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/get_contact_types_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/get_contacts_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/get_schools_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/update_contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/update_contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:map_launcher/map_launcher.dart';
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
    context.read<GetSchoolsCubit>().getSchools();
    context.read<GetContactTypesCubit>().getContactTypes();
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

  Widget _buildSchoolsContent(ThemeData theme) {
    return BlocConsumer<GetSchoolsCubit, GetSchoolsState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: PRFCircularProgressIndicator()),
          loaded: (schools) {
            if (schools.isEmpty) {
              return PRFEmptyView(
                label: 'No Schools Yet',
                description:
                    'Get started by adding your first school to the system',
                icon: Icons.school_outlined,
                actionLabel: 'Add School',
                onActionPressed: () => _showSchoolForm(context, null),
              );
            }
            return _buildSchoolsList(theme, schools);
          },
          error: (message) => PRFEmptyView(
            label: 'Error Loading Schools',
            description: message,
            icon: Icons.error_outline,
            actionLabel: 'Retry',
            onActionPressed: _loadData,
          ),
          orElse: () => const SizedBox.shrink(),
        );
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
                onChanged: (value) {
                  setState(() {});
                },
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
                    return _buildSchoolCard(theme, school, index);
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

  Widget _buildSchoolCard(ThemeData theme, PRFSchool school, int index) {
    return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
          child: InkWell(
            onTap: () => _showSchoolDetails(context, school),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.md),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                          ),
                          child: Icon(
                            Icons.school,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: PRFSpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                school.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: PRFSpacingTokens.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PRFSpacingTokens.sm,
                                  vertical: PRFSpacingTokens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  school.institutionType.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showSchoolForm(context, school),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                PRFSpacingTokens.sm,
                              ),
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
                            onTap: () =>
                                _showDeleteSchoolDialog(context, school),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.md,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                PRFSpacingTokens.sm,
                              ),
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
                    const SizedBox(height: 14),
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      height: 0,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.sm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${school.totalStudents} Students',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: PRFSpacingTokens.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.sm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.contacts_outlined,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${school.contacts.length} Contacts',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            school.address,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildContactTypesContent(ThemeData theme) {
    return BlocBuilder<GetContactTypesCubit, GetContactTypesState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: PRFCircularProgressIndicator()),
          loaded: (contactTypes) {
            if (contactTypes.isEmpty) {
              return PRFEmptyView(
                label: 'No Contact Types',
                description: 'Create your first contact type to get started',
                icon: Icons.category_outlined,
                actionLabel: 'Add Contact Type',
                onActionPressed: () => _showAddContactTypeModal(context),
              );
            }
            return Column(
              children: [
                // Add button header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: PRFPrimaryButton(
                      onPressed: () => _showAddContactTypeModal(context),
                      title: 'Add Contact Type',
                      disabled: false,
                    ),
                  ),
                ),
                // Contact types list
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                      child: Column(
                        children: [
                          ...List.generate(contactTypes.length, (index) {
                            final contactType = contactTypes[index];
                            return _buildContactTypeCard(
                              theme,
                              contactType,
                              index,
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
          },
          error: (message) => PRFEmptyView(
            label: 'Error Loading Contact Types',
            description: message,
            icon: Icons.error_outline,
            actionLabel: 'Retry',
            onActionPressed: _loadData,
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
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
            onTap: () => _showEditContactTypeModal(context, contactType),
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
                            theme.colorScheme.secondary.withValues(alpha: 0.15),
                            theme.colorScheme.secondary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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
                            _showEditContactTypeModal(context, contactType),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        child: Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.sm),
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
                        onTap: () =>
                            _showDeleteContactTypeDialog(context, contactType),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                        child: Container(
                          padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.5,
                            ),
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

  void _showAddContactTypeModal(BuildContext context) {
    final theme = Theme.of(context);
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            'Add Contact Type',
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
          child: BlocProvider.value(
            value: context.read<CreateContactTypeCubit>(),
            child: AddContactTypeViewHandset(
              onContactTypeCreated: _loadData,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditContactTypeModal(
    BuildContext context,
    PRFContactType contactType,
  ) {
    final theme = Theme.of(context);
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            'Edit Contact Type',
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
          child: BlocProvider.value(
            value: context.read<UpdateContactTypeCubit>(),
            child: EditContactTypeViewHandset(
              contactType: contactType,
              onContactTypeUpdated: _loadData,
            ),
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

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.lg),
              Expanded(
                child: Text(
                  'Delete Contact Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Call the original delete dialog to handle the deletion
                showDialog<void>(
                  context: context,
                  builder: (deleteContext) => DeleteContactTypeDialog(
                    contactType: contactType,
                    onContactTypeDeleted: _loadData,
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.sm,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSchoolDialog(BuildContext context, PRFSchool school) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.lg),
              Expanded(
                child: Text(
                  'Delete School',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    if (school.address.isNotEmpty) ...[
                      const SizedBox(height: PRFSpacingTokens.sm),
                      Text(
                        school.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Call the original delete dialog to handle the deletion
                showDialog<void>(
                  context: context,
                  builder: (deleteContext) => DeleteSchoolDialog(
                    school: school,
                    onSchoolDeleted: _loadData,
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                  vertical: PRFSpacingTokens.sm,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSchoolDetails(BuildContext context, PRFSchool school) {
    final theme = Theme.of(context);
    _refreshContacts(school.ulid);
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            school.name,
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
            onPressed: () => Navigator.pop(context),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PRFSpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection(
                  theme,
                  'School Information',
                  Icons.school,
                  [
                    _buildDetailRow(theme, 'Name', school.name),
                    _buildDetailRow(
                      theme,
                      'Institution Type',
                      school.institutionType.name,
                    ),
                    _buildDetailRow(
                      theme,
                      'Total Students',
                      school.totalStudents.toString(),
                    ),
                    _buildDetailRow(theme, 'Address', school.address),
                    _buildDetailRow(
                      theme,
                      'Description',
                      school.description != 'N/A'
                          ? school.description
                          : 'No description',
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                _buildDetailSection(
                  theme,
                  'Location',
                  Icons.map,
                  [
                    LocationDisplay(
                      latitude: school.latitude,
                      longitude: school.longitude,
                      schoolName: school.name,
                      onOpenInMaps: () => _openSchoolInMaps(school),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                _buildContactsSection(context, theme, school),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openSchoolInMaps(PRFSchool school) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      _showSnackBar('No map apps available');
      return;
    }

    // If only one map is available, open it directly
    if (availableMaps.length == 1) {
      await availableMaps.first.showMarker(
        coords: Coords(school.latitude, school.longitude),
        title: school.name,
      );
      return;
    }

    // Show bottom sheet to select map app
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: availableMaps
                .map(
                  (map) => ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      map.showMarker(
                        coords: Coords(school.latitude, school.longitude),
                        title: school.name,
                      );
                    },
                    title: Text(map.mapName),
                    leading: const Icon(Icons.map),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _showAddContactModal(BuildContext context, PRFSchool school) {
    final theme = Theme.of(context);
    final contactTypesState = context.read<GetContactTypesCubit>().state;
    final contactTypes = contactTypesState.maybeWhen(
      loaded: (types) => types,
      orElse: () => <PRFContactType>[],
    );

    if (contactTypes.isEmpty) {
      _showSnackBar(
        'Contact types are still loading. Please retry in a moment.',
      );
      context.read<GetContactTypesCubit>().getContactTypes();
      return;
    }

    final createContactCubit = context.read<CreateContactCubit>()..resetState();

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            'Add Contact',
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
          child: BlocProvider.value(
            value: createContactCubit,
            child: AddContactViewHandset(
              schoolUlid: school.ulid,
              contactTypes: contactTypes,
              onContactCreated: _loadData,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection(
    BuildContext context,
    ThemeData theme,
    PRFSchool school,
  ) {
    return BlocBuilder<GetContactsCubit, GetContactsState>(
      builder: (context, state) {
        final contacts = state.maybeWhen(
          loaded: (contacts) => contacts,
          orElse: () => school.contacts,
        );

        return Card(
          elevation: PRFElevationTokens.sm,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                        theme.colorScheme.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.md,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.contacts,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: PRFSpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contacts',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: PRFSpacingTokens.xs),
                            Text(
                              '${contacts.length} linked to this school',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _refreshContacts(school.ulid),
                        icon: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'Refresh contacts',
                      ),
                      const SizedBox(width: PRFSpacingTokens.xs),
                      TextButton.icon(
                        onPressed: () => _showAddContactModal(context, school),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Add Contact'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.md,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                  child: state.maybeWhen(
                    loading: () => const Center(
                      child: PRFCircularProgressIndicator(),
                    ),
                    error: (message) => PRFEmptyView(
                      label: 'Could not load contacts',
                      description: message,
                      icon: Icons.error_outline,
                      actionLabel: 'Retry',
                      onActionPressed: () => _refreshContacts(school.ulid),
                    ),
                    orElse: () => contacts.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No contacts added yet',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: PRFSpacingTokens.sm),
                              Text(
                                'Add at least one contact so teams '
                                'can reach the right person fast.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              SizedBox(
                                width: double.infinity,
                                child: PRFPrimaryButton(
                                  onPressed: () =>
                                      _showAddContactModal(context, school),
                                  title: 'Add Contact',
                                  disabled: false,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: contacts
                                .map(
                                  (contact) => _buildContactCard(
                                    theme,
                                    contact,
                                    school,
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: PRFElevationTokens.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      ),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PRFSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.md,
                  vertical: PRFSpacingTokens.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: PRFSpacingTokens.sm),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    ThemeData theme,
    PRFContact contact,
    PRFSchool school,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                contact.name,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (contact.contactType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PRFSpacingTokens.sm,
                                  vertical: PRFSpacingTokens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contact.contactType!.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: PRFSpacingTokens.md),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                contact.phone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: PRFSpacingTokens.sm),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildCallButton(theme, contact.phone),
                                _buildContactActions(theme, contact, school),
                              ],
                            ),
                          ],
                        ),
                        if (contact.email != null) ...[
                          const SizedBox(height: PRFSpacingTokens.sm),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  contact.email!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(ThemeData theme, String phone) {
    return FilledButton.tonalIcon(
      onPressed: () => _callPhoneNumber(phone),
      icon: const Icon(Icons.call, size: 16),
      label: const Text('Call'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildContactActions(
    ThemeData theme,
    PRFContact contact,
    PRFSchool school,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit contact',
          icon: Icon(
            Icons.edit_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => _showEditContactModal(context, contact, school),
        ),
        IconButton(
          tooltip: 'Delete contact',
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: theme.colorScheme.error,
          ),
          onPressed: () => _showDeleteContactDialog(context, contact, school),
        ),
      ],
    );
  }

  Future<void> _callPhoneNumber(String phone) async {
    final sanitized = phone.trim();
    if (sanitized.isEmpty) {
      _showSnackBar('No phone number available for this contact');
      return;
    }

    final callUri = Uri(scheme: 'tel', path: sanitized);
    final didLaunch = await Misc.openUrl(callUri);

    if (!didLaunch && mounted) {
      _showSnackBar('Could not launch your phone dialer');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _refreshContacts(String schoolUlid) {
    context.read<GetContactsCubit>().getContactsForSchool(schoolUlid);
  }

  void _showEditContactModal(
    BuildContext context,
    PRFContact contact,
    PRFSchool school,
  ) {
    final theme = Theme.of(context);
    final contactTypesState = context.read<GetContactTypesCubit>().state;
    final contactTypes = contactTypesState.maybeWhen(
      loaded: (types) => types,
      orElse: () => <PRFContactType>[],
    );

    if (contactTypes.isEmpty) {
      _showSnackBar(
        'Contact types are still loading. Please retry in a moment.',
      );
      context.read<GetContactTypesCubit>().getContactTypes();
      return;
    }

    final updateContactCubit = context.read<UpdateContactCubit>()..resetState();

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            'Edit Contact',
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
          child: BlocProvider.value(
            value: updateContactCubit,
            child: EditContactViewHandset(
              contact: contact,
              contactTypes: contactTypes,
              onContactUpdated: () {
                _refreshContacts(school.ulid);
                _loadData();
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteContactDialog(
    BuildContext context,
    PRFContact contact,
    PRFSchool school,
  ) {
    final theme = Theme.of(context);
    final deleteContactCubit = context.read<DeleteContactCubit>()..resetState();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BlocConsumer<DeleteContactCubit, DeleteContactState>(
          bloc: deleteContactCubit,
          listener: (context, state) {
            state.maybeWhen(
              loaded: () {
                Navigator.of(dialogContext).pop();
                _refreshContacts(school.ulid);
                _loadData();
                _showSnackBar('Contact deleted');
              },
              error: (message) {
                _showSnackBar(message);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PRFSpacingTokens.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: PRFSpacingTokens.md),
                  Expanded(
                    child: Text(
                      'Delete Contact',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete ${contact.name}?',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: PRFSpacingTokens.md),
                  Text(
                    'This cannot be undone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => deleteContactCubit.deleteContact(
                          ulid: contact.ulid,
                        ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: PRFSpacingTokens.lg,
                      vertical: PRFSpacingTokens.sm,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSchoolForm(BuildContext context, PRFSchool? school) {
    final theme = Theme.of(context);
    final isEditing = school != null;

    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalContext) => [
        WoltModalSheetPage(
          backgroundColor: Colors.white,
          topBarTitle: Text(
            isEditing ? 'Edit School' : 'Add School',
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
          child: isEditing
              ? EditSchoolViewHandset(
                  school: school,
                  onSchoolUpdated: _loadData,
                )
              : AddSchoolViewHandset(
                  onSchoolCreated: _loadData,
                ),
        ),
      ],
    );
  }
}
