import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/services/api/accounting_event_service.dart';
import 'package:leadership/shared/expenses/_handset.dart';
import 'package:leadership/shared/expenses/cubit/accounting_event_cubit.dart';
import 'package:prf_design/prf_design.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({
    required this.accountingEventUlid,
    this.showFinancialReport = false,
    super.key,
  });

  final String accountingEventUlid;
  final bool showFinancialReport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A new event gets a new cubit rather than the previous event's totals.
      key: ValueKey(accountingEventUlid),
      create: (_) =>
          AccountingEventCubit(getIt<AccountingEventService>())
            ..load(accountingEventUlid),
      child: PRFAdaptive(
        handset: (_) => ExpensesViewHandset(
          accountingEventUlid: accountingEventUlid,
          showFinancialReport: showFinancialReport,
        ),
        builder: (_, _) => ExpensesViewHandset(
          accountingEventUlid: accountingEventUlid,
          showFinancialReport: showFinancialReport,
        ),
      ),
    );
  }
}
