// models/medical_record.dart
class MedicalRecord {
  final String id;
  final String petId;
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
    required this.recordType,
    required this.title,
    this.description,
    required this.date,
    this.veterinarian,
    this.cost,
    this.nextDueDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      petId: json['pet_id'],
      recordType: json['record_type'],
      title: json['title'],
      description: json['description'],
      date:
          json['date'] is String
              ? DateTime.parse(json['date'])
              : DateTime.fromMillisecondsSinceEpoch((json['date'] as int)),
      veterinarian: json['veterinarian'],
      cost: (json['cost'] != null) ? (json['cost'] as num).toDouble() : null,
      nextDueDate:
          json['next_due_date'] != null
              ? DateTime.parse(json['next_due_date'])
              : null,
    );
  }
}
