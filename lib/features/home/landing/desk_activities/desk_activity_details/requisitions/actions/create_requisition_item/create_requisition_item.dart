import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/actions/create_event/_handset.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition/_handset.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition_item/_handset.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition.dart';

class CreateRequisitionItemView extends StatelessWidget {
  const CreateRequisitionItemView({super.key, required this.requisitionUlid});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => CreateRequisitionItemViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => CreateRequisitionItemViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
