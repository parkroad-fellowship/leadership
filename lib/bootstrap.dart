import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leadership/firebase_options.dart';
import 'package:leadership/models/remote/auth.dart';
import 'package:leadership/models/remote/socket_config.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/firebase_service.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/http/request_signer.dart';
import 'package:leadership/utils/multiplatform/url_strategy/url_strategy_app.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  try {
    Bloc.observer = const AppBlocObserver();

    tz_data.initializeTimeZones();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Ensure timezone data is loaded
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));

    // Report errors to Crashlytics in release mode only
    if (kReleaseMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    Singletons.setup();
    await Singletons.setupDatabases();

    await RequestSigner.syncWithServer(
      PRFLeadershipConfig.instance!.values.baseUrl,
    );

    try {
      await getIt<FirebaseService>().initRemoteConfig();
    } catch (e) {
      Logger().e(e);
    }

    final user = getIt<HiveService>().auth.retrieveProfile();

    if (user != null) {
      final defaultConfig = getIt<SocketService>().defaultConfig();

      try {
        await getIt<SocketService>().init(
          socketConfig: SocketConfig(
            privateChannels: defaultConfig.privateChannels,
            presenceChannels: defaultConfig.presenceChannels,
          ),
        );
      } catch (e) {
        Logger().e('SocketService init error: $e');
      }

      try {
        final fcmToken = await getIt<FirebaseMessagingService>()
            .retrieveFCMToken();
        if (fcmToken.isNotEmpty) {
          await getIt<AuthService>().updateProfile(
            updateDTO: UserUpdateDTO(
              fcmTokens: [fcmToken],
            ),
          );
        }
      } catch (e) {
        Logger().e('Firebase Messaging init error: $e');
      }
    }

    // Check if the platform is web and update the URLPath Strategy
    if (kIsWeb) {
      updatePathStrategy();
    }

    runApp(await builder());
  } catch (error, stackTrace) {
    log(error.toString(), stackTrace: stackTrace);
  }
}
