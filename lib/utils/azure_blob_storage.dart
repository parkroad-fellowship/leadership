// Modified from: https://github.com/kkazuo/dart-azblob/blob/main/lib/src/azblob_base.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

/// Blob type
enum BlobType {
  blockBlob('BlockBlob'),
  appendBlob('AppendBlob'),
  pageBlob('PageBlob');

  const BlobType(this.displayName);

  final String displayName;
}

/// Blob access tier for block blobs
enum AccessTier {
  hot('Hot'),
  cool('Cool'),
  archive('Archive');

  const AccessTier(this.value);

  final String value;
}

/// Blob properties returned from list operations
class BlobProperties {
  const BlobProperties({
    required this.name,
    required this.lastModified,
    required this.etag,
    required this.contentLength,
    this.contentType,
    this.blobType,
    this.accessTier,
    this.metadata = const {},
  });

  final String name;
  final DateTime lastModified;
  final String etag;
  final int contentLength;
  final String? contentType;
  final BlobType? blobType;
  final AccessTier? accessTier;
  final Map<String, String> metadata;

  @override
  String toString() => 'BlobProperties(name: $name, size: $contentLength)';
}

/// Container properties
class ContainerProperties {
  const ContainerProperties({
    required this.name,
    required this.lastModified,
    required this.etag,
    this.metadata = const {},
  });

  final String name;
  final DateTime lastModified;
  final String etag;
  final Map<String, String> metadata;

  @override
  String toString() => 'ContainerProperties(name: $name)';
}

/// Azure Storage Exception
class AzureStorageException implements Exception {
  AzureStorageException(this.message, this.statusCode, this.headers);
  final String message;
  final int statusCode;
  final Map<String, String> headers;

  @override
  String toString() => 'AzureStorageException: $message (Status: $statusCode)';
}

/// Azure Storage Client
class AzureStorage {
  /// Initialize with account name and key directly
  AzureStorage({
    required String accountName,
    required String accountKey,
    String endpointSuffix = 'core.windows.net',
    String protocol = 'https',
  }) {
    config = {
      AzureStorage.accountName: accountName,
      AzureStorage.accountKey: accountKey,
      AzureStorage.endpointSuffix: endpointSuffix,
      AzureStorage.defaultEndpointsProtocol: protocol,
    };
    encodedAccountKey = base64Decode(accountKey);
  }

  /// Initialize with connection string.
  AzureStorage.parse(String connectionString) {
    try {
      final m = <String, String>{};
      final items = connectionString.split(';');
      for (final item in items) {
        if (item.isEmpty) continue;
        final i = item.indexOf('=');
        if (i == -1) continue;
        final key = item.substring(0, i);
        final val = item.substring(i + 1);
        m[key] = val;
      }
      config = m;

      final accountKeyValue = config[accountKey];
      if (accountKeyValue == null || accountKeyValue.isEmpty) {
        throw Exception('AccountKey is required in connection string');
      }

      encodedAccountKey = base64Decode(accountKeyValue);
    } catch (e) {
      throw Exception('Parse error: $e');
    }
  }

  late Map<String, String> config;
  late Uint8List encodedAccountKey;

  static const String defaultEndpointsProtocol = 'DefaultEndpointsProtocol';
  static const String endpointSuffix = 'EndpointSuffix';
  static const String accountName = 'AccountName';
  static const String accountKey = 'AccountKey';

  /// Get account name
  String get storageAccountName => config[accountName] ?? '';

  @override
  String toString() {
    final sanitized = Map<String, String>.from(config);
    sanitized[accountKey] = '***';
    return sanitized.toString();
  }

  Uri uri({String path = '/', Map<String, String>? queryParameters}) {
    final blobEndpoint = config['BlobEndpoint'];
    if (blobEndpoint != null) {
      // Parse from explicit endpoint (like Azurite's BlobEndpoint)
      final base = Uri.parse(blobEndpoint);
      return base.replace(
        path: '${base.path}$path',
        queryParameters: queryParameters,
      );
    }

    final scheme = config[defaultEndpointsProtocol] ?? 'https';
    final suffix = config[endpointSuffix] ?? 'core.windows.net';
    final name = config[accountName];
    return Uri(
      scheme: scheme,
      host: '$name.blob.$suffix',
      path: path,
      queryParameters: queryParameters,
    );
  }

