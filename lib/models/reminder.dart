// models/reminder.dart
class Reminder {
  final String id;
  final String petId;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final String reminderType;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.petId,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.reminderType,
    this.isCompleted = false,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      petId: json['pet_id'],
      title: json['title'],
      description: json['description'],
      reminderDate:
          json['reminder_date'] is String
              ? DateTime.parse(json['reminder_date'])
              : DateTime.fromMillisecondsSinceEpoch(
                (json['reminder_date'] as int),
              ),
      reminderType: json['reminder_type'] ?? '',
      isCompleted: json['is_completed'] == true,
    );
  }
}
