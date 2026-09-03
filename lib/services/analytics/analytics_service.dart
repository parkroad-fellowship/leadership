import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Abstraction over analytics so features never touch
/// `FirebaseAnalytics` directly.
abstract class AnalyticsService {
  Future<void> logAppOpen();

  Future<void> logScreenView({required String screenName});

  Future<void> logEvent(String name, {Map<String, Object>? parameters});

  Future<void> setUserProperty({required String name, String? value});

  Future<void> setUserId(String? userId);
}

class FirebaseAnalyticsServiceImpl implements AnalyticsService {
  FirebaseAnalyticsServiceImpl({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logAppOpen() => _analytics.logAppOpen();

  @override
  Future<void> logScreenView({required String screenName}) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty({required String name, String? value}) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);
}

/// No-op implementation used in debug runs so local development
/// does not pollute production analytics.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logAppOpen() async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    debugPrint('[analytics] $name ${parameters ?? const {}}}');
  }

  @override
  Future<void> setUserProperty({required String name, String? value}) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
