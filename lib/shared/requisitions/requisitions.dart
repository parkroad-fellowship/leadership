import 'package:flutter/material.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared/requisitions/_handset.dart';
import 'package:prf_design/prf_design.dart';

class RequisitionsView extends StatelessWidget {
  const RequisitionsView({
    required this.accountingEvent,
    this.event,
    super.key,
  });

  final PRFAccountingEvent accountingEvent;
  final PRFEvent? event;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => RequisitionsViewHandset(
        event: event,
        accountingEvent: accountingEvent,
      ),
      builder: (_, _) => RequisitionsViewHandset(
        event: event,
        accountingEvent: accountingEvent,
      ),
    );
  }
}
