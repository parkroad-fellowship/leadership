import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Single entry point for error reporting. Features and services should
/// never reference `FirebaseCrashlytics` directly.
abstract class UnifiedErrorReportingService {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Object? reason,
    bool fatal = false,
    Iterable<Object>? information,
  });

  Future<void> log(String message);

  Future<void> setUserIdentifier(String identifier);

  Future<void> clearUser();

  void registerFlutterErrorHandlers();

  void registerPlatformErrorHandler();
}

class FirebaseErrorReportingService implements UnifiedErrorReportingService {
  FirebaseErrorReportingService({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Object? reason,
    bool fatal = false,
    Iterable<Object>? information,
  }) => _crashlytics.recordError(
    error,
    stackTrace,
    reason: reason,
    fatal: fatal,
    information: information ?? const Iterable.empty(),
  );

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setUserIdentifier(String identifier) =>
      _crashlytics.setUserIdentifier(identifier);

  @override
  Future<void> clearUser() => _crashlytics.setUserIdentifier('');

  @override
  void registerFlutterErrorHandlers() {
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
  }

  @override
  void registerPlatformErrorHandler() {
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
