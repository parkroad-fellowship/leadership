import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/members/actions/member_form/_handset.dart';
import 'package:leadership/features/home/landing/members/cubit/member_resource_cubit.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_widgets/_index.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class MemberDetailPageHandset extends StatefulWidget {
  const MemberDetailPageHandset({
    required this.memberUlid,
    super.key,
  });

  final String memberUlid;

  @override
  State<MemberDetailPageHandset> createState() =>
      _MemberDetailPageHandsetState();
}

class _MemberDetailPageHandsetState extends State<MemberDetailPageHandset> {
  PRFMember? get _member {
    final state = context.read<MemberResourceCubit>().state;
    final items = switch (state) {
      ResourceListLoaded<PRFMember>(:final items) => items,
      ResourceMutating<PRFMember>(:final items) => items,
      ResourceMutated<PRFMember>(:final items) => items,
      ResourceError<PRFMember>(:final items) => items,
      _ => <PRFMember>[],
    };
    return items.cast<PRFMember?>().firstWhere(
      (m) => m!.ulid == widget.memberUlid,
      orElse: () => null,
    );
  }

  void _reloadData() {
    context.read<MemberResourceCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
      builder: (context, state) {
        final member = _member;
        if (member == null) {
          return Scaffold(
            appBar: PRFAppBar(
              title: 'Member Details',
              onBack: () => context.router.maybePop(),
            ),
            body: const Center(
              child: PRFCircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Column(
            children: [
              ColoredBox(
                color: theme.colorScheme.primary,
                child: PRFBrandedNavBar(
                  title: 'Member',
                  onBack: () => context.router.maybePop(),
                  actions: [
                    PRFHeaderActionButton(
                      label: 'Edit',
                      variant: PRFHeaderActionButtonVariant.neutral,
                      onTap: () => _showEditForm(member),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(theme, member),
                      Transform.translate(
                        offset: const Offset(0, -PRFSpacingTokens.md),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            PRFSpacingTokens.lg,
                            0,
                            PRFSpacingTokens.lg,
                            PRFSpacingTokens.xxxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPersonalSection(theme, member),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              _buildSpiritualSection(theme, member),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              _buildProfessionalSection(theme, member),
                              const SizedBox(height: PRFSpacingTokens.lg),
                              _buildDemographicsSection(theme, member),
                              if (member.departments.isNotEmpty) ...[
                                const SizedBox(height: PRFSpacingTokens.lg),
                                _buildDepartmentsSection(theme, member),
                              ],
                              if (member.gifts.isNotEmpty) ...[
                                const SizedBox(height: PRFSpacingTokens.lg),
                                _buildGiftsSection(theme, member),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // Hero section
  // -----------------------------------------------------------

  Widget _buildHeroSection(ThemeData theme, PRFMember member) {
    final initials = _getInitials(member);
    final onPrimary = theme.colorScheme.onPrimary;
    final profileUrl = member.profilePicture?.temporaryURL;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            PRFColorPalette.navy600,
            PRFColorPalette.navy400,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PRFSpacingTokens.xxl,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: onPrimary.withValues(alpha: 0.2),
                  width: 3,
                ),
                image: profileUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profileUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: profileUrl == null
                  ? Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: PRFSpacingTokens.md),
            // Member name
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.xxl,
              ),
              child: Text(
                member.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.sm),
            // Email badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.md,
                vertical: PRFSpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
              ),
              child: Text(
                member.email,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: onPrimary.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            Container(
              height: PRFSpacingTokens.lg,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // Personal section
  // -----------------------------------------------------------

  Widget _buildPersonalSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.person_outline,
      title: 'PERSONAL',
      children: [
        if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty)
          _infoRow(theme, 'Phone', member.phoneNumber!),
        _infoRow(theme, 'Email', member.email),
        if (member.postalAddress != null && member.postalAddress!.isNotEmpty)
          _infoRow(theme, 'Postal Address', member.postalAddress!),
        if (member.residence != null && member.residence!.isNotEmpty)
          _infoRow(theme, 'Residence', member.residence!),
        if (member.bio != null && member.bio!.isNotEmpty)
          _infoRow(theme, 'Bio', member.bio!),
        if (member.linkedInUrl != null && member.linkedInUrl!.isNotEmpty)
          _infoRow(theme, 'LinkedIn', member.linkedInUrl!),
      ],
    );
  }

  // -----------------------------------------------------------
  // Spiritual section
  // -----------------------------------------------------------

  Widget _buildSpiritualSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.church_outlined,
      title: 'SPIRITUAL',
      children: [
        if (member.yearOfSalvation != null)
          _infoRow(theme, 'Year of Salvation', '${member.yearOfSalvation}'),
        _infoRow(
          theme,
          'Church Volunteer',
          member.churchVolunteer ? 'Yes' : 'No',
        ),
        if (member.pastor != null && member.pastor!.isNotEmpty)
          _infoRow(theme, 'Pastor', member.pastor!),
        if (member.church != null)
          _infoRow(theme, 'Church', member.church!.name),
      ],
    );
  }

  // -----------------------------------------------------------
  // Professional section
  // -----------------------------------------------------------

  Widget _buildProfessionalSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.work_outline,
      title: 'PROFESSIONAL',
      children: [
        if (member.profession != null)
          _infoRow(theme, 'Profession', member.profession!.name),
        if (member.professionInstitution != null &&
            member.professionInstitution!.isNotEmpty)
          _infoRow(theme, 'Institution', member.professionInstitution!),
        if (member.professionLocation != null &&
            member.professionLocation!.isNotEmpty)
          _infoRow(theme, 'Location', member.professionLocation!),
        if (member.professionContact != null &&
            member.professionContact!.isNotEmpty)
          _infoRow(theme, 'Contact', member.professionContact!),
      ],
    );
  }

  // -----------------------------------------------------------
  // Demographics section
  // -----------------------------------------------------------

  Widget _buildDemographicsSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.groups_outlined,
      title: 'DEMOGRAPHICS',
      children: [
        if (member.gender != null)
          _infoRow(
            theme,
            'Gender',
            member.gender == 1 ? 'Male' : 'Female',
          ),
        if (member.maritalStatus != null)
          _infoRow(theme, 'Marital Status', member.maritalStatus!.name),
      ],
    );
  }

  // -----------------------------------------------------------
  // Departments section
  // -----------------------------------------------------------

  Widget _buildDepartmentsSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.groups_outlined,
      title: 'DEPARTMENTS',
      children: [
        Wrap(
          spacing: PRFSpacingTokens.xs,
          runSpacing: PRFSpacingTokens.xs,
          children: member.departments
              .map(
                (d) => Chip(
                  label: Text(
                    d.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // Gifts section
  // -----------------------------------------------------------

  Widget _buildGiftsSection(ThemeData theme, PRFMember member) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.card_giftcard_outlined,
      title: 'GIFTS',
      children: [
        Wrap(
          spacing: PRFSpacingTokens.xs,
          runSpacing: PRFSpacingTokens.xs,
          children: member.gifts
              .map(
                (g) => Chip(
                  label: Text(
                    g.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // Reusable widgets
  // -----------------------------------------------------------

  Widget _buildSectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.9,
                ),
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.9,
                  ),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.lg),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: PRFSpacingTokens.sm,
              ),
              child: Text(
                'No information available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // Actions
  // -----------------------------------------------------------

  void _showEditForm(PRFMember member) {
    PRFBottomSheet.show<void>(
      context,
      title: 'Edit Member',
      child: MemberFormViewHandset(
        member: member,
        onSaved: _reloadData,
      ),
    );
  }

  String _getInitials(PRFMember member) {
    final first = member.firstName.trim();
    final last = member.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    return member.fullName
        .substring(0, member.fullName.length.clamp(0, 2))
        .toUpperCase();
  }
}
