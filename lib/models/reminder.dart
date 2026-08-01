// models/reminder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_helpers.dart';

class Reminder {
  final String? id;
  final String petId;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final String reminderType; // daily, weekly, monthly, once
  final String? importanceLevel; // high, medium, low
  final bool isCompleted;
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.petId,
    required this.ownerId,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.reminderType,
    this.importanceLevel,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Reminder.fromFirestore(Map<String, dynamic> data, String id) {
    return Reminder(
      id: id,
      petId: data['petId'] as String,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      reminderDate: timestampToDateOrNow(data['reminderDate']),
      reminderType: data['reminderType'] as String,
      importanceLevel: data['importanceLevel'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: timestampToDateOrNow(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'reminderDate': dateToTimestamp(reminderDate),
      'reminderType': reminderType,
      'importanceLevel': importanceLevel,
      'isCompleted': isCompleted,
      'createdAt': dateToTimestamp(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Reminder copyWith({
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderType,
    String? importanceLevel,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id,
      petId: petId,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderType: reminderType ?? this.reminderType,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
