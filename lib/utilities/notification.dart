import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {

  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async{
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {}
    );
  }

  notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails("channelId", "channelName", importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails()
    );
  }

  Future directShowNotification({int id = 0, String? title, String? body, String? payload}) async{
    return notificationsPlugin.show(
      id, title, body, await notificationDetails()
    );
  }

  // Future<bool> get hasNotificationPermission async {
  //   if (Platform.isAndroid) {
  //     return (await Permission.notification.status).isGranted;
  //   }
  //   return true; // iOS handles this during initialization
  // }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime scheduledTime,
  }) async {
    print("Get Date Time: $scheduledTime");
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      await notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

  }

  Future<void> debugPrintPendingNotifications() async {
    final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();

    if (pendingNotifications.isEmpty) {
      print('No pending notifications');
      return;
    }

    print('══════ Pending Notifications ══════');
    for (final notification in pendingNotifications) {
      print('''
    ID: ${notification.id}
    Title: ${notification.title}
    Body: ${notification.body}
    Scheduled for: ${notification.payload}
    ''');
    }
    print('═══════════════════════════════════');
  }

  Future<void> cancelChecklistNotification(int notiID) async {
    await notificationsPlugin.cancel(notiID);
  }

  Future<void> cancelAllNotification() async {
    await notificationsPlugin.cancelAll();
  }

}