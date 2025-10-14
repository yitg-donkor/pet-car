// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pet_care/models/reminder.dart';
// import 'package:pet_care/models/user_profile.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   bool _initialized = false;
//   NotificationPreferences? _preferences;

//   // Channel IDs - use dynamic IDs based on settings
//   String get _reminderChannelId {
//     final sound = _preferences?.soundEnabled ?? true;
//     final vibration = _preferences?.vibrationEnabled ?? true;
//     return 'pet_reminders_s${sound ? 1 : 0}_v${vibration ? 1 : 0}';
//   }

//   String get _testChannelId {
//     final sound = _preferences?.soundEnabled ?? true;
//     final vibration = _preferences?.vibrationEnabled ?? true;
//     return 'test_channel_s${sound ? 1 : 0}_v${vibration ? 1 : 0}';
//   }

//   Future<void> initialize() async {
//     if (_initialized) return;

//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Africa/Accra'));

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     _initialized = true;

//     // Create initial channels
//     await _createOrUpdateChannels();

//     print('✅ Notification service initialized');
//   }

//   Future<void> _createOrUpdateChannels() async {
//     final androidPlugin =
//         _notifications
//             .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//             >();

//     if (androidPlugin == null) return;

//     final sound = _preferences?.soundEnabled ?? true;
//     final vibration = _preferences?.vibrationEnabled ?? true;
//     final quietHours = isQuietHours;

//     // Delete old channels with fixed IDs (cleanup)
//     await androidPlugin.deleteNotificationChannel('pet_reminders');
//     await androidPlugin.deleteNotificationChannel('test_channel');
//     await androidPlugin.deleteNotificationChannel('pet_reminders_early');
//     await androidPlugin.deleteNotificationChannel('daily_summary');

//     // Create reminder channel with current settings
//     final reminderChannel = AndroidNotificationChannel(
//       _reminderChannelId,
//       'Pet Care Reminders',
//       description: 'Notifications for pet care tasks and reminders',
//       importance: Importance.high,
//       playSound: sound && !quietHours,
//       enableVibration: vibration && !quietHours,
//       sound:
//           sound && !quietHours
//               ? const RawResourceAndroidNotificationSound('notification')
//               : null,
//       vibrationPattern:
//           (vibration && !quietHours)
//               ? Int64List.fromList([0, 1000, 500, 1000])
//               : null,
//     );

//     // Create test channel with current settings
//     final testChannel = AndroidNotificationChannel(
//       _testChannelId,
//       'Test Notifications',
//       description: 'Test notifications',
//       importance: Importance.high,
//       playSound: sound && !quietHours,
//       enableVibration: vibration && !quietHours,
//       sound:
//           sound && !quietHours
//               ? const RawResourceAndroidNotificationSound('notification')
//               : null,
//       vibrationPattern:
//           (vibration && !quietHours)
//               ? Int64List.fromList([0, 1000, 500, 1000])
//               : null,
//     );

//     // Create early reminder channel
//     final earlyChannel = AndroidNotificationChannel(
//       'early_${_reminderChannelId}',
//       'Early Reminders',
//       description: 'Early notifications 15 minutes before tasks',
//       importance: Importance.defaultImportance,
//       playSound: sound && !quietHours,
//       enableVibration: vibration && !quietHours,
//       vibrationPattern:
//           (vibration && !quietHours)
//               ? Int64List.fromList([0, 500, 250, 500])
//               : null,
//     );

//     // Create daily summary channel
//     final summaryChannel = AndroidNotificationChannel(
//       'summary_${_reminderChannelId}',
//       'Daily Summary',
//       description: 'Daily summary of pet care tasks',
//       importance: Importance.high,
//       playSound: sound && !quietHours,
//       enableVibration: vibration && !quietHours,
//       vibrationPattern:
//           (vibration && !quietHours)
//               ? Int64List.fromList([0, 1000, 500, 1000])
//               : null,
//     );

//     await androidPlugin.createNotificationChannel(reminderChannel);
//     await androidPlugin.createNotificationChannel(testChannel);
//     await androidPlugin.createNotificationChannel(earlyChannel);
//     await androidPlugin.createNotificationChannel(summaryChannel);

