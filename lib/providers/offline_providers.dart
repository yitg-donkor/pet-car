// providers/offline_providers.dart
import 'package:pet_care/providers/activity_log_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';
import '../models/medical_record.dart';
import '../models/reminder.dart';
import '../models/activity_log.dart';
import '../local_db/sqflite_db.dart';
import 'auth_providers.dart';
import 'dart:async';

part 'offline_providers.g.dart';

// ============================================
// LOCAL DATABASE PROVIDERS
// ============================================

@riverpod
LocalDatabaseService localDatabase(LocalDatabaseRef ref) {
  return LocalDatabaseService.instance;
}

@riverpod
PetLocalDB petLocalDB(PetLocalDBRef ref) {
  return PetLocalDB();
}

@riverpod
MedicalRecordLocalDB medicalRecordLocalDB(MedicalRecordLocalDBRef ref) {
  return MedicalRecordLocalDB();
}

@riverpod
ReminderDatabaseService reminderDatabase(ReminderDatabaseRef ref) {
  return ReminderDatabaseService();
}

@riverpod
ActivityLogLocalDB activityLogLocalDB(ActivityLogLocalDBRef ref) {
  return ActivityLogLocalDB();
}

// ============================================
// UNIFIED SYNC SERVICE
// ============================================

class UnifiedSyncService {
  final SupabaseClient supabase;
  final PetLocalDB petLocalDB;
  final MedicalRecordLocalDB medicalRecordLocalDB;
  final ReminderDatabaseService reminderLocalDB;
  final ActivityLogLocalDB activityLogLocalDB;
  final Connectivity connectivity = Connectivity();

  UnifiedSyncService({
    required this.supabase,
    required this.petLocalDB,
    required this.medicalRecordLocalDB,
    required this.reminderLocalDB,
    required this.activityLogLocalDB,
  });

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // PETS SYNC
  Future<void> syncPetsToSupabase() async {
    if (!await hasInternetConnection()) return;

    try {
      final unsyncedPets = await petLocalDB.getUnsyncedPets();

      for (var pet in unsyncedPets) {
        try {
          await supabase.from('pets').upsert(pet.toJson());
          await petLocalDB.markAsSynced(pet.id);
        } catch (e) {
          print('Error syncing pet ${pet.id}: $e');
        }
      }

      print('Synced ${unsyncedPets.length} pets to Supabase');
    } catch (e) {
      print('Error syncing pets to Supabase: $e');
    }
  }

  Future<void> syncPetsFromSupabase(String userId) async {
    if (!await hasInternetConnection()) return;

    try {
      final response = await supabase
          .from('pets')
          .select()
          .eq('owner_id', userId);

      final pets =
          (response as List).map((json) => Pet.fromJson(json)).toList();

      for (var pet in pets) {
        await petLocalDB.upsertPet(pet);
      }

      print('Synced ${pets.length} pets from Supabase');
    } catch (e) {
      print('Error syncing pets from Supabase: $e');
    }
  }

  // MEDICAL RECORDS SYNC
  Future<void> syncMedicalRecordsToSupabase() async {
    if (!await hasInternetConnection()) return;

    try {
      final unsyncedRecords = await medicalRecordLocalDB.getUnsyncedRecords();

      for (var record in unsyncedRecords) {
        try {
          await supabase.from('medical_records').upsert({
            'id': record.id,
            'pet_id': record.petId,
            'record_type': record.recordType,
            'title': record.title,
            'description': record.description,
            'date': record.date.toIso8601String(),
            'veterinarian': record.veterinarian,
            'cost': record.cost,
            'next_due_date': record.nextDueDate?.toIso8601String(),
          });
          await medicalRecordLocalDB.markAsSynced(record.id);
        } catch (e) {
          print('Error syncing medical record ${record.id}: $e');
        }
      }

      print('Synced ${unsyncedRecords.length} medical records to Supabase');
    } catch (e) {
      print('Error syncing medical records to Supabase: $e');
    }
  }

