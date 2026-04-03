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
      environment: PRFEnvironment.production,
      hiveBox: 'prf-leadership-v2',
      baseDomain: Misc.requiredDefine('BASE_DOMAIN'),
      urlScheme: 'https',
      socketDomain: Misc.requiredDefine('SOCKET_DOMAIN'),
      socketKey: Misc.requiredDefine('SOCKET_KEY'),
      socketScheme: 'wss',
      socketPort: 443,
      azureConnString: Misc.requiredDefine('AZURE_CONN_STRING'),
      appId: Misc.requiredDefine('APP_ID'),
      appSecret: Misc.requiredDefine('APP_SECRET'),
      hiveEncryptionKey: Misc.requiredDefine('HIVE_ENCRYPTION_KEY'),
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
