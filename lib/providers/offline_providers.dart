export 'auth_providers.dart';
export 'firestore_providers.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity_log.dart';
import '../models/medical_record.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/user_profile.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';

class UnifiedSyncService {
  UnifiedSyncService(this.ref);

  final Ref ref;
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> fullSync(String userId) async {
    await Future<void>.value();
  }

  Future<bool> hasInternetConnection() async => true;

  Future<void> syncRemindersToSupabase() async {
    await Future<void>.value();
  }

  Future<void> syncMedicalRecordsToSupabase() async {
    await Future<void>.value();
  }
}

final unifiedSyncServiceProvider = Provider<UnifiedSyncService>(
  (ref) => UnifiedSyncService(ref),
);

class ProfileLocalDB {
  ProfileLocalDB(this.ref);

  final Ref ref;

  Future<UserProfile?> getProfileById(String userId) async {
    return ref.read(userProfileRepositoryProvider).get(userId);
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await ref.read(userProfileRepositoryProvider).set(profile.id, profile);
  }
}

final profileLocalDBProvider = Provider<ProfileLocalDB>(
  (ref) => ProfileLocalDB(ref),
);

class ReminderDatabase {
  ReminderDatabase(this.ref);

  final Ref ref;

  Future<List<Reminder>> getAllReminders() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return const [];

    final repo = ref.read(reminderRepositoryProvider);
    return repo.fetch((query) => query.where('ownerId', isEqualTo: user.uid));
  }

  Future<String> createReminder(Reminder reminder) async {
    final repo = ref.read(reminderRepositoryProvider);
    return repo.add(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await ref.read(reminderRepositoryProvider).delete(id);
  }

  Future<void> toggleCompletion(String reminderId, bool isCompleted) async {
    await ref.read(reminderRepositoryProvider).update(reminderId, {
      'isCompleted': isCompleted,
      'isSynced': false,
    });
  }

  Future<void> deleteRecord(String id) => deleteReminder(id);
}

final reminderDatabaseProvider = Provider<ReminderDatabase>(
  (ref) => ReminderDatabase(ref),
);

class CompatMedicalRecordLocalDB {
  CompatMedicalRecordLocalDB(this.ref);

  final Ref ref;

  Future<List<MedicalRecord>> getMedicalRecordsForPet(String petId) async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    return repo.fetch((query) => query.where('petId', isEqualTo: petId));
  }

  Future<void> deleteMedicalRecord(String id) async {
    await ref.read(medicalRecordRepositoryProvider).delete(id);
  }

  Future<String> createMedicalRecord(MedicalRecord record) async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    return repo.add(record);
  }

  Future<void> deleteRecord(String id) async {
    await ref.read(medicalRecordRepositoryProvider).delete(id);
  }
}

final medicalRecordLocalDBProvider = Provider<CompatMedicalRecordLocalDB>(
  (ref) => CompatMedicalRecordLocalDB(ref),
);

class CompatActivityLogLocalDB {
  CompatActivityLogLocalDB(this.ref);

  final Ref ref;

  Future<List<ActivityLog>> getActivityLogsForPet(String petId) async {
    final repo = ref.read(activityLogRepositoryProvider);
    return repo.fetch((query) => query.where('petId', isEqualTo: petId));
  }

  Future<List<ActivityLog>> getAllActivityLogsForOwner(String ownerId) async {
    final repo = ref.read(activityLogRepositoryProvider);
    return repo.fetch((query) => query.where('ownerId', isEqualTo: ownerId));
  }
}

final activityLogLocalDBProvider = Provider<CompatActivityLogLocalDB>(
  (ref) => CompatActivityLogLocalDB(ref),
);

class PetsOfflineNotifier extends AsyncNotifier<List<Pet>> {
  @override
  FutureOr<List<Pet>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const [];

    final repo = ref.read(petRepositoryProvider);
    return repo.fetch(
      (query) => query.where('ownerId', isEqualTo: user.uid).orderBy('name'),
    );
  }

  Future<void> addPet(Pet pet) async {
    await ref.read(petRepositoryProvider).add(pet);
    ref.invalidateSelf();
  }

  Future<void> updatePet(Pet pet) async {
    await ref.read(petRepositoryProvider).set(pet.id, pet);
    ref.invalidateSelf();
  }

  Future<void> deletePet(String petId) async {
    await ref.read(petRepositoryProvider).delete(petId);
    ref.invalidateSelf();
  }
}

final petsOfflineProvider =
    AsyncNotifierProvider<PetsOfflineNotifier, List<Pet>>(
      () => PetsOfflineNotifier(),
    );

class PetMedicalRecordsOfflineNotifier
    extends AsyncNotifier<List<MedicalRecord>> {
  PetMedicalRecordsOfflineNotifier();

  @override
  FutureOr<List<MedicalRecord>> build() async {
    return const [];
  }

  Future<void> loadForPet(String petId) async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    final records = await repo.fetch(
      (query) => query.where('petId', isEqualTo: petId),
    );
    state = AsyncValue.data(records);
  }
}

final petMedicalRecordsOfflineProvider =
    FutureProvider.family<List<MedicalRecord>, String>((ref, petId) async {
      final repo = ref.watch(medicalRecordRepositoryProvider);
      return repo.fetch((query) => query.where('petId', isEqualTo: petId));
    });

final dailyActivityLogsProvider =
    FutureProvider<Map<String, List<ActivityLog>>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return {'today': const [], 'yesterday': const []};

      final repo = ref.watch(activityLogRepositoryProvider);
      final logs = await repo.fetch(
        (query) => query
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true),
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      return {
        'today': logs.where((log) => !log.timestamp.isBefore(today)).toList(),
        'yesterday':
            logs
                .where(
                  (log) =>
                      !log.timestamp.isBefore(yesterday) &&
                      log.timestamp.isBefore(today),
                )
                .toList(),
      };
    });

final healthActivityLogsProvider = FutureProvider<List<ActivityLog>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];

  final repo = ref.watch(activityLogRepositoryProvider);
  return repo.fetch(
    (query) => query
        .where('ownerId', isEqualTo: user.uid)
        .where('isHealthRelated', isEqualTo: true)
        .orderBy('timestamp', descending: true),
  );
});

class ActivityLogsOfflineNotifier extends AsyncNotifier<List<ActivityLog>> {
  @override
  FutureOr<List<ActivityLog>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const [];

    final repo = ref.read(activityLogRepositoryProvider);
    return repo.fetch(
      (query) => query
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true),
    );
  }

  Future<void> addLog(ActivityLog log) async {
    await ref.read(activityLogRepositoryProvider).add(log);
    ref.invalidateSelf();
  }
}

final activityLogsOfflineProvider =
    AsyncNotifierProvider<ActivityLogsOfflineNotifier, List<ActivityLog>>(
      () => ActivityLogsOfflineNotifier(),
    );

class SelectedPetController extends Notifier<Pet?> {
  @override
  Pet? build() => null;

  void selectPet(Pet pet) => state = pet;
  void clearSelection() => state = null;
}

final selectedPetProvider = NotifierProvider<SelectedPetController, Pet?>(
  SelectedPetController.new,
);

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return !results.contains(ConnectivityResult.none);
  });
});

final medicalRecordLocalDB = medicalRecordLocalDBProvider;
final reminderDatabase = reminderDatabaseProvider;
final profileLocalDB = profileLocalDBProvider;
final activityLogDB = activityLogLocalDBProvider;
final petsProvider = petsOfflineProvider;
final selectedPetStateProvider = selectedPetProvider;

final userProfileControllerCompatProvider = userProfileControllerProvider;