  Future<void> syncMedicalRecordsFromSupabase(String userId) async {
    if (!await hasInternetConnection()) return;

    try {
      final response = await supabase
          .from('medical_records')
          .select('''
            *,
            pets!inner(owner_id)
          ''')
          .eq('pets.owner_id', userId);

      final records =
          (response as List)
              .map((json) => MedicalRecord.fromJson(json))
              .toList();

      for (var record in records) {
        await medicalRecordLocalDB.upsertMedicalRecord(record);
      }

      print('Synced ${records.length} medical records from Supabase');
    } catch (e) {
      print('Error syncing medical records from Supabase: $e');
    }
  }

  // ACTIVITY LOGS SYNC

  Future<void> syncActivityLogsToSupabase() async {
    if (!await hasInternetConnection()) return;

    try {
      final unsyncedLogs = await activityLogLocalDB.getUnsyncedLogs();

      for (var log in unsyncedLogs) {
        try {
          await supabase.from('activity_logs').upsert(log.toSupabaseMap());
          await activityLogLocalDB.markAsSynced(log.id);
        } catch (e) {
          print('Error syncing activity log ${log.id}: $e');
        }
      }

      print('Synced ${unsyncedLogs.length} activity logs to Supabase');
    } catch (e) {
      print('Error syncing activity logs to Supabase: $e');
    }
  }

  Future<void> syncActivityLogsFromSupabase(String userId) async {
    if (!await hasInternetConnection()) return;

    try {
      final response = await supabase
          .from('activity_logs')
          .select('''
          *,
          pets!inner(owner_id)
        ''')
          .eq('pets.owner_id', userId);

      final logs =
          (response as List)
              .map((json) => ActivityLog.fromSupabase(json))
              .toList();

      for (var log in logs) {
        await activityLogLocalDB.upsertActivityLog(log);
      }

      print('Synced ${logs.length} activity logs from Supabase');
    } catch (e) {
      print('Error syncing activity logs from Supabase: $e');
    }
  }

  // REMINDERS SYNC
  Future<void> syncRemindersToSupabase() async {
    if (!await hasInternetConnection()) return;

    try {
      final unsyncedReminders = await reminderLocalDB.getUnsyncedReminders();

      for (var reminder in unsyncedReminders) {
        try {
          await supabase.from('reminders').upsert(reminder.toSupabaseMap());
          await reminderLocalDB.markAsSynced(reminder.id!);
        } catch (e) {
          print('Error syncing reminder ${reminder.id}: $e');
        }
      }

      print('Synced ${unsyncedReminders.length} reminders to Supabase');
    } catch (e) {
      print('Error syncing reminders to Supabase: $e');
    }
  }

  Future<void> syncRemindersFromSupabase(String userId) async {
    if (!await hasInternetConnection()) return;

    try {
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

      for (var reminder in reminders) {
        await reminderLocalDB.upsertReminder(reminder);
      }

      print('Synced ${reminders.length} reminders from Supabase');
    } catch (e) {
      print('Error syncing reminders from Supabase: $e');
    }
  }

  // FULL SYNC
  Future<void> fullSync(String userId) async {
    if (!await hasInternetConnection()) {
      print('No internet connection. Working offline.');
      return;
    }

    try {
      print('Starting full sync...');

      // Upload all local changes first
      await syncPetsToSupabase();
      await syncMedicalRecordsToSupabase();
      await syncRemindersToSupabase();
      await syncActivityLogsToSupabase();

      // Then download latest from Supabase
      await syncPetsFromSupabase(userId);
      await syncMedicalRecordsFromSupabase(userId);
      await syncRemindersFromSupabase(userId);
      await syncActivityLogsFromSupabase(userId);

      print('Full sync completed successfully');
    } catch (e) {
      print('Error during full sync: $e');
    }
  }
}

@riverpod
UnifiedSyncService unifiedSyncService(UnifiedSyncServiceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  final petLocalDB = ref.watch(petLocalDBProvider);
  final medicalRecordLocalDB = ref.watch(medicalRecordLocalDBProvider);
  final reminderLocalDB = ref.watch(reminderDatabaseProvider);
  final activityLogLocalDB = ref.watch(activityLogLocalDBProvider);

  return UnifiedSyncService(
    supabase: supabase,
    petLocalDB: petLocalDB,
    medicalRecordLocalDB: medicalRecordLocalDB,
    reminderLocalDB: reminderLocalDB,
    activityLogLocalDB: activityLogLocalDB,
  );
}

