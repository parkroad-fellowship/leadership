import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:leadership/shared_views/requisitions/_handset.dart';

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
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => RequisitionsViewHandset(
        event: event,
        accountingEvent: accountingEvent,
      ),
    );
  }
}
