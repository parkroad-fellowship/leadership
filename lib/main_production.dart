import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/app/app.dart';
import 'package:leadership/bootstrap.dart';
import 'package:leadership/di/di_container.dart';
import 'package:leadership/enums/prf_environment.dart';
import 'package:leadership/utils/constants.dart';
import 'package:leadership/utils/encryption_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EncryptionHelper.ensureRequiredDefines(EncryptionHelper.requiredProduction);

  PRFLeadershipConfig(
    values: PRFLeadershipValues(
      environment: PRFEnvironment.production,
      hiveBox: 'prf-leadership-v2',
      baseDomain: EncryptionHelper.requiredDefine(EncryptionHelper.baseDomain),
      urlScheme: 'https',
      socketDomain: EncryptionHelper.requiredDefine(
        EncryptionHelper.socketDomain,
      ),
      socketKey: EncryptionHelper.requiredDefine(EncryptionHelper.socketKey),
      socketScheme: 'wss',
      socketPort: 443,
      azureConnString: EncryptionHelper.requiredDefine(
        EncryptionHelper.azureConnString,
      ),
      appId: EncryptionHelper.requiredDefine(EncryptionHelper.appId),
      appSecret: EncryptionHelper.requiredDefine(EncryptionHelper.appSecret),
      hiveEncryptionKey: EncryptionHelper.requiredDefine(
        EncryptionHelper.hiveEncryptionKey,
      ),
      tenantUlid: EncryptionHelper.requiredDefine(EncryptionHelper.tenantUlid),
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) async => bootstrap(
      () => MultiBlocProvider(
        providers: DIContainer.registerCubits(),
        child: const PRFLeadership(),
      ),
    ),
  );
}
