import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/members/member_detail/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class MemberDetailsPage extends StatelessWidget {
  const MemberDetailsPage({
    @PathParam('memberUlid') required this.memberUlid,
    super.key,
  });

  final String memberUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => MemberDetailPageHandset(memberUlid: memberUlid),
      builder: (_, _) => MemberDetailPageHandset(memberUlid: memberUlid),
    );
  }
}
