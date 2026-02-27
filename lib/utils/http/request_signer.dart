import 'dart:convert';

import 'package:crypto/crypto.dart';

class RequestSigner {
  static String generateSignature({
    required String method,
    required String url,
    required String timestamp,
    required String appId,
    required String appSecret,
  }) {
    method = method.toUpperCase();
    final stringToSign = '$method|$url|$timestamp|$appId';

    final hmac = Hmac(sha256, utf8.encode(appSecret));
    final digest = hmac.convert(utf8.encode(stringToSign));
    return digest.toString();
  }

  static Map<String, String> generateHeaders({
    required String method,
    required String url,
    required String appId,
    required String appSecret,
  }) {
    final timestamp = DateTime.now()
        .toUtc()
        .millisecondsSinceEpoch
        .toString(); // Convert to seconds
    final signature = generateSignature(
      method: method,
      url: url,
      timestamp: timestamp,
      appId: appId,
      appSecret: appSecret,
    );

    return {
      'X-PRF-App-ID': appId,
      'X-PRF-Timestamp': timestamp,
      'X-PRF-Signature': signature,
    };
  }
}
