import 'package:pet_care/models/reminder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class ReminderDatabaseService {
  static final ReminderDatabaseService instance =
      ReminderDatabaseService._init();
  static Database? _database;

  ReminderDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE reminders ADD COLUMN is_synced INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE reminders ADD COLUMN last_modified TEXT');
    }
  }

  // Create
  Future<String> createReminder(Reminder reminder) async {
    final db = await instance.database;
    final id = reminder.id ?? _generateUuid();
    toString();
    final reminderWithId = reminder.copyWith(
      id: id,
      isSynced: false,
      lastModified: DateTime.now(),
    );

    await db.insert('reminders', reminderWithId.toMap());
    return id;
  }

  String _generateUuid() {
    return const Uuid().v4();
  }

  // Upsert (for syncing from Supabase)
  Future<void> upsertReminder(Reminder reminder) async {
    final db = await instance.database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all
  Future<List<Reminder>> getAllReminders() async {
    final db = await instance.database;
    final result = await db.query('reminders', orderBy: 'reminder_date ASC');
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Get unsynced reminders
  Future<List<Reminder>> getUnsyncedReminders() async {
    final db = await instance.database;
    final result = await db.query(
      'reminders',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Mark as synced
  Future<void> markAsSynced(String id) async {
    final db = await instance.database;
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
    final db = await instance.database;
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
    final db = await instance.database;
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
    final db = await instance.database;
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
    final db = await instance.database;
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
    final db = await instance.database;
    return db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all (for fresh sync)
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('reminders');
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
