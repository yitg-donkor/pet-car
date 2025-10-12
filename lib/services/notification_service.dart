import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/models/user_profile.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationPreferences? _preferences;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Accra'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

  void setPreferences(NotificationPreferences preferences) {
    _preferences = preferences;
    print('📝 Notification preferences updated');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  bool get isQuietHours {
    if (_preferences == null || !_preferences!.quietHoursEnabled) {
      return false;
    }

    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final startParts = _preferences!.quietHoursStart.split(':');
    final endParts = _preferences!.quietHoursEnd.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    if (startMinutes < endMinutes) {
      return currentTime >= startMinutes && currentTime < endMinutes;
    } else {
      return currentTime >= startMinutes || currentTime < endMinutes;
    }
  }

  bool shouldSendNotification(String type) {
    if (_preferences == null || !_preferences!.allNotificationsEnabled) {
      print('🔇 All notifications disabled');
      return false;
    }

    if (_preferences!.quietHoursEnabled && isQuietHours) {
      print('🌙 Quiet hours active');
      return true;
    }

    switch (type) {
      case 'reminder':
        return _preferences!.reminderNotifications;
      case 'health':
        return _preferences!.healthAlerts;
      default:
        return true;
    }
  }

  bool get _shouldPlaySound {
    return (_preferences?.soundEnabled ?? true) && !isQuietHours;
  }

  bool get _shouldVibrate {
    return (_preferences?.vibrationEnabled ?? true) && !isQuietHours;
  }

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    if (!shouldSendNotification('reminder')) {
      print('🔇 Reminder notifications disabled - skipping: ${reminder.title}');
      return;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('❌ Notification permission denied');
      return;
    }

    await cancelNotification(reminder.id!);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

    if (scheduledDate.isBefore(now)) {
      print('⏭️ Skipping past notification for: ${reminder.title}');
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'pet_reminders',
        'Pet Care Reminders',
        channelDescription: 'Notifications for pet care tasks and reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        playSound: _shouldPlaySound,
        enableVibration: _shouldVibrate,
        sound: const RawResourceAndroidNotificationSound('dog_bark'),
        styleInformation: BigTextStyleInformation(
          reminder.description ?? 'Time to take care of your pet!',
          contentTitle: reminder.title,
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _shouldPlaySound,
        sound: 'dog_bark.wav',
        subtitle: reminder.description,
      ),
    );

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

  Future<void> _scheduleDailyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Daily reminder for ${reminder.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reminder:${reminder.id}',
    );
  }

  Future<void> _scheduleWeeklyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;
    final targetWeekday = time.weekday;

    int daysUntilTarget = (targetWeekday - now.weekday) % 7;
    if (daysUntilTarget == 0) {
      final todayAtTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (todayAtTime.isBefore(now)) {
        daysUntilTarget = 7;
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
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'reminder:${reminder.id}',
    );
  }

  Future<void> _scheduleMonthlyNotification(
    Reminder reminder,
    NotificationDetails details,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.reminderDate;
    final targetDay = time.day;

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      targetDay,
      time.hour,
      time.minute,
    );

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
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'reminder:${reminder.id}',
    );
  }

  Future<void> scheduleEarlyNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    final scheduledDate = reminder.reminderDate.subtract(
      const Duration(minutes: 15),
    );
    final now = DateTime.now();

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
        playSound: _shouldPlaySound,
        enableVibration: _shouldVibrate,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _shouldPlaySound,
        sound: 'notification_sound.wav',
      ),
    );

    await _notifications.zonedSchedule(
      '${reminder.id}_early'.hashCode,
      'Upcoming: ${reminder.title}',
      'In 15 minutes - ${reminder.description ?? reminder.title}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'reminder:${reminder.id}',
    );

    print('✅ Scheduled early notification for: ${reminder.title}');
  }

  Future<void> scheduleDailySummary(int pendingCount) async {
    if (!_initialized) await initialize();

    if (_preferences == null || !_preferences!.allNotificationsEnabled) {
      print('🔇 Daily summary disabled');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
      0,
    );

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
        playSound: _shouldPlaySound,
        enableVibration: _shouldVibrate,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        styleInformation: BigTextStyleInformation(
          'Tap to see your pet care tasks for today',
          contentTitle: 'Daily Pet Care Summary',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _shouldPlaySound,
        sound: 'notification_sound.wav',
      ),
    );

    await _notifications.zonedSchedule(
      'daily_summary'.hashCode,
      'Daily Pet Care Summary',
      'You have $pendingCount task${pendingCount != 1 ? 's' : ''} today',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'summary',
    );

    print('✅ Scheduled daily summary');
  }

  Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
    await _notifications.cancel('${reminderId}_early'.hashCode);
    print('Cancelled notifications for reminder: $reminderId');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('Cancelled all notifications');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

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
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('dog_bark'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'dog_bark.wav',
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

  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    print('Rescheduling ${reminders.length} reminders...');

    await cancelAllNotifications();

    for (var reminder in reminders) {
      if (!reminder.isCompleted) {
        await scheduleReminderNotification(reminder);
      }
    }

    print('Rescheduled all reminders');
  }
}
