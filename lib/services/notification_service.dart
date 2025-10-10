import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_care/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Accra')); // Set to your timezone

    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Notification service initialized');
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
    // You can pass reminder ID in payload and navigate to reminder details
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  // Schedule notification for a reminder
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('❌ Notification permission denied');
      return;
    }

    // Cancel existing notification for this reminder
    await cancelNotification(reminder.id!);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

    // Don't schedule if time has passed
    if (scheduledDate.isBefore(now)) {
      print('⏭️ Skipping past notification for: ${reminder.title}');
      return;
    }

    // Notification details
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'pet_reminders',
        'Pet Care Reminders',
        channelDescription: 'Notifications for pet care tasks and reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          reminder.description ?? 'Time to take care of your pet!',
          contentTitle: reminder.title,
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: reminder.description,
      ),
    );

    // Schedule based on frequency type
    switch (reminder.reminderType) {
      case 'daily':
        await _scheduleDailyNotification(reminder, notificationDetails);
        break;
      case 'weekly':
        await _scheduleWeeklyNotification(reminder, notificationDetails);
        break;
      case 'monthly':
        await _scheduleMonthlyNotification(reminder, notificationDetails);
        break;
      case 'once':
      default:
        await _scheduleOneTimeNotification(reminder, notificationDetails);
        break;
    }

    print(
      '✅ Scheduled ${reminder.reminderType} notification: ${reminder.title}',
    );
  }

  // Schedule one-time notification
  Future<void> _scheduleOneTimeNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Time for ${reminder.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      payload: 'reminder:${reminder.id}',
    );
  }

  // Schedule daily repeating notification
  Future<void> _scheduleDailyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;

    // Create first occurrence
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule with daily repeat
    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Daily reminder for ${reminder.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      payload: 'reminder:${reminder.id}',
    );
  }

  // Schedule weekly repeating notification
  Future<void> _scheduleWeeklyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;
    final targetWeekday = time.weekday;

    // Calculate days until target weekday
    int daysUntilTarget = (targetWeekday - now.weekday) % 7;
    if (daysUntilTarget == 0) {
      // It's the target day - check if time has passed
      final todayAtTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (todayAtTime.isBefore(now)) {
        daysUntilTarget = 7; // Schedule for next week
      }
    }

    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilTarget,
      time.hour,
      time.minute,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Weekly reminder for ${reminder.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // Repeats weekly
      payload: 'reminder:${reminder.id}',
    );
  }

  // Schedule monthly repeating notification
  Future<void> _scheduleMonthlyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;
    final targetDay = time.day;

    // Calculate next occurrence
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      targetDay,
      time.hour,
      time.minute,
    );

    // If date has passed this month, schedule for next month
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        targetDay,
        time.hour,
        time.minute,
      );
    }

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Monthly reminder for ${reminder.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents:
          DateTimeComponents.dayOfMonthAndTime, // Repeats monthly
      payload: 'reminder:${reminder.id}',
    );
  }

  // Schedule early notification (15 minutes before)
  Future<void> scheduleEarlyNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    final scheduledDate = reminder.reminderDate.subtract(
      const Duration(minutes: 15),
    );
    final now = DateTime.now();

    // Don't schedule if time has passed
    if (scheduledDate.isBefore(now)) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'pet_reminders_early',
        'Early Reminders',
        channelDescription: 'Early notifications 15 minutes before tasks',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      '${reminder.id}_early'.hashCode,
      '⏰ Upcoming: ${reminder.title}',
      'In 15 minutes - ${reminder.description ?? reminder.title}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      payload: 'reminder:${reminder.id}',
    );

    print('✅ Scheduled early notification for: ${reminder.title}');
  }

  // Schedule daily summary notification
  Future<void> scheduleDailySummary(
    int hour,
    int minute,
    int pendingCount,
  ) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_summary',
        'Daily Summary',
        channelDescription: 'Daily summary of pet care tasks',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        styleInformation: BigTextStyleInformation(
          'Tap to see your pet care tasks for today',
          contentTitle: '🐾 Daily Pet Care Summary',
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      'daily_summary'.hashCode,
      '🐾 Daily Pet Care Summary',
      'You have $pendingCount task${pendingCount != 1 ? 's' : ''} today',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      payload: 'summary',
    );

    print('✅ Scheduled daily summary at $hour:$minute');
  }

  // Cancel notification for a reminder
  Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
    await _notifications.cancel('${reminderId}_early'.hashCode);
    print('🗑️ Cancelled notifications for reminder: $reminderId');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ Cancelled all notifications');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4CAF50),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Reschedule all reminders (useful after app update or device restart)
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    print('🔄 Rescheduling ${reminders.length} reminders...');

    await cancelAllNotifications();

    for (var reminder in reminders) {
      if (!reminder.isCompleted) {
        await scheduleReminderNotification(reminder);
      }
    }

    print('✅ Rescheduled all reminders');
  }
}
