// models/activity_log.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/firestore_helpers.dart';

enum ActivityType {
  walk('walk', 'Walk', Icons.directions_walk, Colors.brown),
  meal('meal', 'Meal', Icons.restaurant, Colors.orange),
  bathroom('bathroom', 'Bathroom', Icons.wc, Colors.blueGrey),
  medication('medication', 'Medication', Icons.medication, Colors.red),
  playtime('playtime', 'Playtime', Icons.toys, Colors.purple),
  health('health', 'Health', Icons.favorite, Colors.green),
  grooming('grooming', 'Grooming', Icons.content_cut, Colors.pink),
  vet('vet', 'Vet', Icons.local_hospital, Colors.teal),
  weight('weight', 'Weight', Icons.monitor_weight, Colors.indigo),
  other('other', 'Other', Icons.event_note, Colors.grey);

  const ActivityType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.other,
    );
  }
}

class ActivityLog {
  final String id;
  final String petId;
  final String ownerId;
  final String activityType;
  final String title;
  final String? details;
  final DateTime timestamp;
  final int? duration;
  final String? amount;
  final Map<String, dynamic>? metadata;
  final bool isHealthRelated;
  final DateTime createdAt;
  final DateTime? lastModified;

  ActivityLog({
    required this.id,
    required this.petId,
    this.ownerId = '',
    required this.activityType,
    required this.title,
    this.details,
    required this.timestamp,
    this.duration,
    this.amount,
    this.metadata,
    this.isHealthRelated = false,
    DateTime? createdAt,
    this.lastModified,
  }) : createdAt = createdAt ?? DateTime.now();

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
      metadata: (data['metadata'] as Map<String, dynamic>?),
      isHealthRelated: data['isHealthRelated'] as bool? ?? false,
      createdAt: timestampToDateOrNow(data['createdAt']),
      lastModified: timestampToDate(data['lastModified']),
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
      'lastModified': dateToTimestamp(lastModified ?? DateTime.now()),
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
    DateTime? lastModified,
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
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
