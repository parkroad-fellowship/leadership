import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:prf_design/prf_design.dart';

class LandingPageHandset extends StatelessWidget {
  const LandingPageHandset({required this.actions, super.key});

  final List<List<Object>> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => Misc.exitApp(
        context: context,
        didPop: didPop,
        result: result,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                  child: Row(
                    children: [
                      // Profile Picture
                      GestureDetector(
                            onTap: () => context.router.pushPath(
                              PRFLeadershipRouter.accountRoute,
                            ),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                    final profilePicture = getIt<HiveService>()
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
                                                ) => CircleAvatar(
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 28,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            child: Text(
                                              Misc.getUserNameInitials(
                                                getIt<HiveService>()
                                                        .retrieveMember()
                                                        ?.fullName ??
                                                    '',
                                              ),
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          );
                                  },
                                ),
                              ),
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            duration: 2000.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                          )
                          .then(delay: 1000.ms),

                      const SizedBox(width: PRFSpacingTokens.lg),

                      // Greeting Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcome,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: PRFSpacingTokens.xs),
                            Text(
                              l10n.hello(
                                getIt<HiveService>().auth
                                        .retrieveProfile()
                                        ?.member
                                        ?.lastName ??
                                    '',
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PRFSpacingTokens.lg,
                    PRFSpacingTokens.xxl,
                    PRFSpacingTokens.lg,
                    PRFSpacingTokens.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.iWantTo,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          fontSize: 32,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: PRFSpacingTokens.md),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Cards
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    actions
                        .where((action) => action[4] as bool)
                        .map(
                          (action) => _buildAnimatedCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PRFSpacingTokens.sm,
                              ),
                              child: PRFActionCard(
                                title: action[0] as String,
                                image: SvgPicture.asset(
                                  action[1] as String,
                                  height: 100,
                                ),
                                onTap: action[2] as VoidCallback,
                              ),
                            ),
                            delay: action[3] as int,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.lg),
      child: Animate(
        effects: [
          FadeEffect(
            duration: 400.ms,
            delay: Duration(milliseconds: delay),
          ),
          SlideEffect(
            duration: 500.ms,
            delay: Duration(milliseconds: delay),
            begin: Offset([-1, 1].sample(1).single * 0.2, 0),
            curve: Curves.easeOut,
          ),
        ],
        child: child,
      ),
    );
  }
}
