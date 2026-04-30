import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition/_handset.dart';

class CreateRequisitionView extends StatelessWidget {
  const CreateRequisitionView({required this.accountingEvent, super.key});

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
