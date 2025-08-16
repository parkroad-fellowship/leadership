import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/actions/create_event/_handset.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_requisition/_handset.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';

class CreateRequisitionView extends StatelessWidget {
  const CreateRequisitionView({super.key, required this.accountingEvent});

  final PRFAccountingEvent accountingEvent;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => CreateRequisitionViewHandset(
        accountingEvent: accountingEvent,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => CreateRequisitionViewHandset(
          accountingEvent: accountingEvent,
        ),
      ),
    );
  }
}
