import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/expenses/_handset.dart';

@RoutePage()
class AccountingEventExpensesView extends StatelessWidget {
  const AccountingEventExpensesView({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => AccountingEventExpensesViewHandset(
        accountingEventUlid: accountingEventUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => AccountingEventExpensesViewHandset(
          accountingEventUlid: accountingEventUlid,
        ),
      ),
    );
  }
}
