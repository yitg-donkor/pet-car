// models/activity_log.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_helpers.dart';

class ActivityLog {
  final String id;
  final String petId;
  final String ownerId;
  final String
  activityType; // 'walk', 'meal', 'bathroom', 'medication', 'playtime', 'health', 'grooming', 'vet'
  final String title;
  final String? details;
  final DateTime timestamp;
  final int? duration; // in minutes
  final String? amount; // for meals, medication
  final Map<String, dynamic>? metadata; // flexible, type-specific data
  final bool isHealthRelated;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.activityType,
    required this.title,
    this.details,
    required this.timestamp,
    this.duration,
    this.amount,
    this.metadata,
    this.isHealthRelated = false,
    required this.createdAt,
  });

  factory ActivityLog.fromFirestore(Map<String, dynamic> data, String id) {
    return ActivityLog(
      id: id,
      petId: data['petId'] as String,
      ownerId: data['ownerId'] as String,
      activityType: data['activityType'] as String,
      title: data['title'] as String,
      details: data['details'] as String?,
      timestamp: timestampToDateOrNow(data['timestamp']),
      duration: data['duration'] as int?,
      amount: data['amount'] as String?,
      // Firestore stores maps natively - no jsonEncode/jsonDecode needed.
      metadata: (data['metadata'] as Map<String, dynamic>?),
      isHealthRelated: data['isHealthRelated'] as bool? ?? false,
      createdAt: timestampToDateOrNow(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'activityType': activityType,
      'title': title,
      'details': details,
      'timestamp': dateToTimestamp(timestamp),
      'duration': duration,
      'amount': amount,
      'metadata': metadata,
      'isHealthRelated': isHealthRelated,
      'createdAt': dateToTimestamp(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ActivityLog copyWith({
    String? activityType,
    String? title,
    String? details,
    DateTime? timestamp,
    int? duration,
    String? amount,
    Map<String, dynamic>? metadata,
    bool? isHealthRelated,
  }) {
    return ActivityLog(
      id: id,
      petId: petId,
      ownerId: ownerId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      amount: amount ?? this.amount,
      metadata: metadata ?? this.metadata,
      isHealthRelated: isHealthRelated ?? this.isHealthRelated,
      createdAt: createdAt,
    );
  }
}
