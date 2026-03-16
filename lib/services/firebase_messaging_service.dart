// ignore_for_file: unreachable_from_main

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:leadership/enums/prf_supported_platform.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';

/// Top-level function required for FCM background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  Logger().i('Handling background FCM message: ${message.messageId}');
  await FirebaseMessagingService.handleFCMMessage(message);
}

abstract class FirebaseMessagingService {
  Future<void> init();
  Future<void> subscribeToTopics();
  Future<String> retrieveFCMToken();

  /// Convert FCM message to AwesomeNotification
  static Future<void> handleFCMMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    Logger().i('Received FCM message: ${message.messageId}');
    Logger().d('Notification: ${notification?.title}');
    Logger().d('Data payload: $data');

    // Only process notifications explicitly targeted at this app
    final targetApp = data['target_app'] as String?;
    if (targetApp != 'leadership_app') {
      Logger().d('Ignoring FCM message: target_app=$targetApp');
      return;
    }

    if (notification == null) {
      Logger().w('FCM message has no notification body');
      return;
    }

    Logger().i('Creating AwesomeNotification from FCM: ${notification.title}');

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(2147483647),
          channelKey: 'requisitions',
          title: notification.title,
          body: notification.body,
          payload: data.map((key, value) => MapEntry(key, value.toString())),
          wakeUpScreen: true,
        ),
      );
      Logger().i('AwesomeNotification created successfully');
    } catch (e) {
      Logger().e('Failed to create AwesomeNotification: $e');
    }
  }
}

class FirebaseMessagingServiceImpl implements FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Future<void> init() async {
    try {
      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      Logger().i('FCM background handler registered');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        Logger().i('Received foreground FCM message: ${message.messageId}');
        FirebaseMessagingService.handleFCMMessage(message);
      });

      // Handle notification taps when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        Logger().i('Notification opened app from background');
        Logger().d('Message data: ${message.data}');
        // AwesomeNotifications will handle the tap action
      });

      // Check if app was opened from a terminated state via notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        Logger().i('App opened from terminated state via notification');
        Logger().d('Initial message: ${initialMessage.data}');
        // Handle initial message if needed
      }

      await subscribeToTopics();

      Logger().i('Firebase Messaging initialized successfully');
    } catch (e) {
      Logger().e('Failed to initialize Firebase Messaging: $e');
      rethrow;
    }
  }

  @override
  Future<void> subscribeToTopics() async {
    try {
      final prefix = PRFLeadershipConfig.instance!.values.environment;

      final topics = ['${prefix.name}_leadership_app'];
      for (final topic in topics) {
        try {
          await _firebaseMessaging.subscribeToTopic(topic);
          Logger().i('Subscribed to topic: $topic');
        } catch (error) {
          Logger().e('Error subscribing to topic $topic: $error');
          rethrow;
        }
      }
    } catch (e) {
      Logger().e('Failed to subscribe to topics: $e');
      rethrow;
    }
  }

  @override
  Future<String> retrieveFCMToken() async {
    try {
      final platform = await Misc.getCurrentPlatform();
      Logger().i('Platform: $platform');

      final hive = getIt<HiveService>().settings;
      final notificationsEnabled = hive.areNotificationsEnabled();
      final hasBeenRequested = hive.hasPermissionBeenRequested();

      if (!notificationsEnabled || !hasBeenRequested) {
        Logger().i(
          'Notifications not enabled/requested; skipping iOS permission prompt',
        );
        return '';
      }

      final currentSettings = await _firebaseMessaging
          .getNotificationSettings();
      final authorized =
          currentSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          currentSettings.authorizationStatus ==
              AuthorizationStatus.provisional;
      Logger().i(
        'Notification permission status:'
        ' ${currentSettings.authorizationStatus}',
      );

      if (!authorized) {
        Logger().w(
          'Notification permissions not granted; returning empty token',
        );
        return '';
      }

      if (platform == PRFSupportedPlatform.ios) {
        String? apnsToken;
        for (var i = 0; i < 3; i++) {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          Logger().d('APNS Token (attempt ${i + 1}): $apnsToken');
          if (apnsToken != null) break;
          await Future<dynamic>.delayed(const Duration(seconds: 2));
        }
        if (apnsToken == null) {
          Logger().w(
            'APNS token not available yet; continuing to fetch FCM token',
          );
        }
      }

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        Logger().i('FCM Token: $token');
        return token;
      } else {
        throw Exception('Failed to retrieve FCM token');
      }
    } catch (error) {
      Logger().e('Error retrieving FCM token: $error');
      throw Failure(message: error.toString());
    }
  }
}
