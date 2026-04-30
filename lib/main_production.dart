import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/app/app.dart';
import 'package:leadership/bootstrap.dart';
import 'package:leadership/enums/prf_environment.dart';
import 'package:leadership/utils/_index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Misc.ensureRequiredDefines(DefineKeys.requiredProduction);

  PRFLeadershipConfig(
    values: PRFLeadershipValues(
      environment: PRFEnvironment.production,
      hiveBox: 'prf-leadership-v2',
      baseDomain: Misc.requiredDefine(DefineKeys.baseDomain),
      urlScheme: 'https',
      socketDomain: Misc.requiredDefine(DefineKeys.socketDomain),
      socketKey: Misc.requiredDefine(DefineKeys.socketKey),
      socketScheme: 'wss',
      socketPort: 443,
      azureConnString: Misc.requiredDefine(DefineKeys.azureConnString),
      appId: Misc.requiredDefine(DefineKeys.appId),
      appSecret: Misc.requiredDefine(DefineKeys.appSecret),
      hiveEncryptionKey: Misc.requiredDefine(DefineKeys.hiveEncryptionKey),
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
