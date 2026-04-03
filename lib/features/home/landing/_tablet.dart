import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:leadership/features/home/landing/models/landing_action_item.dart';
import 'package:leadership/features/home/landing/widgets/landing_action_tile.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:prf_design/prf_design.dart';

class LandingPageTablet extends StatelessWidget {
  const LandingPageTablet({required this.actions, super.key});

  final List<LandingActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200 ? 3 : 2;
    final visibleActions = actions.where((action) => action.isVisible).toList();
    final settingsActions = visibleActions
        .where((action) => action.isSettings)
        .toList();
    final deskGroups = <String, List<LandingActionItem>>{};

    for (final action in visibleActions.where((action) => !action.isSettings)) {
      final group = action.deskGroup;
      if (group == null || group.isEmpty) {
        continue;
      }
      deskGroups.putIfAbsent(group, () => <LandingActionItem>[]).add(action);
    }

    final sections = <_LandingActionSection>[
      ...deskGroups.entries
          .where((entry) => entry.value.isNotEmpty)
          .map(
            (entry) => _LandingActionSection(
              title: entry.key,
              actions: entry.value,
            ),
          ),
      if (settingsActions.isNotEmpty)
        _LandingActionSection(title: 'Settings', actions: settingsActions),
    ];

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
                  padding: const EdgeInsets.all(PRFSpacingTokens.xxxl),
                  child: Row(
                    children: [
                      // Profile Picture
                      GestureDetector(
                            onTap: () => context.router.pushPath(
                              PRFLeadershipRouter.accountRoute,
                            ),
                            child: Container(
                              width: 64,
                              height: 64,
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
                                                    size: 32,
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
                                              style: theme.textTheme.titleLarge
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

                      const SizedBox(width: PRFSpacingTokens.xxl),

                      // Greeting Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcome,
                              style: theme.textTheme.bodyMedium?.copyWith(
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
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ..._buildSectionSlivers(
                context: context,
                sections: sections,
                columns: columns,
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletActionCard({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
    required int delay,
    bool isNeutralCard = false,
  }) {
    return Animate(
      effects: [
        FadeEffect(
          duration: 360.ms,
          delay: Duration(milliseconds: delay),
        ),
        SlideEffect(
          duration: 420.ms,
          delay: Duration(milliseconds: delay),
          begin: const Offset(0, 0.08),
          curve: Curves.easeOut,
        ),
      ],
      child: LandingActionTile(
        title: title,
        assetPath: assetPath,
        onTap: onTap,
        assetHeight: 64,
        isNeutralCard: isNeutralCard,
      ),
    );
  }

  List<Widget> _buildSectionSlivers({
    required BuildContext context,
    required List<_LandingActionSection> sections,
    required int columns,
  }) {
    final theme = Theme.of(context);
    final slivers = <Widget>[];
    var runningIndex = 0;

    for (final section in sections) {
      final sectionStart = runningIndex;
      runningIndex += section.actions.length;

      slivers
        ..add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PRFSpacingTokens.xxxl,
                PRFSpacingTokens.xl,
                PRFSpacingTokens.xxxl,
                PRFSpacingTokens.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: PRFSpacingTokens.sm),
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.xxxl,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: PRFSpacingTokens.lg,
                mainAxisSpacing: PRFSpacingTokens.lg,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final action = section.actions[index];
                  return _buildTabletActionCard(
                    title: action.title,
                    assetPath: action.assetPath,
                    onTap: action.onTap,
                    delay:
                        action.animationDelay + ((sectionStart + index) * 40),
                    isNeutralCard: action.isNeutralCard,
                  );
                },
                childCount: section.actions.length,
              ),
            ),
          ),
        );
    }

    return slivers;
  }
}

class _LandingActionSection {
  const _LandingActionSection({
    required this.title,
    required this.actions,
  });

  final String title;
  final List<LandingActionItem> actions;
}
