import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/app/app.dart';
import 'package:leadership/bootstrap.dart';
import 'package:leadership/utils/_index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PRFLeadershipConfig(
    values: PRFLeadershipValues(
      hiveBox: 'dev-prf-leadership-${Misc.getSluggedAppVersion()}',
      baseDomain: 'prf-sockets.test',
      urlScheme: 'http',
      socketDomain: 'prf-sockets.test',
      socketKey: 'yvnlkaqadqiadutrs9sa',
      socketScheme: 'ws',
      socketPort: 9000,
      azureConnString:
          'DefaultEndpointsProtocol=https;AccountName=prfcorestorage;AccountKey=oizfzMYG6gsjQWTfix8V/50Jh40qCg93DzNiFok/DxJjDOhffzM0TA4TNOV4TYqU1QONfaQOrrs7+ASteXMXPA==;EndpointSuffix=core.windows.net',
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) async => bootstrap(
      () => MultiBlocProvider(
        providers: Singletons.registerCubits(),
        child: const PRFLeadership(),
      ),
    ),
  );
}
