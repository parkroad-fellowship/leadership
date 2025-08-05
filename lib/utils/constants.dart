class PRFLeadershipValues {
  PRFLeadershipValues({
    required this.urlScheme,
    required this.baseDomain,
    required this.hiveBox,
    required this.socketDomain,
    required this.socketKey,
    required this.socketScheme,
    required this.socketPort,
    required this.azureConnString,
  });

  final String urlScheme;
  final String baseDomain;
  final String hiveBox;
  final String socketDomain;
  final String socketKey;
  final String socketScheme;
  final int socketPort;
  final String azureConnString;

  String get baseUrl => '$urlScheme://$baseDomain';
  String get globalHiveAuthBox => 'prf-super-app-auth-';
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
