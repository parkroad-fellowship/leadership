import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class MissionsDetailsPage extends StatelessWidget {
  const MissionsDetailsPage({
    @PathParam('missionUlid') required this.missionUlid,
    super.key,
  });

  final String missionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => MissionsDetailsPageHandset(missionUlid: missionUlid),
      builder: (_, _) => MissionsDetailsPageHandset(missionUlid: missionUlid),
    );
  }
}
