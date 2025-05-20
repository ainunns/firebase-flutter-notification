import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    try {
      await AwesomeNotifications().initialize(
        null, // No icon for now
        [
          NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF007AFF),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            playSound: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic notifications group',
          ),
        ],
        debug: false,
      );

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      // Simplified listeners
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

  static Future<void> _onNotificationCreateMethod(
      ReceivedNotification receivedNotification) async {}
  static Future<void> _onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}
  static Future<void> _onDismissActionReceivedMethod(
      ReceivedNotification receivedNotification) async {}

  static Future<void> _onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    // Simplified action handling
    if (receivedNotification.payload == null) return;
  }

  static Future<void> createNotification({
    required final int id,
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
  }) async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed() ||
          await AwesomeNotifications().requestPermissionToSendNotifications();

      if (!isAllowed) return;

      // Create a minimal notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          // Use minimal payload
          payload: {'type': payload?['type'] ?? 'default'},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
