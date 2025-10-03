import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/services/supa_sync-service.dart';

final reminderDatabaseProvider = Provider<ReminderDatabaseService>((ref) {
  return ReminderDatabaseService.instance;
});

final reminderSyncServiceProvider = Provider<ReminderSyncService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final localDb = ref.watch(reminderDatabaseProvider);
  return ReminderSyncService(supabase: supabase, localDb: localDb);
});

// Main provider - fetches all reminders from local DB
// This will only refresh when explicitly invalidated via ref.invalidate()
final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  final syncService = ref.watch(reminderSyncServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    // Initial sync
    await syncService.fullSync(user.id);
  }

  // Get all reminders from local database
  return db.getAllReminders();
});

// Keep this alias for backward compatibility with your existing code
final remindersStreamProvider = remindersProvider;

final todayRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  // Watch the main provider to trigger refresh when it updates
  ref.watch(remindersProvider);
  final db = ref.watch(reminderDatabaseProvider);
  return db.getTodayReminders();
});

final weeklyRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  // Watch the main provider to trigger refresh when it updates
  ref.watch(remindersProvider);
  final db = ref.watch(reminderDatabaseProvider);
  return db.getRemindersByType('weekly');
});

final monthlyRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  // Watch the main provider to trigger refresh when it updates
  ref.watch(remindersProvider);
  final db = ref.watch(reminderDatabaseProvider);
  return db.getRemindersByType('monthly');
});
