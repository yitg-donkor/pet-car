// providers/offline_providers.dart
import 'package:pet_care/models/user_profile.dart';

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

@riverpod
ProfileLocalDB profileLocalDB(ProfileLocalDBRef ref) {
  return ProfileLocalDB();
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
  final ProfileLocalDB profileLocalDB;
  final Connectivity connectivity = Connectivity();

  UnifiedSyncService({
    required this.supabase,
    required this.petLocalDB,
    required this.medicalRecordLocalDB,
    required this.reminderLocalDB,
    required this.activityLogLocalDB,
    required this.profileLocalDB,
  });

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncProfilesToSupabase() async {
    if (!await hasInternetConnection()) return;

    try {
      final unsyncedProfiles = await profileLocalDB.getUnsyncedProfiles();

      for (var profile in unsyncedProfiles) {
        try {
          await supabase.from('profiles').upsert(profile.toJson());
          await profileLocalDB.markAsSynced(profile.id);
        } catch (e) {
          print('Error syncing profile ${profile.id}: $e');
        }
      }

      print('Synced ${unsyncedProfiles.length} profiles to Supabase');
    } catch (e) {
      print('Error syncing profiles to Supabase: $e');
    }
  }

  Future<void> syncProfilesFromSupabase(String userId) async {
    if (!await hasInternetConnection()) return;

    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();

      final profile = UserProfile.fromJson(response);
      await profileLocalDB.upsertProfile(profile);

      print('Synced profile from Supabase');
    } catch (e) {
      print('Error syncing profile from Supabase: $e');
    }
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
          // Get the pet to verify it exists (ownership is checked via RLS)
          final pet = await petLocalDB.getPetById(record.petId);
          if (pet == null) {
            print('Pet not found for medical record ${record.id}');
            continue;
          }

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
      print('📤 Found ${unsyncedReminders.length} unsynced reminders');

      for (var reminder in unsyncedReminders) {
        try {
          // Get the pet to verify it exists
          final pet = await petLocalDB.getPetById(reminder.petId);

          if (pet == null) {
            print(
              '❌ Pet not found for reminder ${reminder.id} with pet_id: ${reminder.petId}',
            );
            continue;
          }

          print(
            '✅ Found pet: ${pet.name} (id: ${pet.id}, owner: ${pet.ownerId})',
          );

          final reminderMap = reminder.toSupabaseMap();

          print('📦 Attempting to upsert reminder:');
          print('   ID: ${reminderMap['id']}');
          print('   Pet ID: ${reminderMap['pet_id']}');
          print('   Title: ${reminderMap['title']}');
          print('   User should be: ${pet.ownerId}');

          // Try to upsert
          final result = await supabase.from('reminders').upsert(reminderMap);

          print('✅ Successfully synced reminder ${reminder.id}');
          await reminderLocalDB.markAsSynced(reminder.id!);
        } catch (e) {
          print('❌ Error syncing reminder ${reminder.id}');
          print('   Error type: ${e.runtimeType}');
          print('   Error: $e');
        }
      }

      print('✅ Synced ${unsyncedReminders.length} reminders to Supabase');
    } catch (e) {
      print('❌ Error in syncRemindersToSupabase: $e');
    }
  }

  // Also add this to help verify policies are working
  Future<void> testRLSPolicy() async {
    try {
      print('\n🔍 Testing RLS policy...');

      // This should work if user owns the pet
      final testResult = await supabase
          .from('reminders')
          .select('id, pet_id')
          .limit(1);

      print('✅ SELECT policy works - can read reminders');

      // Try to see what's happening
      final petsResult = await supabase
          .from('pets')
          .select('id, owner_id')
          .limit(3);

      print('✅ User\'s pets: ${petsResult.length}');
      for (var pet in petsResult) {
        print('   - Pet: ${pet['id']}, Owner: ${pet['owner_id']}');
      }
    } catch (e) {
      print('❌ Error testing RLS: $e');
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
      await syncProfilesToSupabase();

      // Then download latest from Supabase
      await syncPetsFromSupabase(userId);
      await syncMedicalRecordsFromSupabase(userId);
      await syncRemindersFromSupabase(userId);
      await syncActivityLogsFromSupabase(userId);
      await syncProfilesFromSupabase(userId);

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
  final profileLocalDB = ref.watch(profileLocalDBProvider);

  final activityLogLocalDB = ref.watch(activityLogLocalDBProvider);

  return UnifiedSyncService(
    supabase: supabase,
    petLocalDB: petLocalDB,
    medicalRecordLocalDB: medicalRecordLocalDB,
    reminderLocalDB: reminderLocalDB,
    activityLogLocalDB: activityLogLocalDB,
    profileLocalDB: profileLocalDB,
  );
}

// ============================================
// OFFLINE-FIRST PETS PROVIDER (ADDED HERE)
// ============================================

@riverpod
class PetsOffline extends _$PetsOffline {
  @override
  Future<List<Pet>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    print('🔵 PetsOffline: Loading pets for user ${user.id}');

    // ALWAYS read from local DB first - this is the source of truth
    final petLocalDB = ref.watch(petLocalDBProvider);
    final localPets = await petLocalDB.getAllPets(user.id);

    print('🔵 PetsOffline: Found ${localPets.length} pets in local DB');

    // Trigger background sync WITHOUT awaiting it
    Future.microtask(() async {
      try {
        print('🔵 PetsOffline: Starting background sync');
        final syncService = ref.read(unifiedSyncServiceProvider);

        // Sync both ways
        await syncService.syncPetsToSupabase(); // Upload local changes
        await syncService.syncPetsFromSupabase(
          user.id,
        ); // Download remote changes

        // Check if there are changes after sync
        final updatedPets = await petLocalDB.getAllPets(user.id);
        print('🔵 PetsOffline: After sync, have ${updatedPets.length} pets');

        if (updatedPets.length != localPets.length) {
          print('🔵 PetsOffline: Pet count changed, refreshing UI');
          ref.invalidateSelf();
        }
      } catch (e) {
        print('🔴 PetsOffline: Background sync error: $e');
      }
    });

    return localPets;
  }

  Future<void> addPet(Pet pet) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('User not logged in');

    print('🔵 PetsOffline: Adding pet ${pet.name}');

    final petLocalDB = ref.read(petLocalDBProvider);
    final petWithOwner = Pet(
      id: '',
      ownerId: user.id,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      birthDate: pet.birthDate,
      weight: pet.weight,
      photoUrl: pet.photoUrl,
      microchipId: pet.microchipId,
    );

    // Save to local DB first
    final petId = await petLocalDB.createPet(petWithOwner);
    print('🔵 PetsOffline: Pet saved locally with ID: $petId');

    // Immediately update UI
    ref.invalidateSelf();

    // Sync in background
    Future.microtask(() async {
      try {
        print('🔵 PetsOffline: Syncing new pet to Supabase');
        final syncService = ref.read(unifiedSyncServiceProvider);
        await syncService.syncPetsToSupabase();
        print('🔵 PetsOffline: Pet synced successfully');
      } catch (e) {
        print('🔴 PetsOffline: Background sync error: $e');
      }
    });
  }

  Future<void> updatePet(Pet pet) async {
    print('🔵 PetsOffline: Updating pet ${pet.name}');

    final petLocalDB = ref.read(petLocalDBProvider);
    await petLocalDB.updatePet(pet);

    // Immediately update UI
    ref.invalidateSelf();

    // Sync in background
    Future.microtask(() async {
      try {
        final syncService = ref.read(unifiedSyncServiceProvider);
        await syncService.syncPetsToSupabase();
      } catch (e) {
        print('🔴 PetsOffline: Background sync error: $e');
      }
    });
  }

  Future<void> deletePet(String petId) async {
    print('🔵 PetsOffline: Deleting pet $petId');

    final petLocalDB = ref.read(petLocalDBProvider);
    await petLocalDB.deletePet(petId);

    // Immediately update UI
    ref.invalidateSelf();

    // Delete from Supabase in background if online
    Future.microtask(() async {
      try {
        final syncService = ref.read(unifiedSyncServiceProvider);
        if (await syncService.hasInternetConnection()) {
          await syncService.supabase.from('pets').delete().eq('id', petId);
          print('🔵 PetsOffline: Pet deleted from Supabase');
        }
      } catch (e) {
        print('🔴 PetsOffline: Error deleting from Supabase: $e');
      }
    });
  }

  Future<void> manualSync() async {
    print('🔵 PetsOffline: Manual sync triggered');

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final syncService = ref.read(unifiedSyncServiceProvider);
    await syncService.fullSync(user.id);
    ref.invalidateSelf();

    print('🔵 PetsOffline: Manual sync completed');
  }
}

@riverpod
class SelectedPet extends _$SelectedPet {
  @override
  Pet? build() {
    return null;
  }

  void selectPet(Pet pet) {
    state = pet;
  }

  void clearSelection() {
    state = null;
  }
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
      ref.invalidate(petsOfflineProvider);
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
