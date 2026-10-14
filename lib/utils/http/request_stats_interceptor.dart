import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only counter of API requests per "METHOD /path". Compare request
/// volume before and after a change: call `RequestStatsInterceptor.instance
/// .reset()`, perform a flow, then print `.report()` from the debug console.
class RequestStatsInterceptor extends Interceptor {
  RequestStatsInterceptor._();

  static final RequestStatsInterceptor instance = RequestStatsInterceptor._();

  final Map<String, int> _counts = {};

  Map<String, int> get counts => Map.unmodifiable(_counts);
  int get total => _counts.values.fold(0, (a, b) => a + b);

  void reset() => _counts.clear();

  String report() {
    final rows = _counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      'API requests: $total',
      for (final r in rows) '  ${r.value.toString().padLeft(4)}  ${r.key}',
    ].join('\n');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = '${options.method} ${Uri.parse(options.path).path}';
    _counts[key] = (_counts[key] ?? 0) + 1;
    debugPrint('[api #$total] $key ${options.uri.query}');
    handler.next(options);
  }
}
