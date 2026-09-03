import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/schools/school_detail/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class SchoolDetailsPage extends StatelessWidget {
  const SchoolDetailsPage({
    @PathParam('schoolUlid') required this.schoolUlid,
    super.key,
  });

  final String schoolUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => SchoolDetailPageHandset(schoolUlid: schoolUlid),
      builder: (_, _) => SchoolDetailPageHandset(schoolUlid: schoolUlid),
    );
  }
}
