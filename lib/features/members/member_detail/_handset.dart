import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/members/actions/member_form/_handset.dart';
import 'package:leadership/features/members/cubit/member_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/shared_widgets/error_screen.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class MemberDetailPageHandset extends StatefulWidget {
  const MemberDetailPageHandset({required this.memberUlid, super.key});

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
      ResourceError<PRFMember>(:final items) => items,
      _ => <PRFMember>[],
    };
    return items.cast<PRFMember?>().firstWhere(
      (m) => m!.ulid == widget.memberUlid,
      orElse: () => null,
    );
  }

  /// Only used by the not-found retry; the member itself comes from the
  /// list cubit (Hive-backed), so opening the page loads nothing.
  void _retryLoad() {
    context.read<MemberResourceCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<MemberResourceCubit, ResourceState<PRFMember>>(
      builder: (context, state) {
        final member = _member;
        if (member == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: switch (state) {
              ResourceError<PRFMember>() => PRFLeadershipErrorScreen(
                navBarTitle: l10n.membersDetailLoadingTitle,
                title: l10n.membersLoadError,
                onBack: () => context.router.maybePop(),
                onRetry: _retryLoad,
              ),
              ResourceListLoaded<PRFMember>() => PRFEmptyView(
                navBarTitle: l10n.membersDetailLoadingTitle,
                onBackPressed: () => context.router.maybePop(),
                label: l10n.membersNotFoundTitle,
                description: l10n.membersNotFoundMessage,
                icon: Icons.person_off_outlined,
              ),
              _ => Column(
                children: [
                  PRFBrandedNavBar(
                    title: l10n.membersDetailLoadingTitle,
                    onBack: () => context.router.maybePop(),
                  ),
                  const Expanded(
                    child: Center(child: PRFCircularProgressIndicator()),
                  ),
                ],
              ),
            },
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Column(
            children: [
              ColoredBox(
                color: theme.colorScheme.primary,
                child: PRFBrandedNavBar(
                  title: l10n.membersDetailTitle,
                  onBack: () => context.router.maybePop(),
                  actions: [
                    PRFNavBarAction(
                      label: l10n.edit,
                      icon: Icons.edit_outlined,
                      tooltip: l10n.membersEditTooltip,
                      variant: PRFNavBarActionVariant.neutral,
                      onPressed: () => _showEditForm(member),
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
            // Tint toward onPrimary so the name stays readable (AA) on
            // every stop in light and dark mode.
            Color.lerp(theme.colorScheme.primary, onPrimary, 0.06)!,
            Color.lerp(theme.colorScheme.primary, onPrimary, 0.12)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PRFSpacingTokens.xxl),
        child: Column(
          children: [
            // Avatar
            Container(
              width: PRFSizeTokens.iconHero + PRFSpacingTokens.sm,
              height: PRFSizeTokens.iconHero + PRFSpacingTokens.sm,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: PRFOpacities.muted),
                shape: BoxShape.circle,
                border: Border.all(
                  color: onPrimary.withValues(alpha: PRFOpacities.muted),
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
                color: onPrimary.withValues(alpha: PRFOpacities.muted),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
              ),
              child: Text(
                member.email,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: onPrimary,
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
                    theme.colorScheme.surface.withValues(
                      alpha: PRFOpacities.stronger,
                    ),
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
      title: context.l10n.membersSectionPersonal,
      children: [
        if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty)
          _infoRow(theme, context.l10n.membersPhone, member.phoneNumber!),
        _infoRow(theme, context.l10n.email, member.email),
        if (member.postalAddress != null && member.postalAddress!.isNotEmpty)
          _infoRow(
            theme,
            context.l10n.membersPostalAddress,
            member.postalAddress!,
          ),
        if (member.residence != null && member.residence!.isNotEmpty)
          _infoRow(theme, context.l10n.membersResidence, member.residence!),
        if (member.bio != null && member.bio!.isNotEmpty)
          _infoRow(theme, context.l10n.membersBio, member.bio!),
        if (member.linkedInUrl != null && member.linkedInUrl!.isNotEmpty)
          _infoRow(theme, context.l10n.membersLinkedIn, member.linkedInUrl!),
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
      title: context.l10n.membersSectionSpiritual,
      children: [
        if (member.yearOfSalvation != null)
          _infoRow(
            theme,
            context.l10n.membersYearOfSalvation,
            '${member.yearOfSalvation}',
          ),
        _infoRow(
          theme,
          context.l10n.membersChurchVolunteer,
          member.churchVolunteer ? context.l10n.yes : context.l10n.no,
        ),
        if (member.pastor != null && member.pastor!.isNotEmpty)
          _infoRow(theme, context.l10n.membersPastor, member.pastor!),
        if (member.church != null)
          _infoRow(theme, context.l10n.membersChurch, member.church!.name),
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
      title: context.l10n.membersSectionProfessional,
      children: [
        if (member.profession != null)
          _infoRow(
            theme,
            context.l10n.membersProfession,
            member.profession!.name,
          ),
        if (member.professionInstitution != null &&
            member.professionInstitution!.isNotEmpty)
          _infoRow(
            theme,
            context.l10n.membersInstitution,
            member.professionInstitution!,
          ),
        if (member.professionLocation != null &&
            member.professionLocation!.isNotEmpty)
          _infoRow(
            theme,
            context.l10n.membersLocation,
            member.professionLocation!,
          ),
        if (member.professionContact != null &&
            member.professionContact!.isNotEmpty)
          _infoRow(
            theme,
            context.l10n.membersContact,
            member.professionContact!,
          ),
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
      title: context.l10n.membersSectionDemographics,
      children: [
        if (member.gender != null)
          _infoRow(
            theme,
            context.l10n.membersGender,
            member.gender == 1
                ? context.l10n.membersMale
                : context.l10n.membersFemale,
          ),
        if (member.maritalStatus != null)
          _infoRow(
            theme,
            context.l10n.membersMaritalStatus,
            member.maritalStatus!.name,
          ),
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
      title: context.l10n.membersSectionDepartments,
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
                    alpha: PRFOpacities.subtle,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(
                      alpha: PRFOpacities.glow,
                    ),
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
      title: context.l10n.membersSectionGifts,
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
                    alpha: PRFOpacities.subtle,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(
                      alpha: PRFOpacities.glow,
                    ),
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
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: PRFSizeTokens.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: PRFSpacingTokens.sm),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
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
                context.l10n.membersNoInformation,
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
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
      title: context.l10n.membersEdit,
      child: MemberFormViewHandset(member: member, onSaved: () {}),
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
