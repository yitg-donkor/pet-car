// ============================================
// FIXED SQFLITE LOCAL DATABASE
// ============================================

import 'dart:convert';

import 'package:pet_care/models/activity_log.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/models/user_profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pet_care.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Change version from 1 to 2
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the activity_logs table from the artifact
      await db.execute('''
  CREATE TABLE activity_logs (
    id TEXT PRIMARY KEY,
    pet_id TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    title TEXT NOT NULL,
    details TEXT,
    timestamp TEXT NOT NULL,
    duration INTEGER,
    amount TEXT,
    metadata TEXT,
    is_health_related INTEGER NOT NULL DEFAULT 0,
    is_synced INTEGER NOT NULL DEFAULT 0,
    last_modified TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
  )
''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Pets table
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        age INTEGER,
        birth_date TEXT,
        weight REAL,
        photo_url TEXT,
        microchip_id TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_modified TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Medical records table
    await db.execute('''
      CREATE TABLE medical_records (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        record_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        veterinarian TEXT,
        cost REAL,
        next_due_date TEXT,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_modified TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        reminder_date TEXT NOT NULL,
        reminder_type TEXT NOT NULL,
        importance_level TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_modified TEXT NOT NULL
      )
    ''');
    await db.execute('''
  CREATE TABLE activity_logs (
    id TEXT PRIMARY KEY,
    pet_id TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    title TEXT NOT NULL,
    details TEXT,
    timestamp TEXT NOT NULL,
    duration INTEGER,
    amount TEXT,
    metadata TEXT,
    is_health_related INTEGER NOT NULL DEFAULT 0,
    is_synced INTEGER NOT NULL DEFAULT 0,
    last_modified TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
  )
''');

    // User profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        username TEXT NOT NULL,
        bio TEXT,
        phone_number TEXT,
        phone_verified INTEGER NOT NULL DEFAULT 0,
        street_address TEXT,
        apartment TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT,
        country TEXT,
        emergency_contact_name TEXT,
        emergency_contact_phone TEXT,
        notification_preferences TEXT,
        avatar_url TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_synced INTEGER NOT NULL DEFAULT 0,
        last_modified TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Sync queue table for tracking failed syncs
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

// ============================================
// PET LOCAL DATABASE OPERATIONS
// ============================================

class PetLocalDB {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  String _generateUuid() {
    return const Uuid().v4();
  }

  Future<String> createPet(Pet pet) async {
    final db = await _dbService.database;
    final id = pet.id.isEmpty ? _generateUuid() : pet.id;

    await db.insert('pets', {
      'id': id,
      'owner_id': pet.ownerId,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'age': pet.age,
      'birth_date': pet.birthDate?.toIso8601String(),
      'weight': pet.weight,
      'photo_url': pet.photoUrl,
      'microchip_id': pet.microchipId,
      'is_synced': 0,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  Future<List<Pet>> getAllPets(String ownerId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'pets',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => Pet.fromJson(map)).toList();
  }

  Future<List<Pet>> getUnsyncedPets() async {
    final db = await _dbService.database;
    final result = await db.query(
      'pets',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return result.map((map) => Pet.fromJson(map)).toList();
  }

  Future<void> updatePet(Pet pet) async {
    final db = await _dbService.database;
    await db.update(
      'pets',
      {
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'age': pet.age,
        'birth_date': pet.birthDate?.toIso8601String(),
        'weight': pet.weight,
        'photo_url': pet.photoUrl,
        'microchip_id': pet.microchipId,
        'is_synced': 0,
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [pet.id],
    );
  }

  Future<void> deletePet(String petId) async {
    final db = await _dbService.database;
    await db.delete('pets', where: 'id = ?', whereArgs: [petId]);
  }

  Future<void> upsertPet(Pet pet) async {
    final db = await _dbService.database;
    await db.insert('pets', {
      'id': pet.id,
      'owner_id': pet.ownerId,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'age': pet.age,
      'birth_date': pet.birthDate?.toIso8601String(),
      'weight': pet.weight,
      'photo_url': pet.photoUrl,
      'microchip_id': pet.microchipId,
      'is_synced': 1,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markAsSynced(String petId) async {
    final db = await _dbService.database;
    await db.update(
      'pets',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [petId],
    );
  }
}

// ============================================
// MEDICAL RECORDS LOCAL DATABASE
// ============================================

class MedicalRecordLocalDB {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  String _generateUuid() {
    return const Uuid().v4();
  }

  Future<String> createMedicalRecord(MedicalRecord record) async {
    final db = await _dbService.database;
    final id = record.id.isEmpty ? _generateUuid() : record.id;

    await db.insert('medical_records', {
      'id': id,
      'pet_id': record.petId,
      'record_type': record.recordType,
      'title': record.title,
      'description': record.description,
      'date': record.date.toIso8601String(),
      'veterinarian': record.veterinarian,
      'cost': record.cost,
      'next_due_date': record.nextDueDate?.toIso8601String(),
      'is_synced': 0,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  Future<List<MedicalRecord>> getMedicalRecordsForPet(String petId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'medical_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'date DESC',
    );

    return result.map((map) => MedicalRecord.fromJson(map)).toList();
  }

  Future<List<MedicalRecord>> getUnsyncedRecords() async {
    final db = await _dbService.database;
    final result = await db.query(
      'medical_records',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return result.map((map) => MedicalRecord.fromJson(map)).toList();
  }

  Future<void> upsertMedicalRecord(MedicalRecord record) async {
    final db = await _dbService.database;
    await db.insert('medical_records', {
      'id': record.id,
      'pet_id': record.petId,
      'record_type': record.recordType,
      'title': record.title,
      'description': record.description,
      'date': record.date.toIso8601String(),
      'veterinarian': record.veterinarian,
      'cost': record.cost,
      'next_due_date': record.nextDueDate?.toIso8601String(),
      'is_synced': 1,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markAsSynced(String recordId) async {
    final db = await _dbService.database;
    await db.update(
      'medical_records',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> deleteRecord(String recordId) async {
    final db = await _dbService.database;
    await db.delete('medical_records', where: 'id = ?', whereArgs: [recordId]);
  }
}

// ============================================
// REMINDER DATABASE SERVICE (UPDATED)
// ============================================

class ReminderDatabaseService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  String _generateUuid() {
    return const Uuid().v4();
  }

  // Create
  Future<String> createReminder(Reminder reminder) async {
    final db = await _dbService.database;
    final id = reminder.id ?? _generateUuid();
    final reminderWithId = reminder.copyWith(
      id: id,
      isSynced: false,
      lastModified: DateTime.now(),
    );

    await db.insert('reminders', reminderWithId.toMap());
    return id;
  }

  // Upsert (for syncing from Supabase)
  Future<void> upsertReminder(Reminder reminder) async {
    final db = await _dbService.database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all
  Future<List<Reminder>> getAllReminders() async {
    final db = await _dbService.database;
    final result = await db.query('reminders', orderBy: 'reminder_date ASC');
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Get unsynced reminders
  Future<List<Reminder>> getUnsyncedReminders() async {
    final db = await _dbService.database;
    final result = await db.query(
      'reminders',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Mark as synced
  Future<void> markAsSynced(String id) async {
    final db = await _dbService.database;
    await db.update(
      'reminders',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Read by date range
  Future<List<Reminder>> getRemindersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final result = await db.query(
      'reminders',
      where: 'reminder_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Read by type
  Future<List<Reminder>> getRemindersByType(String type) async {
    final db = await _dbService.database;
    final result = await db.query(
      'reminders',
      where: 'reminder_type = ?',
      whereArgs: [type],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // UPDATED: Smart getTodayReminders that handles all frequency types
  Future<List<Reminder>> getTodayReminders() async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Get all reminders
    final allReminders = await db.query('reminders');
    final reminders = allReminders.map((map) => Reminder.fromMap(map)).toList();

    final todayReminders = <Reminder>[];

    for (var reminder in reminders) {
      final reminderDate = reminder.reminderDate;

      switch (reminder.reminderType) {
        case 'daily':
          // Daily reminders: match if time is today (any date stored, but show every day)
          todayReminders.add(reminder);
          break;

        case 'weekly':
          // Weekly reminders: match if today is the same day of week
          if (reminderDate.weekday == now.weekday) {
            todayReminders.add(reminder);
          }
          break;

        case 'monthly':
          // Monthly reminders: match if today is the same day of month
          if (reminderDate.day == now.day) {
            todayReminders.add(reminder);
          }
          break;

        case 'once':
        default:
          // One-time reminders: match if date is exactly today
          if (reminderDate.isAfter(
                todayStart.subtract(const Duration(seconds: 1)),
              ) &&
              reminderDate.isBefore(todayEnd.add(const Duration(seconds: 1)))) {
            todayReminders.add(reminder);
          }
          break;
      }
    }

    // Sort by time
    todayReminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    return todayReminders;
  }

  // Get this week's reminders (for weekly tab)
  Future<List<Reminder>> getWeeklyReminders() async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final allReminders = await db.query('reminders');
    final reminders = allReminders.map((map) => Reminder.fromMap(map)).toList();

    final weeklyReminders = <Reminder>[];

    for (var reminder in reminders) {
      final reminderDate = reminder.reminderDate;

      switch (reminder.reminderType) {
        case 'daily':
          // Daily reminders show every day, so include them
          weeklyReminders.add(reminder);
          break;

        case 'weekly':
          // Weekly reminders: include all
          weeklyReminders.add(reminder);
          break;

        case 'monthly':
          // Monthly reminders: include if day falls within this week
          final thisWeekDates = List.generate(
            7,
            (i) => startOfWeek.add(Duration(days: i)),
          );
          if (thisWeekDates.any((date) => date.day == reminderDate.day)) {
            weeklyReminders.add(reminder);
          }
          break;

        case 'once':
        default:
          // One-time reminders: include if within this week
          if (reminderDate.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ) &&
              reminderDate.isBefore(
                endOfWeek.add(const Duration(seconds: 1)),
              )) {
            weeklyReminders.add(reminder);
          }
          break;
      }
    }

    weeklyReminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    return weeklyReminders;
  }

  // Get this month's reminders (for monthly tab)
  Future<List<Reminder>> getMonthlyReminders() async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final allReminders = await db.query('reminders');
    final reminders = allReminders.map((map) => Reminder.fromMap(map)).toList();

    final monthlyReminders = <Reminder>[];

    for (var reminder in reminders) {
      final reminderDate = reminder.reminderDate;

      switch (reminder.reminderType) {
        case 'daily':
          // Daily reminders show every day
          monthlyReminders.add(reminder);
          break;

        case 'weekly':
          // Weekly reminders: show all (they repeat every week)
          monthlyReminders.add(reminder);
          break;

        case 'monthly':
          // Monthly reminders: show all
          monthlyReminders.add(reminder);
          break;

        case 'once':
        default:
          // One-time reminders: include if within this month
          if (reminderDate.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ) &&
              reminderDate.isBefore(
                endOfMonth.add(const Duration(seconds: 1)),
              )) {
            monthlyReminders.add(reminder);
          }
          break;
      }
    }

    monthlyReminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    return monthlyReminders;
  }

  // Update
  Future<int> updateReminder(Reminder reminder) async {
    final db = await _dbService.database;
    final updatedReminder = reminder.copyWith(
      isSynced: false,
      lastModified: DateTime.now(),
    );
    return db.update(
      'reminders',
      updatedReminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Toggle completion
  Future<int> toggleCompletion(String id, bool isCompleted) async {
    final db = await _dbService.database;
    return db.update(
      'reminders',
      {
        'is_completed': isCompleted ? 1 : 0,
        'is_synced': 0,
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add to ReminderDatabaseService in sqflite_db.dart

  Future<void> resetRecurringReminders() async {
    final db = await _dbService.database;
    final now = DateTime.now();

    // Get all completed reminders
    final result = await db.query(
      'reminders',
      where: 'is_completed = ?',
      whereArgs: [1],
    );

    final reminders = result.map((map) => Reminder.fromMap(map)).toList();

    for (var reminder in reminders) {
      bool shouldReset = false;
      DateTime newDate = reminder.reminderDate;

      switch (reminder.reminderType) {
        case 'daily':
          // Reset if it's a new day
          if (reminder.reminderDate.day != now.day ||
              reminder.reminderDate.month != now.month ||
              reminder.reminderDate.year != now.year) {
            shouldReset = true;
            newDate = DateTime(
              now.year,
              now.month,
              now.day,
              reminder.reminderDate.hour,
              reminder.reminderDate.minute,
            );
          }
          break;

        case 'weekly':
          // Reset if a week has passed
          final daysSinceCompleted =
              now.difference(reminder.reminderDate).inDays;
          if (daysSinceCompleted >= 7) {
            shouldReset = true;
            // Move to next occurrence of that weekday
            int daysToAdd = 7 - (daysSinceCompleted % 7);
            if (daysToAdd == 7) daysToAdd = 0;
            newDate = now.add(Duration(days: daysToAdd));
            newDate = DateTime(
              newDate.year,
              newDate.month,
              newDate.day,
              reminder.reminderDate.hour,
              reminder.reminderDate.minute,
            );
          }
          break;

        case 'monthly':
          // Reset if a month has passed
          if (reminder.reminderDate.month != now.month ||
              reminder.reminderDate.year != now.year) {
            shouldReset = true;
            // Keep same day of month, update to current/next month
            int targetMonth = now.month;
            int targetYear = now.year;
            if (reminder.reminderDate.day < now.day) {
              targetMonth++;
              if (targetMonth > 12) {
                targetMonth = 1;
                targetYear++;
              }
            }
            newDate = DateTime(
              targetYear,
              targetMonth,
              reminder.reminderDate.day,
              reminder.reminderDate.hour,
              reminder.reminderDate.minute,
            );
          }
          break;

        case 'once':
          // One-time reminders never reset
          break;
      }

      if (shouldReset) {
        await db.update(
          'reminders',
          {
            'is_completed': 0,
            'reminder_date': newDate.toIso8601String(),
            'is_synced': 0,
            'last_modified': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [reminder.id],
        );
      }
    }
  }

  // Delete
  Future<int> deleteReminder(String id) async {
    final db = await _dbService.database;
    return db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all (for fresh sync)
  Future<void> clearAll() async {
    final db = await _dbService.database;
    await db.delete('reminders');
  }

  // Close database
  Future<void> close() async {
    final db = await _dbService.database;
    db.close();
  }
}

class ActivityLogLocalDB {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  String _generateUuid() {
    return const Uuid().v4();
  }

  // Create
  Future<String> createActivityLog(ActivityLog log) async {
    final db = await _dbService.database;
    final id = log.id.isEmpty ? _generateUuid() : log.id;

    await db.insert('activity_logs', {
      'id': id,
      'pet_id': log.petId,
      'activity_type': log.activityType,
      'title': log.title,
      'details': log.details,
      'timestamp': log.timestamp.toIso8601String(),
      'duration': log.duration,
      'amount': log.amount,
      'metadata': log.metadata != null ? jsonEncode(log.metadata) : null,
      'is_health_related': log.isHealthRelated ? 1 : 0,
      'is_synced': 0,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  // Get all logs for a pet
  Future<List<ActivityLog>> getActivityLogsForPet(String petId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'activity_logs',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Get logs by date range
  Future<List<ActivityLog>> getLogsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;
    final result = await db.query(
      'activity_logs',
      where: 'pet_id = ? AND timestamp BETWEEN ? AND ?',
      whereArgs: [
        petId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Get health-related logs
  Future<List<ActivityLog>> getHealthLogs(String petId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'activity_logs',
      where: 'pet_id = ? AND is_health_related = ?',
      whereArgs: [petId, 1],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Get logs by activity type
  Future<List<ActivityLog>> getLogsByType(
    String petId,
    String activityType,
  ) async {
    final db = await _dbService.database;
    final result = await db.query(
      'activity_logs',
      where: 'pet_id = ? AND activity_type = ?',
      whereArgs: [petId, activityType],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Get all logs for an owner (across all pets)
  Future<List<ActivityLog>> getAllLogsForOwner(String ownerId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      '''
      SELECT activity_logs.* 
      FROM activity_logs
      INNER JOIN pets ON activity_logs.pet_id = pets.id
      WHERE pets.owner_id = ?
      ORDER BY activity_logs.timestamp DESC
    ''',
      [ownerId],
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Get unsynced logs
  Future<List<ActivityLog>> getUnsyncedLogs() async {
    final db = await _dbService.database;
    final result = await db.query(
      'activity_logs',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return result.map((map) => ActivityLog.fromJson(map)).toList();
  }

  // Update log
  Future<void> updateActivityLog(ActivityLog log) async {
    final db = await _dbService.database;
    await db.update(
      'activity_logs',
      {
        'activity_type': log.activityType,
        'title': log.title,
        'details': log.details,
        'timestamp': log.timestamp.toIso8601String(),
        'duration': log.duration,
        'amount': log.amount,
        'metadata': log.metadata != null ? jsonEncode(log.metadata) : null,
        'is_health_related': log.isHealthRelated ? 1 : 0,
        'is_synced': 0,
        'last_modified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  // Delete log
  Future<void> deleteActivityLog(String logId) async {
    final db = await _dbService.database;
    await db.delete('activity_logs', where: 'id = ?', whereArgs: [logId]);
  }

  // Upsert (for syncing from Supabase)
  Future<void> upsertActivityLog(ActivityLog log) async {
    final db = await _dbService.database;
    await db.insert(
      'activity_logs',
      log.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Mark as synced
  Future<void> markAsSynced(String logId) async {
    final db = await _dbService.database;
    await db.update(
      'activity_logs',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [logId],
    );
  }

  // Close database
}

class ProfileLocalDB {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  String _generateUuid() {
    return const Uuid().v4();
  }

  // CREATE
  Future<String> createProfile(UserProfile profile) async {
    final db = await _dbService.database;
    final id = profile.id.isEmpty ? _generateUuid() : profile.id;

    await db.insert('profiles', {
      'id': id,
      'full_name': profile.fullName,
      'username': profile.username,
      'bio': profile.bio,
      'phone_number': profile.phoneNumber,
      'phone_verified': profile.phoneVerified ? 1 : 0,
      'street_address': profile.streetAddress,
      'apartment': profile.apartment,
      'city': profile.city,
      'state': profile.state,
      'zip_code': profile.zipCode,
      'country': profile.country,
      'emergency_contact_name': profile.emergencyContactName,
      'emergency_contact_phone': profile.emergencyContactPhone,
      'notification_preferences': profile.notificationPreferences,
      'avatar_url': profile.avatarUrl,
      'is_active': profile.isActive ? 1 : 0,
      'is_synced': 0,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    return id;
  }

  // READ - Get profile by ID
  Future<UserProfile?> getProfileById(String id) async {
    final db = await _dbService.database;
    final result = await db.query('profiles', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return UserProfile.fromJson(result.first);
  }

  // READ - Get all profiles
  Future<List<UserProfile>> getAllProfiles() async {
    final db = await _dbService.database;
    final result = await db.query('profiles', orderBy: 'created_at DESC');
    return result.map((map) => UserProfile.fromJson(map)).toList();
  }

  // READ - Get unsynced profiles
  Future<List<UserProfile>> getUnsyncedProfiles() async {
    final db = await _dbService.database;
    final result = await db.query(
      'profiles',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => UserProfile.fromJson(map)).toList();
  }

  // UPDATE
  Future<int> updateProfile(UserProfile profile) async {
    final db = await _dbService.database;
    return db.update(
      'profiles',
      {
        'full_name': profile.fullName,
        'username': profile.username,
        'bio': profile.bio,
        'phone_number': profile.phoneNumber,
        'phone_verified': profile.phoneVerified ? 1 : 0,
        'street_address': profile.streetAddress,
        'apartment': profile.apartment,
        'city': profile.city,
        'state': profile.state,
        'zip_code': profile.zipCode,
        'country': profile.country,
        'emergency_contact_name': profile.emergencyContactName,
        'emergency_contact_phone': profile.emergencyContactPhone,
        'notification_preferences': profile.notificationPreferences,
        'avatar_url': profile.avatarUrl,
        'is_active': profile.isActive ? 1 : 0,
        'is_synced': 0,
        'last_modified': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // UPSERT (for syncing from Supabase)
  Future<void> upsertProfile(UserProfile profile) async {
    final db = await _dbService.database;
    await db.insert('profiles', {
      'id': profile.id,
      'full_name': profile.fullName,
      'username': profile.username,
      'bio': profile.bio,
      'phone_number': profile.phoneNumber,
      'phone_verified': profile.phoneVerified ? 1 : 0,
      'street_address': profile.streetAddress,
      'apartment': profile.apartment,
      'city': profile.city,
      'state': profile.state,
      'zip_code': profile.zipCode,
      'country': profile.country,
      'emergency_contact_name': profile.emergencyContactName,
      'emergency_contact_phone': profile.emergencyContactPhone,
      'notification_preferences': profile.notificationPreferences,
      'avatar_url': profile.avatarUrl,
      'is_active': profile.isActive ? 1 : 0,
      'is_synced': 1,
      'last_modified': DateTime.now().toIso8601String(),
      'created_at': profile.createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // DELETE
  Future<int> deleteProfile(String id) async {
    final db = await _dbService.database;
    return db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  // Mark as synced
  Future<void> markAsSynced(String id) async {
    final db = await _dbService.database;
    await db.update(
      'profiles',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
