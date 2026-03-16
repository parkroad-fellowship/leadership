import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/enums/media_type.dart';
import 'package:leadership/enums/prf_media_model.dart';
import 'package:leadership/enums/prf_theme_mode.dart';
import 'package:leadership/features/home/account/cubit/change_profile_picture_cubit.dart';
import 'package:leadership/features/home/account/cubit/sign_out_cubit.dart';
import 'package:leadership/features/home/cubit/theme_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/_index.dart';
import 'package:prf_design/prf_design.dart';

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
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
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

            const SliverToBoxAdapter(
              child: SizedBox(height: PRFSpacingTokens.xxxl),
            ),

            // Profile Section
            SliverToBoxAdapter(
              child:
                  Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: PRFSpacingTokens.xxl,
                        ),
                        padding: const EdgeInsets.all(PRFSpacingTokens.xxxl),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.xxl,
                          ),
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
                                      color: theme.colorScheme.primary
                                          .withValues(
                                            alpha: 0.3,
                                          ),
                                      width: 4,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: ValueListenableBuilder(
                                      valueListenable: Hive.box<dynamic>(
                                        PRFLeadershipConfig
                                            .instance!
                                            .values
                                            .hiveBox,
                                      ).listenable(),
                                      builder: (context, _, _) {
                                        final profilePicture =
                                            getIt<HiveService>()
                                                .retrieveMember()
                                                ?.profilePicture;

                                        return profilePicture != null
                                            ? Image.network(
                                                profilePicture.temporaryURL,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Icon(
                                                      Icons.person_rounded,
                                                      size: 70,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.person_rounded,
                                                size: 70,
                                                color:
                                                    theme.colorScheme.primary,
                                              );
                                      },
                                    ),
                                  ),
                                ),
                                const ChangeProfilePictureButton(),
                              ],
                            ),
                            const SizedBox(height: PRFSpacingTokens.xxl),
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
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                );
                              },
                            ),
                            const SizedBox(height: PRFSpacingTokens.sm),
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
                      )
                      .animate()
                      .fadeIn(duration: PRFMotionTokens.slow)
                      .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: PRFSpacingTokens.xxxl),
            ),

            // Dark Mode Toggle
            SliverToBoxAdapter(
              child:
                  Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: PRFSpacingTokens.xxl,
                        ),
                        padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.xxl,
                          ),
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.dark_mode_outlined,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: PRFSpacingTokens.lg),
                            Expanded(
                              child: Text(
                                'Dark Mode',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            BlocBuilder<ThemeCubit, ThemeState>(
                              builder: (context, state) {
                                final themeCubit = context.read<ThemeCubit>();
                                return Switch.adaptive(
                                  value: themeCubit.isDarkMode,
                                  onChanged: (value) => themeCubit.setThemeMode(
                                    value
                                        ? PRFThemeMode.dark
                                        : PRFThemeMode.light,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                      .animate(delay: 50.ms)
                      .fadeIn(duration: PRFMotionTokens.slow)
                      .slideY(begin: 0.1, end: 0),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: PRFSpacingTokens.xxxl),
            ),

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
                                    const SizedBox(width: PRFSpacingTokens.lg),
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
                                const SizedBox(height: PRFSpacingTokens.xxl),
                                _buildInfoField(
                                  context,
                                  label: l10n.name,
                                  value: profile.name,
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: PRFSpacingTokens.xl),
                                _buildInfoField(
                                  context,
                                  label: l10n.email,
                                  value: profile.email,
                                  icon: Icons.email_outlined,
                                ),
                              ],
                            ),
                          )
                          .animate(delay: PRFMotionTokens.stagger1)
                          .fadeIn(duration: PRFMotionTokens.slow)
                          .slideY(begin: 0.1, end: 0),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: PRFSpacingTokens.xxxl),
            ),

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
                                    const SizedBox(width: PRFSpacingTokens.lg),
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
                              ],
                            ),
                          )
                          .animate(delay: PRFMotionTokens.stagger2)
                          .fadeIn(duration: PRFMotionTokens.slow)
                          .slideY(begin: 0.1, end: 0),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // Footer Section
            SliverToBoxAdapter(
              child:
                  Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: PRFSpacingTokens.xxl,
                        ),
                        padding: const EdgeInsets.all(PRFSpacingTokens.xxl),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            PRFRadiusTokens.xxl,
                          ),
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
                            const SizedBox(height: PRFSpacingTokens.lg),
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
                      .animate(delay: PRFMotionTokens.stagger3)
                      .fadeIn(duration: PRFMotionTokens.slow)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                      ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: PRFSpacingTokens.xxxl),
            ),
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
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
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
          const SizedBox(width: PRFSpacingTokens.md),
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
                const SizedBox(height: PRFSpacingTokens.xs),
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
              padding: const EdgeInsets.all(PRFSpacingTokens.md),
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
