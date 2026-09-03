import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:leadership/services/analytics/analytics_service.dart';
import 'package:leadership/services/errors/unified_error_reporting_service.dart';
import 'package:leadership/services/firebase_messaging_service.dart';
import 'package:leadership/services/firebase_service.dart';

class FirebaseModule {
  static void register(GetIt getIt) {
    getIt
      ..registerSingleton<PRFFirebaseService>(FirebaseServiceImpl())
      ..registerSingleton<FirebaseMessagingService>(
        FirebaseMessagingServiceImpl(),
      )
      ..registerSingleton<AnalyticsService>(
        kDebugMode ? NoOpAnalyticsService() : FirebaseAnalyticsServiceImpl(),
      )
      ..registerSingleton<UnifiedErrorReportingService>(
        FirebaseErrorReportingService(),
      );
  }
}
