import 'dart:typed_data';

import 'package:timezone/timezone.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:take_your_meds/main.dart';
import 'package:take_your_meds/common/notification.dart';

class NotificationHandler {
  static List<Notification> scheduledNotifications = [];
  static NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'com.jeydolen.take_your_meds',
      'User reminder',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      showWhen: true,
      visibility: NotificationVisibility.private,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      ticker: 'ticker',
      additionalFlags: Int32List.fromList(<int>[4]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  );

  NotificationHandler();

  static cancelAllNotifications() async {
    await flnp.cancelAll();
  }

  static isNotificationScheduled(Notification notification) async {
    int i = scheduledNotifications.indexWhere((element) {
      if (element.time == notification.time &&
          element.body == notification.body &&
          element.title == notification.title) {
        return true;
      }

      return false;
    });

    if (i == -1) {
      return false;
    }

    return (await flnp.pendingNotificationRequests()).any(
      (element) => element.id == i,
    );
  }

  static TZDateTime dateTimeToTZDateTime(DateTime time) {
    return TZDateTime.parse(local, time.toIso8601String());
  }

  static void showNotification(
    Notification notification, {
    DateTimeComponents? dateTimeComponents,
  }) async {
    if (await isNotificationScheduled(notification)) {
      return;
    }
    TZDateTime scheduledDate = dateTimeToTZDateTime(
      notification.time,
    ).add(const Duration(seconds: 1));

    DateTimeComponents matchDateTimeComponents = DateTimeComponents.dateAndTime;
    if (dateTimeComponents != null) {
      matchDateTimeComponents = dateTimeComponents;
    }

    flnp.zonedSchedule(
      scheduledNotifications.length,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      payload: notification.payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: matchDateTimeComponents,
    );

    scheduledNotifications.add(notification);
  }

  static void showPeriodicNotification(Notification notification) async {
    if (await isNotificationScheduled(notification)) {
      return;
    }

    if (notification.periodicDays.isEmpty) {
      // No period detailed
      return;
    }

    DateTime nTime = notification.time;

    for (var day in notification.periodicDays) {
      // Don't know if its working in start / end of month
      int computedDay = nTime.day - nTime.weekday + day.weekDay;
      DateTime time = DateTime(
        nTime.year,
        nTime.month,
        computedDay,
        nTime.hour,
        nTime.minute,
      );

      Notification newNotification = Notification(
        notification.title,
        notification.body,
        time: time,
        payload: notification.payload,
      );

      showNotification(
        newNotification,
        dateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }
}