// ============================================
// OFFLINE-FIRST MEDICAL RECORDS PROVIDER
// ============================================

@riverpod
class PetMedicalRecordsOffline extends _$PetMedicalRecordsOffline {
  @override
  Future<List<MedicalRecord>> build(String petId) async {
    // Always read from local DB first
    final medicalRecordLocalDB = ref.watch(medicalRecordLocalDBProvider);
    final localRecords = await medicalRecordLocalDB.getMedicalRecordsForPet(
      petId,
    );

    // Sync in background
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      final syncService = ref.watch(unifiedSyncServiceProvider);
      syncService.syncMedicalRecordsFromSupabase(user.id).catchError((e) {
        print('Background sync error: $e');
      });
    }

    return localRecords;
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    final medicalRecordLocalDB = ref.read(medicalRecordLocalDBProvider);
    await medicalRecordLocalDB.createMedicalRecord(record);

    // Sync in background
    final syncService = ref.read(unifiedSyncServiceProvider);
    syncService.syncMedicalRecordsToSupabase().catchError((e) {
      print('Background sync error: $e');
    });

    ref.invalidateSelf();
  }

  Future<void> deleteMedicalRecord(String recordId) async {
    final medicalRecordLocalDB = ref.read(medicalRecordLocalDBProvider);
    await medicalRecordLocalDB.deleteRecord(recordId);

    // Delete from Supabase if online
    final syncService = ref.read(unifiedSyncServiceProvider);
    if (await syncService.hasInternetConnection()) {
      try {
        await syncService.supabase
            .from('medical_records')
            .delete()
            .eq('id', recordId);
      } catch (e) {
        print('Error deleting from Supabase: $e');
      }
    }

    ref.invalidateSelf();
  }
}

// ============================================
// OFFLINE-FIRST REMINDERS PROVIDERS
// ============================================

@riverpod
Future<List<Reminder>> allRemindersRefresh(AllRemindersRefreshRef ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return db.getAllReminders();
}

@riverpod
Future<List<Reminder>> todayReminders(TodayRemindersRef ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return db.getTodayReminders();
}

@riverpod
Future<List<Reminder>> weeklyReminders(WeeklyRemindersRef ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return db.getRemindersByType('weekly');
}

@riverpod
Future<List<Reminder>> monthlyReminders(MonthlyRemindersRef ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return db.getRemindersByType('monthly');
}

@riverpod
Future<List<Reminder>> allReminders(AllRemindersRef ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return db.getAllReminders();
}

//offline first activity log provider
// @riverpod
// class PetActivityLogsOffline extends _$PetActivityLogsOffline {
//   @override
//   Future<List<ActivityLog>> build(String petId) async {
//     // Always read from local DB first
//     final activityLogDB = ref.watch(activityLogLocalDBProvider);
//     final localLogs = await activityLogDB.getActivityLogsForPet(petId);

//     // Sync in background
//     final user = ref.watch(currentUserProvider);
//     if (user != null) {
//       final syncService = ref.watch(unifiedSyncServiceProvider);
//       syncService.syncActivityLogsFromSupabase(user.id).catchError((e) {
//         print('Background sync error: $e');
//       });
//     }

//     return localLogs;
//   }

//   Future<void> addLog(ActivityLog log) async {
//     final activityLogDB = ref.read(activityLogLocalDBProvider);
//     await activityLogDB.createActivityLog(log);

//     // Sync in background
//     final syncService = ref.read(unifiedSyncServiceProvider);
//     syncService.syncActivityLogsToSupabase().catchError((e) {
//       print('Background sync error: $e');
//     });

//     ref.invalidateSelf();
//   }

//   Future<void> updateLog(ActivityLog log) async {
//     final activityLogDB = ref.read(activityLogLocalDBProvider);
//     await activityLogDB.updateActivityLog(log);

