// ============================================
// FIRESTORE DATA PROVIDERS
// ============================================
//
// Replaces offline_providers.dart. The old file's job was: read local DB
// first, kick off a background sync, merge results, track is_synced flags.
// Firestore's `.snapshots()` stream already does all of that - it serves
// from the on-device cache instantly and pushes updates as the server
// confirms writes or another device changes something. So each provider
// here is just a thin `watch(...)` on a FirestoreRepository query.
export 'auth_providers.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/activity_log.dart';
import '../models/medical_record.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../services/firestore_repository.dart';
import 'auth_providers.dart';

part 'firestore_providers.g.dart';

// ============================================
// REPOSITORIES
// ============================================

@riverpod
FirestoreRepository<Pet> petRepository(PetRepositoryRef ref) {
  return FirestoreRepository<Pet>(
    collectionPath: 'pets',
    fromFirestore: Pet.fromFirestore,
    toFirestore: (pet) => pet.toFirestore(),
  );
}

@riverpod
FirestoreRepository<MedicalRecord> medicalRecordRepository(
  MedicalRecordRepositoryRef ref,
) {
  return FirestoreRepository<MedicalRecord>(
    collectionPath: 'medical_records',
    fromFirestore: MedicalRecord.fromFirestore,
    toFirestore: (record) => record.toFirestore(),
  );
}

@riverpod
FirestoreRepository<Reminder> reminderRepository(
  ReminderRepositoryRef ref,
) {
  return FirestoreRepository<Reminder>(
    collectionPath: 'reminders',
    fromFirestore: Reminder.fromFirestore,
    toFirestore: (reminder) => reminder.toFirestore(),
  );
}

@riverpod
FirestoreRepository<ActivityLog> activityLogRepository(
  ActivityLogRepositoryRef ref,
) {
  return FirestoreRepository<ActivityLog>(
    collectionPath: 'activity_logs',
    fromFirestore: ActivityLog.fromFirestore,
    toFirestore: (log) => log.toFirestore(),
  );
}

// ============================================
// PETS
// ============================================

@riverpod
Stream<List<Pet>> petsStream(PetsStreamRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(petRepositoryProvider);
  return repo.watch(
    (q) => q.where('ownerId', isEqualTo: user.uid).orderBy('name'),
  );
}

@riverpod
class PetsController extends _$PetsController {
  @override
  Stream<List<Pet>> build() => ref.watch(petsStreamProvider.stream);

  Future<void> addPet(Pet pet) =>
      ref.read(petRepositoryProvider).add(pet);

  Future<void> updatePet(Pet pet) =>
      ref.read(petRepositoryProvider).set(pet.id, pet);

  Future<void> deletePet(String petId) =>
      ref.read(petRepositoryProvider).delete(petId);
}

// ============================================
// MEDICAL RECORDS (per pet)
// ============================================

@riverpod
class PetMedicalRecords extends _$PetMedicalRecords {
  @override
  Stream<List<MedicalRecord>> build(String petId) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Stream.value([]);

    final repo = ref.watch(medicalRecordRepositoryProvider);
    return repo.watch(
      (q) => q
          .where('petId', isEqualTo: petId)
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('date', descending: true),
    );
  }

  Future<void> addRecord(MedicalRecord record) =>
      ref.read(medicalRecordRepositoryProvider).add(record);

  Future<void> deleteRecord(String recordId) =>
      ref.read(medicalRecordRepositoryProvider).delete(recordId);
}

// ============================================
// REMINDERS
// ============================================

@riverpod
Stream<List<Reminder>> allReminders(AllRemindersRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('reminderDate'),
  );
}

@riverpod
Stream<List<Reminder>> todayReminders(TodayRemindersRef ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .where('reminderDate', isGreaterThanOrEqualTo: startOfDay)
        .where('reminderDate', isLessThan: endOfDay)
        .orderBy('reminderDate'),
  );
}

@riverpod
Stream<List<Reminder>> weeklyReminders(WeeklyRemindersRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .where('reminderType', isEqualTo: 'weekly')
        .orderBy('reminderDate'),
  );
}

@riverpod
Stream<List<Reminder>> monthlyReminders(MonthlyRemindersRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .where('reminderType', isEqualTo: 'monthly')
        .orderBy('reminderDate'),
  );
}

@riverpod
class RemindersController extends _$RemindersController {
  @override
  Stream<List<Reminder>> build() => ref.watch(allRemindersProvider.stream);

  Future<void> addReminder(Reminder reminder) =>
      ref.read(reminderRepositoryProvider).add(reminder);

  Future<void> completeReminder(String reminderId, Reminder current) =>
      ref
          .read(reminderRepositoryProvider)
          .update(reminderId, {'isCompleted': true});

  Future<void> deleteReminder(String reminderId) =>
      ref.read(reminderRepositoryProvider).delete(reminderId);
}

// ============================================
// ACTIVITY LOGS
// ============================================

@riverpod
Stream<List<ActivityLog>> activityLogsForOwner(ActivityLogsForOwnerRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(activityLogRepositoryProvider);
  return repo.watch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(200), // paginate further if/when this becomes a bottleneck
  );
}

/// Today's and yesterday's activity logs, split out for the daily log view.
@riverpod
Future<Map<String, List<ActivityLog>>> dailyActivityLogs(
  DailyActivityLogsRef ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'today': const [], 'yesterday': const []};

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final repo = ref.watch(activityLogRepositoryProvider);
  final logs = await repo.fetch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: yesterday)
        .orderBy('timestamp', descending: true),
  );

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
}

/// Activity logs flagged as health-related, across all of the user's pets.
@riverpod
Future<List<ActivityLog>> healthActivityLogs(HealthActivityLogsRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(const []);

  final repo = ref.watch(activityLogRepositoryProvider);
  return repo.fetch(
    (q) => q
        .where('ownerId', isEqualTo: user.uid)
        .where('isHealthRelated', isEqualTo: true)
        .orderBy('timestamp', descending: true),
  );
}

@riverpod
class ActivityLogsController extends _$ActivityLogsController {
  @override
  Stream<List<ActivityLog>> build() =>
      ref.watch(activityLogsForOwnerProvider.stream);

  Future<void> addLog(ActivityLog log) =>
      ref.read(activityLogRepositoryProvider).add(log);

  Future<void> deleteLog(String logId) =>
      ref.read(activityLogRepositoryProvider).delete(logId);
}

// ============================================
// SELECTED PET (local UI state, not persisted)
// ============================================

@riverpod
class SelectedPet extends _$SelectedPet {
  @override
  Pet? build() => null;

  void selectPet(Pet pet) => state = pet;
  void clearSelection() => state = null;
}