//     print(
//       '📢 Created/Updated notification channels with sound=$sound, vibration=$vibration',
//     );
//   }

//   void setPreferences(NotificationPreferences preferences) {
//     final oldPrefs = _preferences;
//     _preferences = preferences;

//     // Recreate channels if sound/vibration settings changed
//     if (oldPrefs?.soundEnabled != preferences.soundEnabled ||
//         oldPrefs?.vibrationEnabled != preferences.vibrationEnabled) {
//       _createOrUpdateChannels();
//     }

//     print(
//       '📝 Notification preferences updated: Sound=${preferences.soundEnabled}, Vibration=${preferences.vibrationEnabled}',
//     );
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     print('Notification tapped: ${response.payload}');
//   }

//   Future<bool> requestPermissions() async {
//     if (await Permission.notification.isDenied) {
//       final status = await Permission.notification.request();
//       return status.isGranted;
//     }
//     return true;
//   }

//   bool get isQuietHours {
//     if (_preferences == null || !_preferences!.quietHoursEnabled) {
//       return false;
//     }

//     final now = DateTime.now();
//     final currentTime = now.hour * 60 + now.minute;

//     final startParts = _preferences!.quietHoursStart.split(':');
//     final endParts = _preferences!.quietHoursEnd.split(':');

//     final startMinutes =
//         int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
//     final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

//     if (startMinutes < endMinutes) {
//       return currentTime >= startMinutes && currentTime < endMinutes;
//     } else {
//       return currentTime >= startMinutes || currentTime < endMinutes;
//     }
//   }

//   bool shouldSendNotification(String type) {
//     if (_preferences == null || !_preferences!.allNotificationsEnabled) {
//       print('🔇 All notifications disabled');
//       return false;
//     }

//     if (_preferences!.quietHoursEnabled && isQuietHours) {
//       print('🌙 Quiet hours active - skipping notification');
//       return false;
//     }

//     switch (type) {
//       case 'reminder':
//         return _preferences!.reminderNotifications;
//       case 'health':
//         return _preferences!.healthAlerts;
//       default:
//         return true;
//     }
//   }

//   bool get _shouldPlaySound {
//     if (_preferences == null) return true;
//     if (isQuietHours) return false;
//     final result = _preferences!.soundEnabled;
//     print(
//       '🔊 Should play sound: $result (soundEnabled=${_preferences!.soundEnabled}, quietHours=$isQuietHours)',
//     );
//     return result;
//   }

//   bool get _shouldVibrate {
//     if (_preferences == null) return true;
//     if (isQuietHours) return false;
//     final result = _preferences!.vibrationEnabled;
//     print(
//       '📳 Should vibrate: $result (vibrationEnabled=${_preferences!.vibrationEnabled}, quietHours=$isQuietHours)',
//     );
//     return result;
//   }

//   Future<void> scheduleReminderNotification(Reminder reminder) async {
//     if (!_initialized) await initialize();

//     if (!shouldSendNotification('reminder')) {
//       print('🔇 Reminder notifications disabled - skipping: ${reminder.title}');
//       return;
//     }

//     final hasPermission = await requestPermissions();
//     if (!hasPermission) {
//       print('❌ Notification permission denied');
//       return;
//     }

//     await cancelNotification(reminder.id!);

//     final now = tz.TZDateTime.now(tz.local);
//     final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

//     if (scheduledDate.isBefore(now)) {
//       print('⏭️ Skipping past notification for: ${reminder.title}');
//       return;
//     }

//     final shouldPlaySound = _shouldPlaySound;
//     final shouldVibrate = _shouldVibrate;

//     print(
//       'Creating notification with: sound=$shouldPlaySound, vibration=$shouldVibrate, channel=$_reminderChannelId',
//     );

//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         _reminderChannelId, // Use dynamic channel ID
//         'Pet Care Reminders',
//         channelDescription: 'Notifications for pet care tasks and reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: const Color(0xFF4CAF50),
//         playSound: shouldPlaySound,
//         enableVibration: shouldVibrate,
//         sound:
//             shouldPlaySound
//                 ? const RawResourceAndroidNotificationSound('notification')
//                 : null,
//         vibrationPattern:
//             shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
//         styleInformation: BigTextStyleInformation(
//           reminder.description ?? 'Time to take care of your pet!',
//           contentTitle: reminder.title,
//         ),
//         enableLights: true,
//         ledColor: const Color(0xFF4CAF50),
//         ledOnMs: 1000,
//         ledOffMs: 500,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: shouldPlaySound,
//         subtitle: reminder.description,
//       ),
//     );

