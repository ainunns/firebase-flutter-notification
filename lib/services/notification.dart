import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_flutter_notification/views/second_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_notification/main.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    try {
      // Initialize Awesome Notifications
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF007AFF),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            criticalAlerts: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic notifications group',
          ),
        ],
        debug: true,
      );

      // Request notification permissions
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      // Set notification listeners
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onActionReceivedMethod,
        onNotificationCreatedMethod: _onNotificationCreateMethod,
        onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Listeners
  static Future<void> _onNotificationCreateMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  static Future<void> _onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  static Future<void> _onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    final payload = receivedNotification.payload;
    if (payload == null) return;

    if (payload['navigate'] == 'true') {
      if (MyApp.navigatorKey.currentContext != null) {
        Navigator.push(
          MyApp.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const SecondPage()),
        );
      }
    }
  }

  static Future<void> createNotification({
    required final int id,
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final Duration? interval,
  }) async {
    try {
      assert(!scheduled || (scheduled && interval != null));

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      if (!isAllowed) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
        ),
        actionButtons: actionButtons,
        schedule: scheduled
            ? NotificationInterval(
                interval: interval,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                preciseAlarm: true,
              )
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