//     // Sync in background
//     final syncService = ref.read(unifiedSyncServiceProvider);
//     syncService.syncActivityLogsToSupabase().catchError((e) {
//       print('Background sync error: $e');
//     });

//     ref.invalidateSelf();
//   }

//   Future<void> deleteLog(String logId) async {
//     final activityLogDB = ref.read(activityLogLocalDBProvider);
//     await activityLogDB.deleteActivityLog(logId);

//     // Delete from Supabase if online
//     final syncService = ref.read(unifiedSyncServiceProvider);
//     if (await syncService.hasInternetConnection()) {
//       try {
//         await syncService.supabase
//             .from('activity_logs')
//             .delete()
//             .eq('id', logId);
//       } catch (e) {
//         print('Error deleting from Supabase: $e');
//       }
//     }

//     ref.invalidateSelf();
//   }
// }

// ============================================
// CONNECTIVITY STATUS PROVIDER
// ============================================

@riverpod
Stream<bool> connectivityStatus(ConnectivityStatusRef ref) async* {
  final connectivity = Connectivity();

  // Initial check
  final result = await connectivity.checkConnectivity();
  yield result != ConnectivityResult.none;

  // Listen to changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield result != ConnectivityResult.none;
  }
}

// ============================================
// SYNC STATUS PROVIDER
// ============================================

@riverpod
class SyncStatus extends _$SyncStatus {
  @override
  Future<Map<String, int>> build() async {
    final petLocalDB = ref.watch(petLocalDBProvider);
    final medicalRecordLocalDB = ref.watch(medicalRecordLocalDBProvider);
    final reminderDB = ref.watch(reminderDatabaseProvider);

    final unsyncedPets = await petLocalDB.getUnsyncedPets();
    final unsyncedRecords = await medicalRecordLocalDB.getUnsyncedRecords();
    final unsyncedReminders = await reminderDB.getUnsyncedReminders();

    return {
      'pets': unsyncedPets.length,
      'medical_records': unsyncedRecords.length,
      'reminders': unsyncedReminders.length,
      'total':
          unsyncedPets.length +
          unsyncedRecords.length +
          unsyncedReminders.length,
    };
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

// ============================================
// MANUAL SYNC TRIGGER
// ============================================

@riverpod
class ManualSync extends _$ManualSync {
  @override
  bool build() => false;

  Future<void> syncNow() async {
    state = true;

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = false;
        return;
      }

      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.fullSync(user.id);

      // Refresh all providers
      ref.invalidate(allRemindersRefreshProvider);
      ref.invalidate(syncStatusProvider);

      print('Manual sync completed');
    } catch (e) {
      print('Manual sync error: $e');
    } finally {
      state = false;
    }
  }
}

// ============================================
// PERIODIC SYNC MANAGER
// ============================================

class PeriodicSyncManager {
  Timer? _syncTimer;
  final UnifiedSyncService syncService;
  final String userId;
  final Duration syncInterval;

  PeriodicSyncManager({
    required this.syncService,
    required this.userId,
    this.syncInterval = const Duration(minutes: 5),
  });

  void start() {
    stop();

    _syncTimer = Timer.periodic(syncInterval, (timer) {
      print('Periodic sync triggered at ${DateTime.now()}');
      syncService.fullSync(userId).catchError((e) {
        print('Periodic sync error: $e');
      });
    });

    print('Periodic sync started (every ${syncInterval.inMinutes} minutes)');
  }

  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('Periodic sync stopped');
  }

  void syncNow() {
    print('Manual sync triggered');
    syncService.fullSync(userId).catchError((e) {
      print('Manual sync error: $e');
    });
  }
}

@riverpod
PeriodicSyncManager periodicSyncManager(
  PeriodicSyncManagerRef ref,
  String userId,
) {
  final syncService = ref.watch(unifiedSyncServiceProvider);
  final manager = PeriodicSyncManager(syncService: syncService, userId: userId);

  // Auto cleanup when disposed
  ref.onDispose(() {
    manager.stop();
  });

  return manager;
}