//     switch (reminder.reminderType) {
//       case 'daily':
//         await _scheduleDailyNotification(reminder, notificationDetails);
//         break;
//       case 'weekly':
//         await _scheduleWeeklyNotification(reminder, notificationDetails);
//         break;
//       case 'monthly':
//         await _scheduleMonthlyNotification(reminder, notificationDetails);
//         break;
//       case 'once':
//       default:
//         await _scheduleOneTimeNotification(reminder, notificationDetails);
//         break;
//     }

//     print(
//       '✅ Scheduled ${reminder.reminderType} notification: ${reminder.title} (sound=$shouldPlaySound, vibration=$shouldVibrate)',
//     );
//   }

//   Future<void> _scheduleOneTimeNotification(
//     Reminder reminder,
//     NotificationDetails details,
//   ) async {
//     final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

//     await _notifications.zonedSchedule(
//       reminder.id.hashCode,
//       reminder.title,
//       reminder.description ?? 'Time for ${reminder.title}',
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       payload: 'reminder:${reminder.id}',
//     );
//   }

//   Future<void> _scheduleDailyNotification(
//     Reminder reminder,
//     NotificationDetails details,
//   ) async {
//     final now = tz.TZDateTime.now(tz.local);
//     final time = reminder.reminderDate;

//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     await _notifications.zonedSchedule(
//       reminder.id.hashCode,
//       reminder.title,
//       reminder.description ?? 'Daily reminder for ${reminder.title}',
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: 'reminder:${reminder.id}',
//     );
//   }

//   Future<void> _scheduleWeeklyNotification(
//     Reminder reminder,
//     NotificationDetails details,
//   ) async {
//     final now = tz.TZDateTime.now(tz.local);
//     final time = reminder.reminderDate;
//     final targetWeekday = time.weekday;

//     int daysUntilTarget = (targetWeekday - now.weekday) % 7;
//     if (daysUntilTarget == 0) {
//       final todayAtTime = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month,
//         now.day,
//         time.hour,
//         time.minute,
//       );
//       if (todayAtTime.isBefore(now)) {
//         daysUntilTarget = 7;
//       }
//     }

//     final scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day + daysUntilTarget,
//       time.hour,
//       time.minute,
//     );

//     await _notifications.zonedSchedule(
//       reminder.id.hashCode,
//       reminder.title,
//       reminder.description ?? 'Weekly reminder for ${reminder.title}',
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       payload: 'reminder:${reminder.id}',
//     );
//   }

//   Future<void> _scheduleMonthlyNotification(
//     Reminder reminder,
//     NotificationDetails details,
//   ) async {
//     final now = tz.TZDateTime.now(tz.local);
//     final time = reminder.reminderDate;
//     final targetDay = time.day;

