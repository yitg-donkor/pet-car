// ============================================
// FIXED SQFLITE LOCAL DATABASE
// ============================================

import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
// REMINDER DATABASE SERVICE (FIXED)
// ============================================

class ReminderDatabaseService {
  // Use the shared LocalDatabaseService instance
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

  // Read today's reminders
  Future<List<Reminder>> getTodayReminders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getRemindersByDateRange(startOfDay, endOfDay);
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
