import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_notification_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> init();

  Future<void> requestPermissions();

  void createNotification({required NotificationContent content});

  Future<void> scheduleGivingNotification();
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Logger().d(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Logger().d(receivedNotification);
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Logger().d(receivedAction);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    Logger().f(receivedAction);

    final payload = receivedAction.payload;
    final context = getIt<PRFLeadershipRouter>().navigatorKey.currentContext;

    if (payload == null) {
      Logger().w('Notification payload is null');
    }

    if (context == null) {
      Logger().w('No context available for notification action');
      return;
    }

    if (payload != null && payload['type'] == null) {
      Logger().w('Notification payload type is null');
      return;
    }

    if (payload != null) {
      switch (PRFNotificationType.fromType(payload['type']!)) {
        case PRFNotificationType.defaultPrompt:
          Logger().i('Default prompt received');
          return;
      }
    }
  }
}

class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> init() async {
    final notificationsEnabled = getIt<HiveService>().settings
        .areNotificationsEnabled();
    if (!notificationsEnabled) return;
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
        ),
        NotificationChannel(
          channelKey: 'prayer_prompts',
          channelName: 'Prayer Prompts',
          channelDescription: 'Notify members to pray',
        ),
        NotificationChannel(
          channelKey: 'giving_prompts',
          channelName: 'Giving Prompts',
          channelDescription: 'Notify members to give towards the fellowship',
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationService.onDismissActionReceivedMethod,
    );
  }

  @override
  Future<void> requestPermissions() async {
    final hiveService = getIt<HiveService>().settings;
    final notificationsEnabled = hiveService.areNotificationsEnabled();
    final hasBeenRequested = hiveService.hasPermissionBeenRequested();

    // Don't show dialog if notifications are disabled or already requested
    if (!notificationsEnabled || hasBeenRequested) return;

    var userAuthorized = false;
    final context = getIt<PRFLeadershipRouter>().navigatorKey.currentContext;
    if (context == null) return;
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.getNotified),
          content: Text(l10n.allowNotifications),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.deny,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                userAuthorized = true;
                Navigator.of(context).pop();
              },
              child: Text(
                l10n.allow,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Mark that permission has been requested
    hiveService.setPermissionRequested(requested: true);

    if (userAuthorized) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      hiveService.toggleNotifications(enable: true);
    } else {
      hiveService.toggleNotifications(enable: false);
    }
  }

  @override
  void createNotification({required NotificationContent content}) {
    final notificationsEnabled = getIt<HiveService>().settings
        .areNotificationsEnabled();
    if (!notificationsEnabled) return;
    AwesomeNotifications().createNotification(content: content);
  }

  @override
  Future<void> scheduleGivingNotification() async {
    final notificationsEnabled = getIt<HiveService>().settings
        .areNotificationsEnabled();
    if (!notificationsEnabled) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        autoDismissible: false,
        id: 111001,
        channelKey: 'giving_prompts',
        title: 'PRF: Support',
        body: 'Consider supporting the fellowship with your giving',
        payload: {'type': 'giving_prompt'},
      ),
      // Show this notification every Fridy at 1250 Hours
      schedule: NotificationCalendar(
        weekday: 5,
        hour: 12,
        minute: 50,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
        timeZone: _timezone,
      ),
    );
  }

  String get _timezone => tz.local.name;
}
