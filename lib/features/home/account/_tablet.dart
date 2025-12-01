import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/enums/prf_membership_type.dart';
import 'package:leadership/features/home/account/cubit/change_profile_picture_cubit.dart';
import 'package:leadership/features/home/account/cubit/sign_out_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/shared_widgets/navbar/navbar.dart';
import 'package:leadership/shared_widgets/progress/circular_progress_indicator.dart';
import 'package:leadership/utils/_index.dart';

class AccountPageTablet extends StatelessWidget {
  const AccountPageTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern Navigation Bar
            PRFNavBar(
              title: l10n.myAccount,
              onBack: () => context.router.popUntilRouteWithPath(
                PRFLeadershipRouter.landingRoute,
              ),
              backgroundColor: theme.colorScheme.surface,
              actions: [
                Animate(
                  effects: [ShimmerEffect(duration: 1.seconds)],
                  child: BlocListener<SignOutCubit, SignOutState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        orElse: () => context.router.pushPath(
                          PRFLeadershipRouter.decisionRoute,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => context.read<SignOutCubit>().signOut(),
                        icon: Icon(
                          Icons.logout_rounded,
                          color: theme.colorScheme.error,
                          size: 24,
                        ),
                        tooltip: l10n.signOut,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Profile Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                theme.colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 4,
                            ),
                          ),
                          child: ClipOval(
                            child: ValueListenableBuilder(
                              valueListenable: Hive.box<dynamic>(
                                PRFLeadershipConfig.instance!.values.hiveBox,
                              ).listenable(),
                              builder: (context, _, _) {
                                final profilePicture = getIt<HiveService>()
                                    .retrieveMember()
                                    ?.profilePicture;

                                return profilePicture != null
                                    ? Image.network(
                                        profilePicture.temporaryURL,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.person_rounded,
                                                  size: 70,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                      )
                                    : Icon(
                                        Icons.person_rounded,
                                        size: 70,
                                        color: theme.colorScheme.primary,
                                      );
                              },
                            ),
                          ),
                        ),
                        const ChangeProfilePictureButton(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // User Name
                    ValueListenableBuilder(
                      valueListenable: Hive.box<dynamic>(
                        PRFLeadershipConfig.instance!.values.hiveBox,
                      ).listenable(),
                      builder: (context, _, _) {
                        final profile = getIt<HiveService>().auth
                            .retrieveProfile();
                        return Text(
                          profile?.name ?? 'User',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // User Email
                    ValueListenableBuilder(
                      valueListenable: Hive.box<dynamic>(
                        PRFLeadershipConfig.instance!.values.hiveBox,
                      ).listenable(),
                      builder: (context, _, _) {
                        final profile = getIt<HiveService>().auth
                            .retrieveProfile();
                        return Text(
                          profile?.email ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Personal Information Section
            ValueListenableBuilder(
              valueListenable: Hive.box<dynamic>(
                PRFLeadershipConfig.instance!.values.hiveBox,
              ).listenable(),
              builder: (context, _, _) {
                final profile = getIt<HiveService>().auth.retrieveProfile();
                if (profile == null) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child:
                      Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Personal Information',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildInfoField(
                                  context,
                                  label: l10n.name,
                                  value: profile.name,
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildInfoField(
                                  context,
                                  label: l10n.email,
                                  value: profile.email,
                                  icon: Icons.email_outlined,
                                ),
                                if (profile.member?.bio != null &&
                                    profile.member!.bio!.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  _buildInfoField(
                                    context,
                                    label: l10n.bio,
                                    value: profile.member!.bio!,
                                    icon: Icons.description_outlined,
                                    maxLines: 3,
                                  ),
                                ],
                              ],
                            ),
                          )
                          .animate(delay: 100.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Memberships Section
            ValueListenableBuilder(
              valueListenable: Hive.box<dynamic>(
                PRFLeadershipConfig.instance!.values.hiveBox,
              ).listenable(),
              builder: (context, _, _) {
                final profile = getIt<HiveService>().auth.retrieveProfile();
                if (profile?.member?.memberships.isEmpty ?? true) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child:
                      Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.groups_outlined,
                                      color: theme.colorScheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      l10n.memberships,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...profile!.member!.memberships
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              entry.key <
                                                  profile
                                                          .member!
                                                          .memberships
                                                          .length -
                                                      1
                                              ? 16
                                              : 0,
                                        ),
                                        child: _buildMembershipCard(
                                          context,
                                          spiritualYear:
                                              entry.value.spiritualYear!.name,
                                          membershipType:
                                              PrfMembershipType.fromIndex(
                                                entry.value.type,
                                              ).name,
                                          isApproved: entry.value.approved,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // Footer Section
            SliverToBoxAdapter(
              child:
                  Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: l10n.byUsing,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: l10n.terms,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final uri = Uri(
                                          scheme: 'https',
                                          host: 'parkroadfellowship.org',
                                          path: '/privacy-policy',
                                        );
                                        await Misc.openUrl(uri);
                                      },
                                  ),
                                  TextSpan(
                                    text: l10n.and,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.privacyPolicy,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final uri = Uri(
                                          scheme: 'https',
                                          host: 'parkroadfellowship.org',
                                          path: 'privacy-policy',
                                        );
                                        await Misc.openUrl(uri);
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.version(Misc.getAppVersion()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                      ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(
    BuildContext context, {
    required String spiritualYear,
    required String membershipType,
    required bool isApproved,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isApproved
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isApproved ? Icons.check_circle_outline : Icons.pending_outlined,
              color: isApproved
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spiritualYear,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  membershipType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isApproved
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isApproved ? 'Approved' : 'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isApproved
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangeProfilePictureButton extends StatelessWidget {
  const ChangeProfilePictureButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<dynamic>(
        PRFLeadershipConfig.instance!.values.hiveBox,
      ).listenable(),
      builder: (context, _, _) {
        final member = getIt<HiveService>().retrieveMember();
        if (member == null) return const SizedBox.shrink();
        return Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: () =>
                context.read<ChangeProfilePictureCubit>().changeProfilePicture(
                  context: context,
                  modelUlid: member.ulid,
                  model: PRFMediaModel.memberProfilePictures,
                  mediaType: MediaType.image,
                ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  BlocConsumer<
                    ChangeProfilePictureCubit,
                    ChangeProfilePictureState
                  >(
                    listener: (context, state) {
                      state.mapOrNull(
                        loaded: (_) {
                          Gaimon.success();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.successfullyUpdated,
                              ),
                            ),
                          );
                        },
                        error: (error) {
                          Gaimon.error();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(error.message),
                            ),
                          );
                        },
                      );
                    },
                    builder: (context, state) => state.maybeWhen(
                      orElse: () => const Icon(
                        Icons.camera_alt_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                      loading: () => SizedBox.square(
                        dimension: 24,
                        child: PRFCircularProgressIndicator(
                          color: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}
