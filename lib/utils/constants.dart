import 'package:leadership/enums/prf_environment.dart';

class PRFLeadershipValues {
  PRFLeadershipValues({
    required this.environment,
    required this.urlScheme,
    required this.baseDomain,
    required this.hiveBox,
    required this.socketDomain,
    required this.socketKey,
    required this.socketScheme,
    required this.socketPort,
    required this.azureConnString,
    required this.appId,
    required this.appSecret,
    this.hiveEncryptionKey = '',
  });

  final PRFEnvironment environment;
  final String urlScheme;
  final String baseDomain;
  final String hiveBox;
  final String socketDomain;
  final String socketKey;
  final String socketScheme;
  final int socketPort;
  final String azureConnString;
  final String appId;
  final String appSecret;
  final String hiveEncryptionKey;

  String get baseUrl => '$urlScheme://$baseDomain';
  String get globalHiveAuthBox => 'prf-super-app-auth-v2';
}

class PRFLeadershipConfig {
  factory PRFLeadershipConfig({required PRFLeadershipValues values}) {
    return _instance ??= PRFLeadershipConfig._internal(values);
  }

  PRFLeadershipConfig._internal(this.values);

  final PRFLeadershipValues values;
  static PRFLeadershipConfig? _instance;

  static PRFLeadershipConfig? get instance => _instance;
}
