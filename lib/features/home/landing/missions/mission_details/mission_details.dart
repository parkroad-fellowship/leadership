import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/mission_details/_handset.dart';

@RoutePage()
class MissionsDetailsPage extends StatelessWidget {
  const MissionsDetailsPage({
    @PathParam('missionUlid') required this.missionUlid,
    super.key,
  });

  final String missionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) =>
          MissionsDetailsPageHandset(missionUlid: missionUlid),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => MissionsDetailsPageHandset(missionUlid: missionUlid),
      ),
    );
  }
}
