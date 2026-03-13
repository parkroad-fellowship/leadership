import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/members/member_detail/_handset.dart';

@RoutePage()
class MemberDetailsPage extends StatelessWidget {
  const MemberDetailsPage({
    @PathParam('memberUlid') required this.memberUlid,
    super.key,
  });

  final String memberUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => MemberDetailPageHandset(memberUlid: memberUlid),
    );
  }
}
