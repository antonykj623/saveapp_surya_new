import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 🔹 Initialize
  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // If needed, handle taps or rescheduling logic here
      },
    );
  }

  // 🔹 Request Permission
  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // 🔹 Show Instant Notification
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Shows instant notifications immediately',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // 🔹 One-time
  Future<void> scheduleOnetimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'onetime_channel',
          'One-Time Notifications',
          channelDescription: 'Triggers once at a specified time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Daily
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Repeats daily at the same time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Weekly
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_channel',
          'Weekly Notifications',
          channelDescription: 'Repeats weekly on the same day & time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Monthly
  Future<void> scheduleMonthlyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_channel',
          'Monthly Notifications',
          channelDescription: 'Repeats monthly on the same date & time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Quarterly (every 3 months)
  Future<void> scheduleQuarterlyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final firstSchedule = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      firstSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quarterly_channel',
          'Quarterly Notifications',
          channelDescription: 'Repeats every 3 months',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quarterly_$id',
    );

    // Re-schedule next one manually after 3 months
    final nextSchedule = firstSchedule.add(const Duration(days: 90));
    await _notificationsPlugin.zonedSchedule(
      id + 1000, // ensure unique ID for next cycle
      title,
      body,
      nextSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quarterly_channel',
          'Quarterly Notifications',
          channelDescription: 'Repeats every 3 months',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Half-Yearly (every 6 months)
  Future<void> scheduleHalfYearlyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final firstSchedule = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      firstSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'halfyearly_channel',
          'Half-Yearly Notifications',
          channelDescription: 'Repeats every 6 months',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'halfyearly_$id',
    );

    // Schedule next one 6 months later
    final nextSchedule = firstSchedule.add(const Duration(days: 182));
    await _notificationsPlugin.zonedSchedule(
      id + 2000,
      title,
      body,
      nextSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'halfyearly_channel',
          'Half-Yearly Notifications',
          channelDescription: 'Repeats every 6 months',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Yearly
  Future<void> scheduleYearlyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'yearly_channel',
          'Yearly Notifications',
          channelDescription: 'Repeats yearly on the same date & time',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔹 Cancel all
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
