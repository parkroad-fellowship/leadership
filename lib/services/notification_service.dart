import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:leadership/enums/prf_notification_type.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/utils/_index.dart';
import 'package:leadership/utils/router/router.gr.dart';
import 'package:logger/logger.dart';
import 'package:prf_design/prf_design.dart';

abstract class NotificationService {
  Future<void> init();

  Future<void> requestPermissions();

  void createNotification({required NotificationContent content});

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Just log - notification is already created, don't create another one
    Logger().d('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Just log - notification is already displayed, don't create another one
    Logger().d('Notification displayed: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // User dismissed the notification - just log, don't navigate
    Logger().d('Notification dismissed: ${receivedAction.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // User tapped the notification - handle the action
    Logger().f('Notification tapped: ${receivedAction.title}');
    await _act(receivedAction.payload);
  }

  static Future<void> _act(Map<String, String?>? payload) async {
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

    if (payload != null) {}

    switch (PRFNotificationType.fromType(payload!['type']!)) {
      case PRFNotificationType.defaultPrompt:
        Logger().i('Default prompt received');
        await getIt<PRFLeadershipRouter>().pushAll([]);
        return;
      case PRFNotificationType.newRequisition:
      case PRFNotificationType.requisitionApproved:
      case PRFNotificationType.requisitionRecalled:
      case PRFNotificationType.requisitionRejected:
      case PRFNotificationType.requisitionReviewRequested:
        Logger().i('New requisition notification received');
        final requisitionUlid = payload['requisition_ulid'];
        if (requisitionUlid != null) {
          await getIt<PRFLeadershipRouter>().replaceAll([
            const LandingRoute(),
            RequisitionDetailsRoute(
              requisitionUlid: requisitionUlid,
            ),
          ]);
        } else {
          Logger().w('No requisition_ulid in notification payload');
        }
        return;
    }
  }
}

class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> init() async {
    final notificationsEnabled = getIt<HiveService>().settings
        .areNotificationsEnabled();
    if (!notificationsEnabled) return;

    // Initialize AwesomeNotifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'requisitions',
          channelName: 'Requisitions',
          channelDescription: 'Notify about new requisitions',
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic group',
        ),
      ],
      debug: kDebugMode,
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

    Logger().i('AwesomeNotifications initialized');
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

    final confirmed = await PRFConfirmationDialog.show(
      context,
      title: l10n.getNotified,
      message: l10n.allowNotifications,
      confirmLabel: l10n.allow,
      cancelLabel: l10n.deny,
    );

    userAuthorized = confirmed ?? false;

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
}