  String _canonicalHeaders(Map<String, String> headers) {
    final keys =
        headers.keys
            .where((i) => i.toLowerCase().startsWith('x-ms-'))
            .map((i) => '${i.toLowerCase()}:${headers[i]?.trim()}\n')
            .toList()
          ..sort();
    return keys.join();
  }

  String _canonicalResources(Map<String, String> items) {
    if (items.isEmpty) {
      return '';
    }
    final keys = items.keys.toList()..sort();
    return keys.map((i) => '\n${i.toLowerCase()}:${items[i]}').join();
  }

  void sign(http.Request request) {
    request.headers['x-ms-date'] = http_parser.formatHttpDate(DateTime.now());
    request.headers['x-ms-version'] = '2021-08-06';
    final ce = request.headers['Content-Encoding'] ?? '';
    final cl = request.headers['Content-Language'] ?? '';
    final cz = request.contentLength == 0 ? '' : '${request.contentLength}';
    final cm = request.headers['Content-MD5'] ?? '';
    final ct = request.headers['Content-Type'] ?? '';
    final dt = request.headers['Date'] ?? '';
    final ims = request.headers['If-Modified-Since'] ?? '';
    final imt = request.headers['If-Match'] ?? '';
    final inm = request.headers['If-None-Match'] ?? '';
    final ius = request.headers['If-Unmodified-Since'] ?? '';
    final ran = request.headers['Range'] ?? '';
    final chs = _canonicalHeaders(request.headers);
    final crs = _canonicalResources(request.url.queryParameters);
    final name = config[accountName];
    final path = request.url.path;
    final sig =
        '${request.method}\n$ce\n$cl\n$cz\n$cm\n$ct\n$dt\n$ims\n$imt\n$inm\n$ius\n$ran\n$chs/$name$path$crs';
    final mac = crypto.Hmac(crypto.sha256, encodedAccountKey);
    final digest = base64Encode(mac.convert(utf8.encode(sig)).bytes);
    final auth = 'SharedKey $name:$digest';
    request.headers['Authorization'] = auth;
  }

  String _signedExpiry(DateTime? expiry) {
    final str = (expiry ?? DateTime.now().add(const Duration(hours: 1)))
        .toUtc()
        .toIso8601String();
    return '${str.substring(0, str.indexOf('.'))}Z';
  }

  /// Get Blob Link with enhanced options.
  Future<Uri> getBlobLink(
    String path, {
    DateTime? expiry,
    String permissions = 'r',
    String? contentType,
    String? contentDisposition,
  }) async {
    const signedStart = '';
    final signedExpiry = _signedExpiry(expiry);
    const signedIdentifier = '';
    const signedVersion = '2021-08-06';
    final name = config[accountName];
    final canonicalizedResource = '/$name$path';
    final str =
        '$permissions\n'
        '$signedStart\n'
        '$signedExpiry\n'
        '$canonicalizedResource\n'
        '$signedIdentifier\n'
        '$signedVersion';
    final mac = crypto.Hmac(crypto.sha256, encodedAccountKey);
    final sig = base64Encode(mac.convert(utf8.encode(str)).bytes);

    final queryParams = {
      'sr': 'b',
      'sp': permissions,
      'se': signedExpiry,
      'sv': signedVersion,
      'spr': 'https',
      'sig': sig,
    };

    if (contentType != null) queryParams['rsct'] = contentType;
    if (contentDisposition != null) queryParams['rscd'] = contentDisposition;

    return uri(path: path, queryParameters: queryParams);
  }

