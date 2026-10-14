import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount < retries && _shouldRetry(err)) {
      requestOptions.extra['retry_count'] = retryCount + 1;

      final delay = retryDelays.length > retryCount
          ? retryDelays[retryCount]
          : retryDelays.last;

      await Future<void>.delayed(delay);

      try {
        final response = await dio.fetch<dynamic>(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        } else {
          return handler.next(
            DioException(requestOptions: requestOptions, error: e),
          );
        }
      }
    }

    return handler.next(err);
  }

  static const _idempotent = {'GET', 'HEAD', 'OPTIONS'};

  /// Only idempotent reads are retried: replaying a POST after a timeout can
  /// create the record twice.
  bool _shouldRetry(DioException err) {
    if (!_idempotent.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            const [500, 502, 503, 504].contains(err.response!.statusCode));
  }
}
