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
      android: AndroidNotificationDetails(
          "channelId",
          "channelName",
          importance: Importance.max,
          priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  Future<bool> requestNotificationPermission() async {

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;

      if (!status.isGranted) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }

      return true; // Already granted
    }

    if (Platform.isIOS) {
      final iosPlugin = notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      final bool? granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return granted ?? false;
    }

    return true; // Fallback for other platforms
  }

  Future directShowNotification({int id = 0, String? title, String? body, String? payload}) async{
    return notificationsPlugin.show(
      id, title, body, await notificationDetails()
    );
  }

  /// Set right date and time for notifications
  tz.TZDateTime _convertDate(int year, int month, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      9,
      0,
    );
    
    return scheduleDate;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int year,
    required int month,
    required int day
    //required DateTime scheduledTime,
  }) async {
    //print("Get Date Time: $scheduledTime");
    print("Get year: $year");
    print("Get month: $month");
    print("Get day: $day");

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertDate(year, month, day),
      await notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime
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