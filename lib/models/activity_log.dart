import 'dart:convert';

class ActivityLog {
  final String id;
  final String petId;
  final String
  activityType; // 'walk', 'meal', 'bathroom', 'medication', 'playtime', 'health', 'grooming', 'vet'
  final String title;
  final String? details;
  final DateTime timestamp;
  final int? duration; // in minutes
  final String? amount; // for meals, medication
  final Map<String, dynamic>? metadata; // flexible JSON for type-specific data
  final bool isHealthRelated;
  final bool isSynced;
  final DateTime lastModified;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.activityType,
    required this.title,
    this.details,
    required this.timestamp,
    this.duration,
    this.amount,
    this.metadata,
    this.isHealthRelated = false,
    this.isSynced = false,
    required this.lastModified,
    required this.createdAt,
  });

  // Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'activity_type': activityType,
      'title': title,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'amount': amount,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
      'is_health_related': isHealthRelated ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'last_modified': lastModified.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from JSON (database)
  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      activityType: json['activity_type'] as String,
      title: json['title'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] as int?,
      amount: json['amount'] as String?,
      metadata:
          json['metadata'] != null
              ? jsonDecode(json['metadata'] as String) as Map<String, dynamic>
              : null,
      isHealthRelated: (json['is_health_related'] as int) == 1,
      isSynced: (json['is_synced'] as int) == 1,
      lastModified: DateTime.parse(json['last_modified'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Create from Supabase (for syncing)
  factory ActivityLog.fromSupabase(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      activityType: json['activity_type'] as String,
      title: json['title'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] as int?,
      amount: json['amount'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isHealthRelated: json['is_health_related'] as bool? ?? false,
      isSynced: true,
      lastModified: DateTime.parse(json['last_modified'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to Supabase format (for syncing)
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'pet_id': petId,
      'activity_type': activityType,
      'title': title,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'amount': amount,
      'metadata': metadata,
      'is_health_related': isHealthRelated,
      'last_modified': lastModified.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ActivityLog copyWith({
    String? id,
    String? petId,
    String? activityType,
    String? title,
    String? details,
    DateTime? timestamp,
    int? duration,
    String? amount,
    Map<String, dynamic>? metadata,
    bool? isHealthRelated,
    bool? isSynced,
    DateTime? lastModified,
    DateTime? createdAt,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      amount: amount ?? this.amount,
      metadata: metadata ?? this.metadata,
      isHealthRelated: isHealthRelated ?? this.isHealthRelated,
      isSynced: isSynced ?? this.isSynced,
      lastModified: lastModified ?? this.lastModified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
