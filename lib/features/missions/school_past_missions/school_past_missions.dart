import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/missions/school_past_missions/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class SchoolPastMissionsPage extends StatelessWidget {
  const SchoolPastMissionsPage({
    @PathParam('schoolUlid') required this.schoolUlid,
    super.key,
  });

  final String schoolUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => SchoolPastMissionsHandset(schoolUlid: schoolUlid),
      builder: (_, _) => SchoolPastMissionsHandset(schoolUlid: schoolUlid),
    );
  }
}
