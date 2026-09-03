import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/missions/_handset.dart'
    show TimelineMissionCard;
import 'package:leadership/features/missions/cubit/past_mission_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:prf_design/prf_design.dart';

class SchoolPastMissionsHandset extends StatefulWidget {
  const SchoolPastMissionsHandset({required this.schoolUlid, super.key});

  final String schoolUlid;

  @override
  State<SchoolPastMissionsHandset> createState() =>
      _SchoolPastMissionsHandsetState();
}

class _SchoolPastMissionsHandsetState extends State<SchoolPastMissionsHandset> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PastMissionResourceCubit>();
    // The schools tab normally loads the cubit before navigation, but ensure
    // the data is present when arriving via a deep link or direct navigation.
    final hasSchool = cubit.currentItems.any((s) => s.ulid == widget.schoolUlid);
    if (!hasSchool) {
      cubit.loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<PastMissionResourceCubit, ResourceState<PRFSchool>>(
        builder: (context, state) {
          final schools = context.read<PastMissionResourceCubit>().currentItems;
          PRFSchool? school;
          for (final s in schools) {
            if (s.ulid == widget.schoolUlid) {
              school = s;
              break;
            }
          }

          final isLoading =
              state is ResourceListLoading<PRFSchool> && schools.isEmpty;

          if (school == null) {
            return Column(
              children: [
                PRFBrandedNavBar(
                  title: l10n.missions,
                  onBack: () => context.router.maybePop(),
                ),
                Expanded(
                  child: Center(
                    child: isLoading
                        ? const PRFCircularProgressIndicator()
                        : PRFEmptyView(
                            label: l10n.noPastMissions,
                            description: l10n.pleaseWait,
                          ),
                  ),
                ),
              ],
            );
          }

          final missions = List<PRFMission>.from(school.missions)
            ..sort((a, b) => b.startDate.compareTo(a.startDate));

          return Column(
            children: [
              PRFBrandedNavBar(
                title: school.name,
                onBack: () => context.router.maybePop(),
              ),
              Expanded(
                child: missions.isEmpty
                    ? PRFEmptyView(
                        label: l10n.noMissions,
                        description: l10n.noPastMissions,
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            context.read<PastMissionResourceCubit>().loadAll(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.lg,
                            vertical: PRFSpacingTokens.xl,
                          ),
                          children: missions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final mission = entry.value;
                            final isLast = index == missions.length - 1;

                            return TimelineMissionCard(
                              mission: mission,
                              isLast: isLast,
                              index: index,
                              onTap: () => context.router.push(
                                MissionsDetailsRoute(
                                  missionUlid: mission.ulid,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
