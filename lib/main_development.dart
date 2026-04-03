import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/app/app.dart';
import 'package:leadership/bootstrap.dart';
import 'package:leadership/enums/prf_environment.dart';
import 'package:leadership/utils/_index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PRFLeadershipConfig(
    values: PRFLeadershipValues(
      environment: PRFEnvironment.development,
      hiveBox: 'prf-leadership-dev',
      baseDomain: 'dev-api.parkroadfellowship.org',
      urlScheme: 'https',
      socketDomain: 'dev-ws.parkroadfellowship.org',
      socketKey: 'yvnlkaqadqiadutrs9sa',
      socketScheme: 'wss',
      socketPort: 443,
      azureConnString:
          'DefaultEndpointsProtocol=https;AccountName=prfcorestorage;AccountKey=oizfzMYG6gsjQWTfix8V/50Jh40qCg93DzNiFok/DxJjDOhffzM0TA4TNOV4TYqU1QONfaQOrrs7+ASteXMXPA==;EndpointSuffix=core.windows.net',
      appId: 'prf_leadership_01khyfcbxn1mrwvg1yte0e7hq0',
      appSecret:
          'BqXB5apC9dXm5PyLhmFeD9Q8seKdDxGYljqDXisW0sX8m83QnBA2IUv1ygJ10cKM',
      hiveEncryptionKey: 'random_dev',
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
