import 'package:flutter/material.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_requisition/_handset.dart';
import 'package:prf_design/prf_design.dart';

class CreateRequisitionView extends StatelessWidget {
  const CreateRequisitionView({required this.accountingEvent, super.key});

  final PRFAccountingEvent accountingEvent;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => CreateRequisitionViewHandset(
        accountingEvent: accountingEvent,
      ),
      builder: (_, _) => CreateRequisitionViewHandset(
        accountingEvent: accountingEvent,
      ),
    );
  }
}