  /// Create container
  Future<void> createContainer(
    String containerName, {
    Map<String, String>? metadata,
  }) async {
    final request = http.Request(
      'PUT',
      uri(path: '/$containerName', queryParameters: {'restype': 'container'}),
    );

    if (metadata != null) {
      metadata.forEach((key, value) {
        request.headers['x-ms-meta-$key'] = value;
      });
    }

    sign(request);
    final res = await request.send();

    if (res.statusCode == 201) {
      await res.stream.drain<dynamic>();
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Delete container
  Future<void> deleteContainer(String containerName) async {
    final request = http.Request(
      'DELETE',
      uri(path: '/$containerName', queryParameters: {'restype': 'container'}),
    );

    sign(request);
    final res = await request.send();

    if (res.statusCode == 202) {
      await res.stream.drain<dynamic>();
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// List containers
  Future<List<ContainerProperties>> listContainers({
    String? prefix,
    int? maxResults,
    String? marker,
  }) async {
    final queryParams = <String, String>{'comp': 'list'};
    if (prefix != null) queryParams['prefix'] = prefix;
    if (maxResults != null) queryParams['maxresults'] = maxResults.toString();
    if (marker != null) queryParams['marker'] = marker;

    final request = http.Request('GET', uri(queryParameters: queryParams));
    sign(request);
    final res = await request.send();

    if (res.statusCode == 200) {
      final xml = await res.stream.bytesToString();
      return _parseContainerList(xml);
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// List blobs in container
  Future<List<BlobProperties>> listBlobs(
    String containerName, {
    String? prefix,
    int? maxResults,
    String? marker,
  }) async {
    final queryParams = <String, String>{
      'restype': 'container',
      'comp': 'list',
    };
    if (prefix != null) queryParams['prefix'] = prefix;
    if (maxResults != null) queryParams['maxresults'] = maxResults.toString();
    if (marker != null) queryParams['marker'] = marker;

    final request = http.Request(
      'GET',
      uri(path: '/$containerName', queryParameters: queryParams),
    );
    sign(request);
    final res = await request.send();

    if (res.statusCode == 200) {
      final xml = await res.stream.bytesToString();
      return _parseBlobList(xml);
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Get blob metadata and properties
  Future<BlobProperties> getBlobProperties(String path) async {
    final request = http.Request('HEAD', uri(path: path));
    sign(request);
    final res = await request.send();

    if (res.statusCode == 200) {
      await res.stream.drain<dynamic>();
      return _parseBlobPropertiesFromHeaders(path, res.headers);
    }

    final message = res.statusCode == 404 ? 'Blob not found' : 'Request failed';
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Download blob content
  Future<Uint8List> downloadBlob(String path) async {
    final request = http.Request('GET', uri(path: path));
    sign(request);
    final res = await request.send();

    if (res.statusCode == 200) {
      return res.stream.toBytes();
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Delete blob
  Future<void> deleteBlob(String path) async {
    final request = http.Request('DELETE', uri(path: path));
    sign(request);
    final res = await request.send();

    if (res.statusCode == 202) {
      await res.stream.drain<dynamic>();
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Set blob access tier (for block blobs)
  Future<void> setBlobTier(String path, AccessTier tier) async {
    final request = http.Request(
      'PUT',
      uri(path: path, queryParameters: {'comp': 'tier'}),
    );
    request.headers['x-ms-access-tier'] = tier.value;
    sign(request);
    final res = await request.send();

    if (res.statusCode == 200 || res.statusCode == 202) {
      await res.stream.drain<dynamic>();
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Put Blob with enhanced options.
  Future<void> putBlob(
    String path, {
    String? body,
    Uint8List? bodyBytes,
    String? contentType,
    BlobType type = BlobType.blockBlob,
    Map<String, String>? headers,
    AccessTier? accessTier,
  }) async {
    final request = http.Request('PUT', uri(path: path));
    request.headers['x-ms-blob-type'] = type.displayName;

    if (headers != null) {
      headers.forEach((key, value) {
        request.headers['x-ms-meta-$key'] = value;
      });
    }

    if (contentType != null) request.headers['content-type'] = contentType;
    if (accessTier != null && type == BlobType.blockBlob) {
      request.headers['x-ms-access-tier'] = accessTier.value;
    }

    if (type == BlobType.blockBlob) {
      if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      } else if (body != null) {
        request.body = body;
      }
    } else {
      request.body = '';
    }

    sign(request);
    final res = await request.send();

    if (res.statusCode == 201) {
      await res.stream.drain<dynamic>();
      if (type == BlobType.appendBlob && (body != null || bodyBytes != null)) {
        await _appendBlock(path, body: body, bodyBytes: bodyBytes);
      }
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  /// Append block to blob.
  Future<void> _appendBlock(
    String path, {
    String? body,
    Uint8List? bodyBytes,
  }) async {
    final request = http.Request(
      'PUT',
      uri(path: path, queryParameters: {'comp': 'appendblock'}),
    );
    if (bodyBytes != null) {
      request.bodyBytes = bodyBytes;
    } else if (body != null) {
      request.body = body;
    }
    sign(request);
    final res = await request.send();
    if (res.statusCode == 201) {
      await res.stream.drain<dynamic>();
      return;
    }

    final message = await res.stream.bytesToString();
    throw AzureStorageException(message, res.statusCode, res.headers);
  }

  // Helper methods for parsing XML responses
  List<ContainerProperties> _parseContainerList(String xml) {
    // Simple XML parsing - in production, consider using xml package
    final containers = <ContainerProperties>[];
    final containerRegex = RegExp('<Container>.*?</Container>', dotAll: true);
    final nameRegex = RegExp('<Name>(.*?)</Name>');
    final lastModifiedRegex = RegExp('<Last-Modified>(.*?)</Last-Modified>');
    final etagRegex = RegExp('<Etag>(.*?)</Etag>');

    for (final match in containerRegex.allMatches(xml)) {
      final containerXml = match.group(0)!;
      final name = nameRegex.firstMatch(containerXml)?.group(1) ?? '';
      final lastModifiedStr =
          lastModifiedRegex.firstMatch(containerXml)?.group(1) ?? '';
      final etag = etagRegex.firstMatch(containerXml)?.group(1) ?? '';

      final lastModified = DateTime.tryParse(lastModifiedStr) ?? DateTime.now();

      containers.add(
        ContainerProperties(
          name: name,
          lastModified: lastModified,
          etag: etag,
        ),
      );
    }

    return containers;
  }

  List<BlobProperties> _parseBlobList(String xml) {
    // Simple XML parsing - in production, consider using xml package
    final blobs = <BlobProperties>[];
    final blobRegex = RegExp('<Blob>.*?</Blob>', dotAll: true);
    final nameRegex = RegExp('<Name>(.*?)</Name>');
    final lastModifiedRegex = RegExp('<Last-Modified>(.*?)</Last-Modified>');
    final etagRegex = RegExp('<Etag>(.*?)</Etag>');
    final sizeRegex = RegExp(r'<Content-Length>(\d+)</Content-Length>');
    final contentTypeRegex = RegExp('<Content-Type>(.*?)</Content-Type>');

    for (final match in blobRegex.allMatches(xml)) {
      final blobXml = match.group(0)!;
      final name = nameRegex.firstMatch(blobXml)?.group(1) ?? '';
      final lastModifiedStr =
          lastModifiedRegex.firstMatch(blobXml)?.group(1) ?? '';
      final etag = etagRegex.firstMatch(blobXml)?.group(1) ?? '';
      final sizeStr = sizeRegex.firstMatch(blobXml)?.group(1) ?? '0';
      final contentType = contentTypeRegex.firstMatch(blobXml)?.group(1);

      final lastModified = DateTime.tryParse(lastModifiedStr) ?? DateTime.now();
      final size = int.tryParse(sizeStr) ?? 0;

      blobs.add(
        BlobProperties(
          name: name,
          lastModified: lastModified,
          etag: etag,
          contentLength: size,
          contentType: contentType,
        ),
      );
    }

    return blobs;
  }

  BlobProperties _parseBlobPropertiesFromHeaders(
    String name,
    Map<String, String> headers,
  ) {
    final lastModifiedStr = headers['last-modified'] ?? '';
    final etag = headers['etag'] ?? '';
    final contentLengthStr = headers['content-length'] ?? '0';
    final contentType = headers['content-type'];

    final lastModified = DateTime.tryParse(lastModifiedStr) ?? DateTime.now();
    final contentLength = int.tryParse(contentLengthStr) ?? 0;

    // Extract metadata
    final metadata = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase().startsWith('x-ms-meta-')) {
        final metaKey = key.substring('x-ms-meta-'.length);
        metadata[metaKey] = value;
      }
    });

    return BlobProperties(
      name: name,
      lastModified: lastModified,
      etag: etag,
      contentLength: contentLength,
      contentType: contentType,
      metadata: metadata,
    );
  }
}
