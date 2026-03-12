import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/schools/school_detail/_handset.dart';

@RoutePage()
class SchoolDetailsPage extends StatelessWidget {
  const SchoolDetailsPage({
    @PathParam('schoolUlid') required this.schoolUlid,
    super.key,
  });

  final String schoolUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => SchoolDetailPageHandset(schoolUlid: schoolUlid),
    );
  }
}
