// models/medical_record.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_helpers.dart';

class MedicalRecord {
  final String id;
  final String petId;
  final String ownerId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime date;
  final String? veterinarian;
  final double? cost;
  final DateTime? nextDueDate;

  MedicalRecord({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.recordType,
    required this.title,
    this.description,
    required this.date,
    this.veterinarian,
    this.cost,
    this.nextDueDate,
  });

  factory MedicalRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return MedicalRecord(
      id: id,
      petId: data['petId'] as String,
      ownerId: data['ownerId'] as String,
      recordType: data['recordType'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      date: timestampToDateOrNow(data['date']),
      veterinarian: data['veterinarian'] as String?,
      cost: (data['cost'] as num?)?.toDouble(),
      nextDueDate: timestampToDate(data['nextDueDate']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'recordType': recordType,
      'title': title,
      'description': description,
      'date': dateToTimestamp(date),
      'veterinarian': veterinarian,
      'cost': cost,
      'nextDueDate': dateToTimestamp(nextDueDate),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
