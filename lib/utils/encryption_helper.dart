const _baseDomainDefine = String.fromEnvironment(EncryptionHelper.baseDomain);
const _socketDomainDefine = String.fromEnvironment(
  EncryptionHelper.socketDomain,
);
const _socketKeyDefine = String.fromEnvironment(EncryptionHelper.socketKey);
const _azureConnStringDefine = String.fromEnvironment(
  EncryptionHelper.azureConnString,
);
const _appIdDefine = String.fromEnvironment(EncryptionHelper.appId);
const _appSecretDefine = String.fromEnvironment(EncryptionHelper.appSecret);
const _hiveEncryptionKeyDefine = String.fromEnvironment(
  EncryptionHelper.hiveEncryptionKey,
);
const _tenantUlidDefine = String.fromEnvironment(EncryptionHelper.tenantUlid);

class EncryptionHelper {
  EncryptionHelper._();

  static const baseDomain = 'BASE_DOMAIN';
  static const socketDomain = 'SOCKET_DOMAIN';
  static const socketKey = 'SOCKET_KEY';
  static const azureConnString = 'AZURE_CONN_STRING';
  static const appId = 'APP_ID';
  static const appSecret = 'APP_SECRET';
  static const hiveEncryptionKey = 'HIVE_ENCRYPTION_KEY';
  static const tenantUlid = 'TENANT_ULID';

  static const requiredProduction = <String>[
    baseDomain,
    socketDomain,
    socketKey,
    azureConnString,
    appId,
    appSecret,
    hiveEncryptionKey,
    tenantUlid,
  ];

  static String requiredDefine(String key) {
    switch (key) {
      case baseDomain:
        return _requiredConstDefine(key, _baseDomainDefine);
      case socketDomain:
        return _requiredConstDefine(key, _socketDomainDefine);
      case socketKey:
        return _requiredConstDefine(key, _socketKeyDefine);
      case azureConnString:
        return _requiredConstDefine(key, _azureConnStringDefine);
      case appId:
        return _requiredConstDefine(key, _appIdDefine);
      case appSecret:
        return _requiredConstDefine(key, _appSecretDefine);
      case hiveEncryptionKey:
        return _requiredConstDefine(key, _hiveEncryptionKeyDefine);
      case tenantUlid:
        return _requiredConstDefine(key, _tenantUlidDefine);
      default:
        throw ArgumentError('Unsupported --dart-define key: $key');
    }
  }

  static void ensureRequiredDefines(Iterable<String> keys) {
    final missingKeys = <String>[];

    for (final key in keys) {
      if (_lookupDefine(key).isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      throw StateError(
        'Missing required --dart-define keys: ${missingKeys.join(', ')}',
      );
    }
  }

  static String _requiredConstDefine(String key, String value) {
    if (value.isEmpty) {
      throw StateError('Missing required --dart-define=$key for production.');
    }
    return value;
  }

  static String _lookupDefine(String key) {
    switch (key) {
      case baseDomain:
        return _baseDomainDefine;
      case socketDomain:
        return _socketDomainDefine;
      case socketKey:
        return _socketKeyDefine;
      case azureConnString:
        return _azureConnStringDefine;
      case appId:
        return _appIdDefine;
      case appSecret:
        return _appSecretDefine;
      case hiveEncryptionKey:
        return _hiveEncryptionKeyDefine;
      case tenantUlid:
        return _tenantUlidDefine;
      default:
        throw ArgumentError('Unsupported --dart-define key: $key');
    }
  }
}
