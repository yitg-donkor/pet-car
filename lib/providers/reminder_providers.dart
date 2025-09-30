// providers/reminder_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/reminder.dart';
import 'auth_providers.dart';

part 'reminder_providers.g.dart';

@riverpod
class Reminders extends _$Reminders {
  @override
  Future<List<Reminder>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final supabase = ref.watch(supabaseProvider);
    final response = await supabase
        .from('reminders')
        .select('''
          *,
          pets:pet_id (name, species)
        ''')
        .eq('pets.owner_id', user.id)
        .eq('is_completed', false)
        .order('reminder_date');

    return (response as List).map((json) => Reminder.fromJson(json)).toList();
  }

  Future<void> addReminder(Reminder reminder) async {
    final supabase = ref.read(supabaseProvider);

    await supabase.from('reminders').insert({
      'pet_id': reminder.petId,
      'title': reminder.title,
      'description': reminder.description,
      'reminder_date': reminder.reminderDate.toIso8601String(),
      'reminder_type': reminder.reminderType,
    });

    ref.invalidateSelf();
  }

  Future<void> completeReminder(String reminderId) async {
    final supabase = ref.read(supabaseProvider);

    await supabase
        .from('reminders')
        .update({'is_completed': true})
        .eq('id', reminderId);

    ref.invalidateSelf();
  }
}

// Today's reminders provider
@riverpod
Future<List<Reminder>> todaysReminders(TodaysRemindersRef ref) async {
  final allReminders = await ref.watch(remindersProvider.future);
  final today = DateTime.now();

  return allReminders.where((reminder) {
    final reminderDate = reminder.reminderDate;
    return reminderDate.year == today.year &&
        reminderDate.month == today.month &&
        reminderDate.day == today.day;
  }).toList();
}
