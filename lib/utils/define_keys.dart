class DefineKeys {
  const DefineKeys._();

  static const baseDomain = 'BASE_DOMAIN';
  static const socketDomain = 'SOCKET_DOMAIN';
  static const socketKey = 'SOCKET_KEY';
  static const azureConnString = 'AZURE_CONN_STRING';
  static const appId = 'APP_ID';
  static const appSecret = 'APP_SECRET';
  static const hiveEncryptionKey = 'HIVE_ENCRYPTION_KEY';

  static const requiredProduction = <String>[
    baseDomain,
    socketDomain,
    socketKey,
    azureConnString,
    appId,
    appSecret,
    hiveEncryptionKey,
  ];
}
