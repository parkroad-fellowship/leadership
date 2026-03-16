import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class RequestSigner {
  /// Offset in milliseconds between server time and device time.
  /// Positive = server is ahead, negative = server is behind.
  static int _serverOffset = 0;

  /// Fetches the server time and computes the offset from device time.
  /// Falls back to zero offset if the call fails.
  static Future<void> syncWithServer(String baseUrl) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final deviceTimeBefore = DateTime.now().millisecondsSinceEpoch;
      final response = await dio.get<Map<String, dynamic>>(
        '$baseUrl/api/v1/server-time',
      );
      final deviceTimeAfter = DateTime.now().millisecondsSinceEpoch;

      final serverTimestamp = response.data?['timestamp'] as int?;
      if (serverTimestamp != null) {
        // Use midpoint of request to account for network latency
        final deviceMidpoint = (deviceTimeBefore + deviceTimeAfter) ~/ 2;
        _serverOffset = serverTimestamp - deviceMidpoint;
      }
    } catch (e) {
      Logger().w('Server time sync failed, using device time: $e');
    }
  }

  /// Returns the current time in milliseconds, adjusted by the server offset.
  static int _now() =>
      DateTime.now().toUtc().millisecondsSinceEpoch + _serverOffset;

  static String _generateSignature({
    required String method,
    required String url,
    required String timestamp,
    required String appId,
    required String appSecret,
  }) {
    final stringToSign = '${method.toUpperCase()}|$url|$timestamp|$appId';

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
    final timestamp = _now().toString(); // Convert to seconds
    final signature = _generateSignature(
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
