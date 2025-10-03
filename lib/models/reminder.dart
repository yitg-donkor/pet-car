class Reminder {
  final String? id;
  final String petId;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final String reminderType; // daily, weekly, monthly, once
  final String? importanceLevel; // high, medium, low
  final bool isCompleted;
  final DateTime createdAt;
  final bool isSynced; // Track sync status
  final DateTime? lastModified;

  Reminder({
    this.id,
    required this.petId,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.reminderType,
    this.importanceLevel,
    this.isCompleted = false,
    DateTime? createdAt,
    this.isSynced = false,
    this.lastModified,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'description': description,
      'reminder_date': reminderDate.toIso8601String(),
      'reminder_type': reminderType,
      'importance_level': importanceLevel,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'last_modified': (lastModified ?? DateTime.now()).toIso8601String(),
    };
  }

  // For Supabase (without local-only fields)
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'pet_id': petId,
      'title': title,
      'description': description,
      'reminder_date': reminderDate.toIso8601String(),
      'reminder_type': reminderType,
      'importance_level': importanceLevel,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      petId: map['pet_id'],
      title: map['title'],
      description: map['description'],
      reminderDate: DateTime.parse(map['reminder_date']),
      reminderType: map['reminder_type'],
      importanceLevel: map['importance_level'],
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
      createdAt: DateTime.parse(map['created_at']),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      lastModified:
          map['last_modified'] != null
              ? DateTime.parse(map['last_modified'])
              : null,
    );
  }

  factory Reminder.fromSupabase(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      petId: map['pet_id'],
      title: map['title'],
      description: map['description'],
      reminderDate: DateTime.parse(map['reminder_date']),
      reminderType: map['reminder_type'],
      importanceLevel: map['importance_level'],
      isCompleted: map['is_completed'] == true,
      createdAt: DateTime.parse(map['created_at']),
      isSynced: true, // From Supabase, so it's synced
      lastModified: DateTime.now(),
    );
  }

  Reminder copyWith({
    String? id,
    String? petId,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderType,
    String? importanceLevel,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isSynced,
    DateTime? lastModified,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderType: reminderType ?? this.reminderType,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
