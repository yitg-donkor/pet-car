// ============================================
// 4. UNIFIED SYNC SERVICE
// ============================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnifiedSyncService {
  final SupabaseClient supabase;
  final PetLocalDB petLocalDB;
  final MedicalRecordLocalDB medicalRecordLocalDB;
  final ReminderDatabaseService reminderLocalDB;
  final Connectivity connectivity = Connectivity();

  UnifiedSyncService({
    required this.supabase,
    required this.petLocalDB,
    required this.medicalRecordLocalDB,
    required this.reminderLocalDB,
  });

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // ============================================
  // PETS SYNC
  // ============================================

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

  // ============================================
  // MEDICAL RECORDS SYNC
  // ============================================

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

  // ============================================
  // REMINDERS SYNC (Reusing existing)
  // ============================================

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

  // ============================================
  // FULL SYNC (All Data)
  // ============================================

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

      // Then download latest from Supabase
      await syncPetsFromSupabase(userId);
      await syncMedicalRecordsFromSupabase(userId);
      await syncRemindersFromSupabase(userId);

      print('Full sync completed successfully');
    } catch (e) {
      print('Error during full sync: $e');
    }
  }

  // ============================================
  // PERIODIC SYNC (Call this every X minutes)
  // ============================================

  Future<void> periodicSync(String userId) async {
    print('Running periodic sync...');
    await fullSync(userId);
  }
}