//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       targetDay,
//       time.hour,
//       time.minute,
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = tz.TZDateTime(
//         tz.local,
//         now.year,
//         now.month + 1,
//         targetDay,
//         time.hour,
//         time.minute,
//       );
//     }

//     await _notifications.zonedSchedule(
//       reminder.id.hashCode,
//       reminder.title,
//       reminder.description ?? 'Monthly reminder for ${reminder.title}',
//       scheduledDate,
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
//       payload: 'reminder:${reminder.id}',
//     );
//   }

//   Future<void> scheduleEarlyNotification(Reminder reminder) async {
//     if (!_initialized) await initialize();

//     final scheduledDate = reminder.reminderDate.subtract(
//       const Duration(minutes: 15),
//     );
//     final now = DateTime.now();

//     if (scheduledDate.isBefore(now)) return;

//     final shouldPlaySound = _shouldPlaySound;
//     final shouldVibrate = _shouldVibrate;

//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'early_${_reminderChannelId}', // Use dynamic channel ID
//         'Early Reminders',
//         channelDescription: 'Early notifications 15 minutes before tasks',
//         importance: Importance.defaultImportance,
//         priority: Priority.defaultPriority,
//         icon: '@mipmap/ic_launcher',
//         color: const Color(0xFF4CAF50),
//         playSound: shouldPlaySound,
//         enableVibration: shouldVibrate,
//         sound:
//             shouldPlaySound
//                 ? const RawResourceAndroidNotificationSound('notification')
//                 : null,
//         vibrationPattern:
//             shouldVibrate ? Int64List.fromList([0, 500, 250, 500]) : null,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: shouldPlaySound,
//       ),
//     );

//     await _notifications.zonedSchedule(
//       '${reminder.id}_early'.hashCode,
//       'Upcoming: ${reminder.title}',
//       'In 15 minutes - ${reminder.description ?? reminder.title}',
//       tz.TZDateTime.from(scheduledDate, tz.local),
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       payload: 'reminder:${reminder.id}',
//     );

//     print('✅ Scheduled early notification for: ${reminder.title}');
//   }

//   Future<void> scheduleDailySummary(int pendingCount) async {
//     if (!_initialized) await initialize();

//     if (_preferences == null || !_preferences!.allNotificationsEnabled) {
//       print('🔇 Daily summary disabled');
//       return;
//     }

//     final now = tz.TZDateTime.now(tz.local);

//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       8,
//       0,
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     final shouldPlaySound = _shouldPlaySound;
//     final shouldVibrate = _shouldVibrate;

//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'summary_${_reminderChannelId}', // Use dynamic channel ID
//         'Daily Summary',
//         channelDescription: 'Daily summary of pet care tasks',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: const Color(0xFF4CAF50),
//         playSound: shouldPlaySound,
//         enableVibration: shouldVibrate,
//         sound:
//             shouldPlaySound
//                 ? const RawResourceAndroidNotificationSound('notification')
//                 : null,
//         vibrationPattern:
//             shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
//         styleInformation: BigTextStyleInformation(
//           'Tap to see your pet care tasks for today',
//           contentTitle: 'Daily Pet Care Summary',
//         ),
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: shouldPlaySound,
//       ),
//     );

//     await _notifications.zonedSchedule(
//       'daily_summary'.hashCode,
//       'Daily Pet Care Summary',
//       'You have $pendingCount task${pendingCount != 1 ? 's' : ''} today',
//       scheduledDate,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: 'summary',
//     );

//     print('✅ Scheduled daily summary');
//   }

//   Future<void> cancelNotification(String reminderId) async {
//     await _notifications.cancel(reminderId.hashCode);
//     await _notifications.cancel('${reminderId}_early'.hashCode);
//     print('Cancelled notifications for reminder: $reminderId');
//   }

//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//     print('Cancelled all notifications');
//   }

//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _notifications.pendingNotificationRequests();
//   }

//   Future<void> showImmediateNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     if (!_initialized) await initialize();

//     // Ensure channels are up-to-date
//     await _createOrUpdateChannels();

//     final shouldPlaySound = _shouldPlaySound;
//     final shouldVibrate = _shouldVibrate;

//     print(
//       'Test notification: sound=$shouldPlaySound, vibration=$shouldVibrate, channel=$_testChannelId',
//     );

//     final notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         _testChannelId, // Use dynamic channel ID
//         'Test Notifications',
//         channelDescription: 'Test notifications',
//         importance: Importance.high,
//         priority: Priority.high,
//         icon: '@mipmap/ic_launcher',
//         color: const Color(0xFF4CAF50),
//         playSound: shouldPlaySound,
//         enableVibration: shouldVibrate,
//         sound:
//             shouldPlaySound
//                 ? const RawResourceAndroidNotificationSound('notification')
//                 : null,
//         vibrationPattern:
//             shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
//         enableLights: true,
//         ledColor: const Color(0xFF4CAF50),
//         ledOnMs: 1000,
//         ledOffMs: 500,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: shouldPlaySound,
//       ),
//     );

//     await _notifications.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }

//   Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
//     print('Rescheduling ${reminders.length} reminders...');

//     // Recreate channels with current preferences
//     await _createOrUpdateChannels();

//     await cancelAllNotifications();

//     for (var reminder in reminders) {
//       if (!reminder.isCompleted) {
//         await scheduleReminderNotification(reminder);
//       }
//     }

//     print('✅ Rescheduled all reminders with current preferences');
//   }
// }

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/models/user_profile.dart';

/// Notification Service - Handles all app notifications
///
/// KEY DESIGN DECISION:
/// - Uses FIXED channel IDs (never change)
/// - Channels are created with MAXIMUM capabilities (sound + vibration enabled)
/// - Individual notifications control whether to use sound/vibration
/// - This prevents channel recreation issues that cause crashes in debug mode
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationPreferences? _preferences;

  // ✅ FIXED CHANNEL IDS - NEVER CHANGE THESE
  static const String _reminderChannelId = 'pet_reminders';
  static const String _testChannelId = 'test_channel';
  static const String _earlyChannelId = 'early_reminders';
  static const String _summaryChannelId = 'daily_summary';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Accra'));

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;

    // Create notification channels (one-time setup)
    await _createChannels();

    debugPrint('✅ Notification service initialized');
  }

  /// Create notification channels once with maximum capabilities
  /// Sound/vibration will be controlled per notification, not per channel
  Future<void> _createChannels() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin == null) return;

    // Create channels with FULL capabilities
    // Individual notifications will decide whether to use them

    // 1. Main reminder channel
    final reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      'Pet Care Reminders',
      description: 'Notifications for pet care tasks and reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    // 2. Test notification channel
    final testChannel = AndroidNotificationChannel(
      _testChannelId,
      'Test Notifications',
      description: 'Test notifications for verifying settings',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    // 3. Early reminder channel (15 minutes before)
    final earlyChannel = AndroidNotificationChannel(
      _earlyChannelId,
      'Early Reminders',
      description: 'Early notifications 15 minutes before tasks',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
    );

    // 4. Daily summary channel
    final summaryChannel = AndroidNotificationChannel(
      _summaryChannelId,
      'Daily Summary',
      description: 'Daily summary of pet care tasks',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    // Create all channels
    await androidPlugin.createNotificationChannel(reminderChannel);
    await androidPlugin.createNotificationChannel(testChannel);
    await androidPlugin.createNotificationChannel(earlyChannel);
    await androidPlugin.createNotificationChannel(summaryChannel);

    debugPrint('📢 Created notification channels');
  }

  /// Update notification preferences
  /// NOTE: We don't recreate channels - we just store preferences
  /// Individual notifications will respect these settings
  void setPreferences(NotificationPreferences preferences) {
    _preferences = preferences;
    debugPrint(
      '📝 Notification preferences updated: '
      'Sound=${preferences.soundEnabled}, '
      'Vibration=${preferences.vibrationEnabled}',
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check if current time is within quiet hours
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

  /// Check if notification should be sent based on type
  bool shouldSendNotification(String type) {
    if (_preferences == null || !_preferences!.allNotificationsEnabled) {
      debugPrint('🔇 All notifications disabled');
      return false;
    }

    if (_preferences!.quietHoursEnabled && isQuietHours) {
      debugPrint('🌙 Quiet hours active - skipping notification');
      return false;
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

  /// Check if sound should be played
  bool get _shouldPlaySound {
    if (_preferences == null) return true;
    if (isQuietHours) return false;
    return _preferences!.soundEnabled;
  }

  /// Check if device should vibrate
  bool get _shouldVibrate {
    if (_preferences == null) return true;
    if (isQuietHours) return false;
    return _preferences!.vibrationEnabled;
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    if (!shouldSendNotification('reminder')) {
      debugPrint(
        '🔇 Reminder notifications disabled - skipping: ${reminder.title}',
      );
      return;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('❌ Notification permission denied');
      return;
    }

    // Cancel existing notification
    await cancelNotification(reminder.id!);

    // Check if scheduled date is in the future
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.from(reminder.reminderDate, tz.local);

    if (scheduledDate.isBefore(now)) {
      debugPrint('⏭️ Skipping past notification for: ${reminder.title}');
      return;
    }

    // Get current sound/vibration settings
    final shouldPlaySound = _shouldPlaySound;
    final shouldVibrate = _shouldVibrate;

    debugPrint('📅 Scheduling: ${reminder.title}');
    debugPrint('   Sound: $shouldPlaySound, Vibration: $shouldVibrate');

    // Build notification details with current settings
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        'Pet Care Reminders',
        channelDescription: 'Notifications for pet care tasks and reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        // ✅ Control sound/vibration per notification
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        sound:
            shouldPlaySound
                ? const RawResourceAndroidNotificationSound('notification')
                : null,
        vibrationPattern:
            shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
        styleInformation: BigTextStyleInformation(
          reminder.description ?? 'Time to take care of your pet!',
          contentTitle: reminder.title,
        ),
        enableLights: true,
        ledColor: const Color(0xFF4CAF50),
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: shouldPlaySound,
        subtitle: reminder.description,
      ),
    );

    // Schedule based on reminder type
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

    debugPrint(
      '✅ Scheduled ${reminder.reminderType} notification: ${reminder.title}',
    );
  }

  /// Schedule one-time notification
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

  /// Schedule daily recurring notification
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

  /// Schedule weekly recurring notification
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

  /// Schedule monthly recurring notification
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

  /// Schedule early notification (15 minutes before)
  Future<void> scheduleEarlyNotification(Reminder reminder) async {
    if (!_initialized) await initialize();

    final scheduledDate = reminder.reminderDate.subtract(
      const Duration(minutes: 15),
    );
    final now = DateTime.now();

    if (scheduledDate.isBefore(now)) return;

    final shouldPlaySound = _shouldPlaySound;
    final shouldVibrate = _shouldVibrate;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _earlyChannelId,
        'Early Reminders',
        channelDescription: 'Early notifications 15 minutes before tasks',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        sound:
            shouldPlaySound
                ? const RawResourceAndroidNotificationSound('notification')
                : null,
        vibrationPattern:
            shouldVibrate ? Int64List.fromList([0, 500, 250, 500]) : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: shouldPlaySound,
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

    debugPrint('✅ Scheduled early notification for: ${reminder.title}');
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary(int pendingCount) async {
    if (!_initialized) await initialize();

    if (_preferences == null || !_preferences!.allNotificationsEnabled) {
      debugPrint('🔇 Daily summary disabled');
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

    final shouldPlaySound = _shouldPlaySound;
    final shouldVibrate = _shouldVibrate;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _summaryChannelId,
        'Daily Summary',
        channelDescription: 'Daily summary of pet care tasks',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        sound:
            shouldPlaySound
                ? const RawResourceAndroidNotificationSound('notification')
                : null,
        vibrationPattern:
            shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
        styleInformation: BigTextStyleInformation(
          'Tap to see your pet care tasks for today',
          contentTitle: 'Daily Pet Care Summary',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: shouldPlaySound,
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

    debugPrint('✅ Scheduled daily summary');
  }

  /// Show immediate test notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final shouldPlaySound = _shouldPlaySound;
    final shouldVibrate = _shouldVibrate;

    debugPrint('🔔 Sending test notification:');
    debugPrint('   Sound: $shouldPlaySound');
    debugPrint('   Vibration: $shouldVibrate');

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _testChannelId,
        'Test Notifications',
        channelDescription: 'Test notifications for verifying settings',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF4CAF50),
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        sound:
            shouldPlaySound
                ? const RawResourceAndroidNotificationSound('notification')
                : null,
        vibrationPattern:
            shouldVibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
        enableLights: true,
        ledColor: const Color(0xFF4CAF50),
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: shouldPlaySound,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('✅ Test notification sent!');
  }

  /// Cancel specific reminder notification
  Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
    await _notifications.cancel('${reminderId}_early'.hashCode);
    debugPrint('Cancelled notifications for reminder: $reminderId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Reschedule all reminders with current preferences
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    debugPrint('🔄 Rescheduling ${reminders.length} reminders...');

    await cancelAllNotifications();

    for (var reminder in reminders) {
      if (!reminder.isCompleted) {
        await scheduleReminderNotification(reminder);
      }
    }

    debugPrint('✅ Rescheduled all reminders with current preferences');
  }
}
