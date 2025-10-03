import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ReminderSyncService {
  final SupabaseClient supabase;
  final ReminderDatabaseService localDb;
  final Connectivity connectivity = Connectivity();

  ReminderSyncService({required this.supabase, required this.localDb});

  // Check internet connectivity
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Sync from Supabase to local (download)
  Future<void> syncFromSupabase(String userId) async {
    if (!await hasInternetConnection()) {
      print('No internet connection. Skipping sync from Supabase.');
      return;
    }

    try {
      // Get all reminders from Supabase
      final response = await supabase
          .from('reminders')
          .select('''
            *,
            pets!inner(owner_id)
          ''')
          .eq('pets.owner_id', userId);

      final reminders =
          (response as List)
              .map((json) => Reminder.fromSupabase(json))
              .toList();

      // Upsert into local database
      for (var reminder in reminders) {
        await localDb.upsertReminder(reminder);
      }

      print('Synced ${reminders.length} reminders from Supabase');
    } catch (e) {
      print('Error syncing from Supabase: $e');
      throw Exception('Failed to sync from Supabase: $e');
    }
  }

  // Sync to Supabase from local (upload)
  Future<void> syncToSupabase() async {
    if (!await hasInternetConnection()) {
      print('No internet connection. Skipping sync to Supabase.');
      return;
    }

    try {
      // Get unsynced reminders
      final unsyncedReminders = await localDb.getUnsyncedReminders();

      if (unsyncedReminders.isEmpty) {
        print('No unsynced reminders to upload');
        return;
      }

      // Upload to Supabase
      for (var reminder in unsyncedReminders) {
        try {
          await supabase.from('reminders').upsert(reminder.toSupabaseMap());

          // Mark as synced locally
          await localDb.markAsSynced(reminder.id!);
        } catch (e) {
          print('Error syncing reminder ${reminder.id}: $e');
        }
      }

      print('Synced ${unsyncedReminders.length} reminders to Supabase');
    } catch (e) {
      print('Error syncing to Supabase: $e');
      throw Exception('Failed to sync to Supabase: $e');
    }
  }

  // Full bidirectional sync
  Future<void> fullSync(String userId) async {
    if (!await hasInternetConnection()) {
      print('No internet connection. Working offline.');
      return;
    }

    try {
      // First, push local changes to Supabase
      await syncToSupabase();

      // Then, pull latest from Supabase
      await syncFromSupabase(userId);

      print('Full sync completed successfully');
    } catch (e) {
      print('Error during full sync: $e');
    }
  }

  // Delete from both local and Supabase
  Future<void> deleteReminder(String id) async {
    // Delete locally first
    await localDb.deleteReminder(id);

    // Try to delete from Supabase if online
    if (await hasInternetConnection()) {
      try {
        await supabase.from('reminders').delete().eq('id', id);
      } catch (e) {
        print('Error deleting from Supabase: $e');
      }
    }
  }

  // Listen to Supabase realtime changes
  RealtimeChannel setupRealtimeSync(String userId, Function() onUpdate) {
    return supabase
        .channel('reminders_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reminders',
          callback: (payload) async {
            print('Realtime change detected: ${payload.eventType}');

            // Sync from Supabase when changes detected
            await syncFromSupabase(userId);
            onUpdate();
          },
        )
        .subscribe();
  }
}
