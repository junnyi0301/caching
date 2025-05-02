import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:caching/main.dart';

class NotiService{
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async{
    if (_isInitialized) return; // prevent re-initialization

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // prepare android init setting
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // prepare ios setting
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init setting (group together)
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // finally, use to initialized the plugin
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final checklistID = response.payload;
        navigatorKey.currentState?.pushNamed('/checklist', arguments: checklistID);
      },
    );
  }

  // NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', // Must match in both show and schedule
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        // playSound: true,
        // enableVibration: true,
        //sound: RawResourceAndroidNotificationSound('notification_sound'),
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel_id',
          'Default',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Schedule notification at a specified date
  Future<void> scheduleChecklistNotification({
    required String checklistId,
    required String title,
    required String dateString,
  }) async {
    try {
      if (!_isInitialized) await initNotification();

      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      final location = tz.local;

      print('Original Date: $date');
      print('Local Timezone: ${location.name}');

      final scheduledTime = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        9,
        0,
      );

      print('Scheduled Time (Local): $scheduledTime');

      await notificationsPlugin.zonedSchedule(
        checklistId.hashCode,
        'Checklist Reminder',
        'Don\'t forget about: $title',
        scheduledTime,
        notificationDetails(),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: checklistId,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Notification successfully scheduled for $scheduledTime');
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelChecklistNotification(String checklistId) async {
    await notificationsPlugin.cancel(checklistId.hashCode);
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      print('''
    Scheduling Notification:
    - Current Time: ${now.toLocal()}
    - Scheduled Time: ${scheduledDate.toLocal()}
    - Time Difference: ${scheduledDate.difference(now).inMinutes} minutes
    ''');

      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(), // Make sure to use your notificationDetails()
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
      );

      print('✅ Notification scheduled successfully for ${scheduledDate.toLocal()}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }


  Future<void> showImmediateTestNotification() async {
    await showNotification(
      id: 9999,
      title: 'Test Notification',
      body: 'This is an immediate test notification',
    );
  }

  Future<void> scheduleTestNotification() async {
    try {
      // Get current time in local timezone
      final location = tz.local;
      final now = tz.TZDateTime.now(location);
      print('Current local time: $now');

      // Schedule for 10 seconds later (use exact timing)
      final testTime = now.add(Duration(seconds: 10));
      print('Scheduled time: $testTime');

      await notificationsPlugin.zonedSchedule(
        9998,
        'Scheduled Test',
        'This should appear at ${DateFormat('HH:mm:ss').format(testTime)}',
        testTime,
        notificationDetails(),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Changed to exact
      );

      print('Test notification scheduled successfully for $testTime');
    } catch (e) {
      print('Error scheduling test notification: $e');
      rethrow;
    }
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
    Android Details: ${notification.android}
    ''');
    }
    print('═══════════════════════════════════');
  }

}