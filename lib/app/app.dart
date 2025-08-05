import 'package:flutter/material.dart';
import 'package:leadership/l10n/gen/app_localizations.dart';
import 'package:leadership/utils/_index.dart';

class PRFLeadership extends StatefulWidget {
  const PRFLeadership({super.key});

  @override
  State<PRFLeadership> createState() => _PRFLeadershipState();
}

class _PRFLeadershipState extends State<PRFLeadership> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: PRFTheme.light(context),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: getIt<PRFLeadershipRouter>().config(),
    );
  }
}
