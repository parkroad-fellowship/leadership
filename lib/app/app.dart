import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/cubit/theme_cubit.dart';
import 'package:leadership/l10n/gen/app_localizations.dart';
import 'package:leadership/utils/_index.dart';
import 'package:prf_design/prf_design.dart';

class PRFLeadership extends StatelessWidget {
  const PRFLeadership({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final themeMode = context.read<ThemeCubit>().currentThemeMode;
        final scaleFactor = DeviceHelper.getScaleFactor(context: context);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: PRFTheme.light(scaleFactor: scaleFactor),
          darkTheme: PRFTheme.dark(scaleFactor: scaleFactor),
          themeMode: themeMode.toFlutterThemeMode(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: getIt<PRFLeadershipRouter>().config(),
        );
      },
    );
  }
}
