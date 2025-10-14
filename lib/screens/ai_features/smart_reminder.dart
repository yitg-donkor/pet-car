import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:intl/intl.dart';

class SmartRemindersScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const SmartRemindersScreen({Key? key, required this.pet}) : super(key: key);

  @override
  ConsumerState<SmartRemindersScreen> createState() =>
      _SmartRemindersScreenState();
}

class _SmartRemindersScreenState extends ConsumerState<SmartRemindersScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  List<Map<String, dynamic>> _aiGeneratedReminders = [];
  bool _isGenerating = false;
  bool _hasNoData = false;

  @override
  void initState() {
    super.initState();
    _generateSmartReminders();
  }

  Future<void> _generateSmartReminders() async {
    setState(() {
      _isGenerating = true;
      _hasNoData = false;
      _aiGeneratedReminders = [];
    });

    try {
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      final reminderDB = ref.read(reminderDatabaseProvider);

      final medicalRecords = await medicalRecordDB.getMedicalRecordsForPet(
        widget.pet.id,
      );
      final existingReminders = await reminderDB.getAllReminders();
      final petReminders =
          existingReminders.where((r) => r.petId == widget.pet.id).toList();

      final prompt = _buildPromptFromData(medicalRecords, petReminders);

      final response = await _aiHelper.generateSmartReminders(prompt);

      final reminders = _parseReminders(response);

      setState(() {
        _aiGeneratedReminders = reminders;
        _hasNoData = reminders.isEmpty && medicalRecords.isEmpty;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating reminders: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _generateSmartReminders,
            ),
          ),
        );
      }
    }
  }

  String _buildPromptFromData(
    List<MedicalRecord> medicalRecords,
    List<Reminder> existingReminders,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('===== PET PROFILE =====');
    buffer.writeln('Name: ${widget.pet.name}');
    buffer.writeln('Species: ${widget.pet.species}');
    if (widget.pet.breed != null) {
      buffer.writeln('Breed: ${widget.pet.breed}');
    }
    if (widget.pet.age != null) {
      buffer.writeln('Age: ${widget.pet.age} years');
    }
    if (widget.pet.weight != null) {
      buffer.writeln('Weight: ${widget.pet.weight} kg');
    }
    buffer.writeln();

    // Medical history with more context
    if (medicalRecords.isNotEmpty) {
      buffer.writeln(
        '===== MEDICAL HISTORY (${medicalRecords.length} records) =====',
      );

      final recordsByType = <String, List<MedicalRecord>>{};
      for (var record in medicalRecords) {
        recordsByType.putIfAbsent(record.recordType, () => []).add(record);
      }

      for (var entry in recordsByType.entries) {
        buffer.writeln('\n${entry.key.toUpperCase()}:');
        for (var record in entry.value.take(5)) {
          buffer.writeln('  • ${record.title} - ${_formatDate(record.date)}');
          if (record.description != null && record.description!.isNotEmpty) {
            buffer.writeln('    Details: ${record.description}');
          }
          if (record.nextDueDate != null) {
            buffer.writeln('    Next due: ${_formatDate(record.nextDueDate!)}');
          }
        }
      }
      buffer.writeln();
    } else {
      buffer.writeln('===== MEDICAL HISTORY =====');
      buffer.writeln(
        'No records available - generate basic preventive care reminders',
      );
      buffer.writeln();
    }

    // Existing reminders with frequency info
    if (existingReminders.isNotEmpty) {
      buffer.writeln(
        '===== EXISTING REMINDERS (${existingReminders.length}) =====',
      );
      buffer.writeln('IMPORTANT: DO NOT duplicate these existing reminders:');
      for (var reminder in existingReminders.take(10)) {
        buffer.writeln(
          '  • ${reminder.title} [${reminder.reminderType}] - ${_formatDate(reminder.reminderDate)}',
        );
      }
      buffer.writeln('\nGenerate DIFFERENT reminders that complement these.');
      buffer.writeln();
    }

    buffer.writeln('===== TASK =====');
    buffer.writeln(
      'Generate 6-10 important care reminders for the next 3 months.',
    );
    buffer.writeln();

    buffer.writeln('===== REMINDER CATEGORIES =====');
    buffer.writeln('1. DAILY CARE (frequency: daily)');
    buffer.writeln('   - Morning/evening feeding schedules');
    buffer.writeln('   - Water bowl refills');
    buffer.writeln('   - Daily medication (if applicable)');
    buffer.writeln('   - Daily exercise/walks');
    buffer.writeln('   - Litter box cleaning (cats)');
    buffer.writeln();

    buffer.writeln('2. WEEKLY CARE (frequency: weekly)');
    buffer.writeln('   - Weekly grooming sessions');
    buffer.writeln('   - Training sessions');
    buffer.writeln('   - Deep cleaning of pet areas');
    buffer.writeln('   - Play time routines');
    buffer.writeln('   - Weight monitoring');
    buffer.writeln();

    buffer.writeln('3. MONTHLY CARE (frequency: monthly)');
    buffer.writeln('   - Flea & tick prevention');
    buffer.writeln('   - Heartworm medication');
    buffer.writeln('   - Nail trimming');
    buffer.writeln('   - Dental checks');
    buffer.writeln('   - Bath time');
    buffer.writeln();

    buffer.writeln('4. ONE-TIME EVENTS (frequency: once)');
    buffer.writeln('   - Annual checkups');
    buffer.writeln('   - Vaccination appointments');
    buffer.writeln('   - Scheduled surgeries/procedures');
    buffer.writeln('   - Follow-up vet visits');
    buffer.writeln('   - Grooming appointments');
    buffer.writeln();

    buffer.writeln('===== FREQUENCY RULES =====');
    buffer.writeln('CRITICAL: Choose the correct frequency for each reminder:');
    buffer.writeln(
      '• "daily" = Task repeats EVERY day (feeding, walks, daily meds)',
    );
    buffer.writeln(
      '• "weekly" = Task repeats EVERY week on specific day (grooming, training)',
    );
    buffer.writeln(
      '• "monthly" = Task repeats EVERY month on specific day (flea control, nail trim)',
    );
    buffer.writeln(
      '• "once" = One-time event (vet appointments, vaccinations)',
    );
    buffer.writeln();

    buffer.writeln('===== DATE CALCULATION =====');
    buffer.writeln('For DAILY reminders: Use 1 day from now');
    buffer.writeln('For WEEKLY reminders: Use 7 days from now');
    buffer.writeln('For MONTHLY reminders: Use 7-30 days from now');
    buffer.writeln(
      'For ONCE reminders: Use appropriate future date (14-90 days)',
    );
    buffer.writeln();

    buffer.writeln('===== SPECIES-SPECIFIC GUIDANCE =====');
    if (widget.pet.species.toLowerCase() == 'dog') {
      buffer.writeln('DOG CARE PRIORITIES:');
      buffer.writeln('• Daily walks (at least 2x per day)');
      buffer.writeln('• Weekly grooming (breed-dependent)');
      buffer.writeln('• Monthly nail trimming');
      buffer.writeln('• Monthly flea/tick prevention');
      buffer.writeln('• Annual vaccinations (rabies, DHPP)');
      buffer.writeln('• Annual dental cleaning');
    } else if (widget.pet.species.toLowerCase() == 'cat') {
      buffer.writeln('CAT CARE PRIORITIES:');
      buffer.writeln('• Daily litter box cleaning');
      buffer.writeln('• Weekly brushing (especially long-haired)');
      buffer.writeln('• Monthly nail trimming');
      buffer.writeln('• Monthly flea prevention');
      buffer.writeln('• Annual vaccinations (FVRCP, rabies)');
      buffer.writeln('• Dental care monitoring');
    }
    buffer.writeln();

    buffer.writeln('===== OUTPUT FORMAT =====');
    buffer.writeln('STRICTLY follow this format (one reminder per line):');
    buffer.writeln();
    buffer.writeln(
      'REMINDER: [Title] | DATE: [days from now] | TYPE: [feeding/exercise/medication/grooming/checkup/vaccination/general] | FREQUENCY: [daily/weekly/monthly/once] | PRIORITY: [high/medium/low] | DESC: [description] | TIME: [HH:MM in 24h format]',
    );
    buffer.writeln();

    buffer.writeln('===== EXAMPLES =====');
    buffer.writeln(
      'REMINDER: Morning Feeding | DATE: 1 | TYPE: feeding | FREQUENCY: daily | PRIORITY: high | DESC: Feed breakfast portion - ensure fresh water available | TIME: 08:00',
    );
    buffer.writeln(
      'REMINDER: Evening Walk | DATE: 1 | TYPE: exercise | FREQUENCY: daily | PRIORITY: high | DESC: 30-minute evening walk for exercise and bathroom break | TIME: 18:00',
    );
    buffer.writeln(
      'REMINDER: Flea & Tick Prevention | DATE: 7 | TYPE: medication | FREQUENCY: monthly | PRIORITY: high | DESC: Apply monthly topical flea and tick treatment | TIME: 10:00',
    );
    buffer.writeln(
      'REMINDER: Weekly Brushing | DATE: 7 | TYPE: grooming | FREQUENCY: weekly | PRIORITY: medium | DESC: Brush coat thoroughly to prevent matting and reduce shedding | TIME: 14:00',
    );
    buffer.writeln(
      'REMINDER: Nail Trimming | DATE: 14 | TYPE: grooming | FREQUENCY: monthly | PRIORITY: medium | DESC: Trim nails to prevent overgrowth and discomfort | TIME: 15:00',
    );
    buffer.writeln(
      'REMINDER: Annual Wellness Exam | DATE: 60 | TYPE: checkup | FREQUENCY: once | PRIORITY: high | DESC: Schedule comprehensive yearly health checkup with veterinarian | TIME: 10:00',
    );
    buffer.writeln();

    buffer.writeln(
      'Generate diverse reminders covering different care aspects!',
    );

    return buffer.toString();
  }

  List<Map<String, dynamic>> _parseReminders(String response) {
    List<Map<String, dynamic>> reminders = [];
    final lines = response.split('\n');

    for (var line in lines) {
      if (line.trim().startsWith('REMINDER:')) {
        try {
          final parts = line.split('|').map((p) => p.trim()).toList();
          if (parts.length >= 6) {
            final title = parts[0].replaceFirst('REMINDER:', '').trim();
            final daysStr = parts[1].replaceFirst('DATE:', '').trim();
            final type =
                parts[2].replaceFirst('TYPE:', '').trim().toLowerCase();
            final frequency =
                parts[3].replaceFirst('FREQUENCY:', '').trim().toLowerCase();
            final priority =
                parts[4].replaceFirst('PRIORITY:', '').trim().toLowerCase();
            final description = parts[5].replaceFirst('DESC:', '').trim();

            // Extract time if provided
            String? timeStr;
            if (parts.length >= 7) {
              timeStr = parts[6].replaceFirst('TIME:', '').trim();
            }

            final days =
                int.tryParse(daysStr) ?? _getDefaultDaysForFrequency(frequency);

            // Create date with time
            DateTime reminderDate;
            if (timeStr != null && timeStr.contains(':')) {
              final timeParts = timeStr.split(':');
              final hour = int.tryParse(timeParts[0]) ?? 9;
              final minute = int.tryParse(timeParts[1]) ?? 0;

              reminderDate = DateTime.now().add(Duration(days: days));
              reminderDate = DateTime(
                reminderDate.year,
                reminderDate.month,
                reminderDate.day,
                hour,
                minute,
              );
            } else {
              reminderDate = DateTime.now().add(Duration(days: days));
            }

            reminders.add({
              'title': title,
              'date': reminderDate,
              'description': description,
              'type': type,
              'frequency': _normalizeFrequency(frequency),
              'priority': priority,
              'timeStr': timeStr ?? '09:00',
            });
          }
        } catch (e) {
          print('Error parsing reminder line: $line - $e');
          continue;
        }
      }
    }

    // If parsing fails or no reminders, generate smart defaults
    if (reminders.isEmpty) {
      reminders = _generateDefaultReminders();
    }

    // Remove duplicates
    final seen = <String>{};
    reminders =
        reminders.where((r) {
          final key = '${r['title']}_${r['frequency']}';
          if (seen.contains(key)) return false;
          seen.add(key);
          return true;
        }).toList();

    // Sort by date, then by priority
    reminders.sort((a, b) {
      final dateCompare = a['date'].compareTo(b['date']);
      if (dateCompare != 0) return dateCompare;
      return _getPriorityValue(
        b['priority'],
      ).compareTo(_getPriorityValue(a['priority']));
    });

    return reminders;
  }

  int _getDefaultDaysForFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'monthly':
        return 14;
      default:
        return 7;
    }
  }

  String _normalizeFrequency(String frequency) {
    final freq = frequency.toLowerCase();
    if (freq.contains('day') || freq == 'daily') return 'daily';
    if (freq.contains('week') || freq == 'weekly') return 'weekly';
    if (freq.contains('month') || freq == 'monthly') return 'monthly';
    if (freq.contains('once') || freq == 'one-time') return 'once';
    return 'once';
  }

  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }

  List<Map<String, dynamic>> _generateDefaultReminders() {
    final now = DateTime.now();
    final isdog = widget.pet.species.toLowerCase() == 'dog';
    final isCat = widget.pet.species.toLowerCase() == 'cat';

    return [
      {
        'title': 'Morning Feeding',
        'date': DateTime(now.year, now.month, now.day + 1, 8, 0),
        'description':
            'Feed ${widget.pet.name} breakfast at regular time with fresh water',
        'type': 'feeding',
        'frequency': 'daily',
        'priority': 'high',
        'timeStr': '08:00',
      },
      {
        'title': 'Evening Feeding',
        'date': DateTime(now.year, now.month, now.day + 1, 18, 0),
        'description': 'Feed ${widget.pet.name} dinner portion',
        'type': 'feeding',
        'frequency': 'daily',
        'priority': 'high',
        'timeStr': '18:00',
      },
      if (isdog)
        {
          'title': 'Morning Walk',
          'date': DateTime(now.year, now.month, now.day + 1, 7, 0),
          'description':
              '30-minute morning walk for exercise and bathroom break',
          'type': 'exercise',
          'frequency': 'daily',
          'priority': 'high',
          'timeStr': '07:00',
        },
      if (isdog)
        {
          'title': 'Evening Walk',
          'date': DateTime(now.year, now.month, now.day + 1, 19, 0),
          'description': '30-minute evening walk and playtime',
          'type': 'exercise',
          'frequency': 'daily',
          'priority': 'high',
          'timeStr': '19:00',
        },
      if (isCat)
        {
          'title': 'Litter Box Cleaning',
          'date': DateTime(now.year, now.month, now.day + 1, 9, 0),
          'description': 'Daily litter box maintenance for hygiene',
          'type': 'general',
          'frequency': 'daily',
          'priority': 'high',
          'timeStr': '09:00',
        },
      {
        'title': 'Flea & Tick Prevention',
        'date': DateTime(now.year, now.month, now.day + 7, 10, 0),
        'description': 'Apply monthly topical flea and tick treatment',
        'type': 'medication',
        'frequency': 'monthly',
        'priority': 'high',
        'timeStr': '10:00',
      },
      {
        'title': 'Weekly Grooming Session',
        'date': DateTime(now.year, now.month, now.day + 7, 14, 0),
        'description':
            'Brush coat thoroughly to prevent matting and reduce shedding',
        'type': 'grooming',
        'frequency': 'weekly',
        'priority': 'medium',
        'timeStr': '14:00',
      },
      {
        'title': 'Nail Trimming',
        'date': DateTime(now.year, now.month, now.day + 14, 15, 0),
        'description': 'Trim nails to prevent overgrowth and discomfort',
        'type': 'grooming',
        'frequency': 'monthly',
        'priority': 'medium',
        'timeStr': '15:00',
      },
      {
        'title': 'Wellness Checkup',
        'date': DateTime(now.year, now.month, now.day + 60, 10, 0),
        'description':
            'Schedule annual comprehensive health examination with veterinarian',
        'type': 'checkup',
        'frequency': 'once',
        'priority': 'high',
        'timeStr': '10:00',
      },
      {
        'title': 'Dental Care Check',
        'date': DateTime(now.year, now.month, now.day + 30, 16, 0),
        'description': 'Inspect teeth and gums, schedule cleaning if needed',
        'type': 'checkup',
        'frequency': 'once',
        'priority': 'medium',
        'timeStr': '16:00',
      },
    ];
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Reminders'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGenerating ? null : _generateSmartReminders,
          ),
        ],
      ),
      body:
          _isGenerating
              ? _buildLoadingState()
              : _hasNoData
              ? _buildNoDataState()
              : _aiGeneratedReminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing ${widget.pet.name}\'s care needs...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generating personalized reminders',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 100, color: Colors.orange[300]),
            const SizedBox(height: 24),
            Text(
              'Let\'s Get Started!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'AI will generate basic care reminders for ${widget.pet.name}. Add medical records for more personalized suggestions!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the refresh button to generate',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateSmartReminders,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate Reminders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    // Group reminders by frequency
    final daily =
        _aiGeneratedReminders.where((r) => r['frequency'] == 'daily').toList();
    final weekly =
        _aiGeneratedReminders.where((r) => r['frequency'] == 'weekly').toList();
    final monthly =
        _aiGeneratedReminders
            .where((r) => r['frequency'] == 'monthly')
            .toList();
    final once =
        _aiGeneratedReminders.where((r) => r['frequency'] == 'once').toList();

    return RefreshIndicator(
      onRefresh: _generateSmartReminders,
      color: Colors.orange,
      child: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI-Generated Care Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_aiGeneratedReminders.length} personalized reminders',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Frequency Summary
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFrequencyChip('Daily', daily.length, Icons.today),
                _buildFrequencyChip(
                  'Weekly',
                  weekly.length,
                  Icons.calendar_view_week,
                ),
                _buildFrequencyChip(
                  'Monthly',
                  monthly.length,
                  Icons.calendar_month,
                ),
                _buildFrequencyChip('Once', once.length, Icons.event),
              ],
            ),
          ),

          // Reminders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _aiGeneratedReminders.length,
              itemBuilder: (context, index) {
                final reminder = _aiGeneratedReminders[index];
                return _buildReminderCard(reminder, index);
              },
            ),
          ),

          // Add All Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _addAllReminders,
                icon: const Icon(Icons.add_circle, size: 24),
                label: const Text(
                  'Add All Reminders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, int index) {
    final iconData = _getReminderIcon(reminder['type']);
    final color = _getReminderColor(reminder['type']);
    final daysUntil = reminder['date'].difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;
    final priority = reminder['priority'] ?? 'medium';
    final frequency = reminder['frequency'] ?? 'once';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isUrgent
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showReminderDetails(reminder),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildPriorityBadge(priority),
                            const SizedBox(width: 8),
                            _buildFrequencyBadge(frequency),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reminder['description'],
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(reminder['timeStr'] ?? '09:00'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(reminder['date']),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      daysUntil == 0
                          ? 'Today'
                          : daysUntil == 1
                          ? 'Tomorrow'
                          : 'in $daysUntil days',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUrgent ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _dismissReminder(index),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Dismiss'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addSingleReminder(reminder),
                    icon: const Icon(Icons.add_alarm, size: 18),
                    label: const Text('Add Reminder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color badgeColor;
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        badgeColor = Colors.orange;
        icon = Icons.remove;
        break;
      case 'low':
        badgeColor = Colors.green;
        icon = Icons.trending_down;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            priority[0].toUpperCase() + priority.substring(1),
            style: TextStyle(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyBadge(String frequency) {
    Color badgeColor;
    IconData icon;
    String label;

    switch (frequency.toLowerCase()) {
      case 'daily':
        badgeColor = Colors.blue;
        icon = Icons.today;
        label = 'Daily';
        break;
      case 'weekly':
        badgeColor = Colors.purple;
        icon = Icons.calendar_view_week;
        label = 'Weekly';
        break;
      case 'monthly':
        badgeColor = Colors.teal;
        icon = Icons.calendar_month;
        label = 'Monthly';
        break;
      case 'once':
        badgeColor = Colors.indigo;
        icon = Icons.event;
        label = 'One-time';
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.notifications;
        label = 'Once';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return Icons.health_and_safety;
      case 'vaccination':
        return Icons.vaccines;
      case 'medication':
        return Icons.medication;
      case 'grooming':
        return Icons.content_cut;
      case 'feeding':
        return Icons.restaurant;
      case 'exercise':
        return Icons.directions_walk;
      case 'general':
        return Icons.pets;
      default:
        return Icons.notifications;
    }
  }

  Color _getReminderColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return Colors.green;
      case 'vaccination':
        return Colors.blue;
      case 'medication':
        return Colors.orange;
      case 'grooming':
        return Colors.purple;
      case 'feeding':
        return Colors.amber;
      case 'exercise':
        return Colors.teal;
      case 'general':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('About Smart Reminders'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI analyzes your pet\'s profile and medical history to generate personalized care reminders.\n',
                  ),
                  const Text(
                    'Reminder Types:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    Icons.today,
                    'Daily',
                    'Repeats every day (feeding, walks)',
                  ),
                  _buildHelpItem(
                    Icons.calendar_view_week,
                    'Weekly',
                    'Repeats every week (grooming)',
                  ),
                  _buildHelpItem(
                    Icons.calendar_month,
                    'Monthly',
                    'Repeats every month (flea control)',
                  ),
                  _buildHelpItem(
                    Icons.event,
                    'One-time',
                    'Single occurrence (vet visits)',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap "Add Reminder" to save individual suggestions, or "Add All" to save everything at once.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReminderDetails(Map<String, dynamic> reminder) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(reminder['title']),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Type', reminder['type']),
                  _buildDetailRow('Frequency', reminder['frequency']),
                  _buildDetailRow('Priority', reminder['priority'] ?? 'medium'),
                  _buildDetailRow('Date', _formatDate(reminder['date'])),
                  _buildDetailRow(
                    'Time',
                    _formatTime(reminder['timeStr'] ?? '09:00'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(reminder['description']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addSingleReminder(reminder);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Add Reminder'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value[0].toUpperCase() + value.substring(1))),
        ],
      ),
    );
  }

  Future<void> _addSingleReminder(Map<String, dynamic> reminderData) async {
    try {
      final reminderDB = ref.read(reminderDatabaseProvider);

      final reminder = Reminder(
        petId: widget.pet.id,
        title: reminderData['title'],
        description: reminderData['description'],
        reminderDate: reminderData['date'],
        reminderType: reminderData['frequency'],
        importanceLevel: reminderData['priority'] ?? 'medium',
      );

      await reminderDB.createReminder(reminder);

      // Sync to Supabase
      final syncService = ref.read(unifiedSyncServiceProvider);
      final user = ref.read(currentUserProvider);

      if (user != null) {
        await syncService.syncRemindersToSupabase();
      }

      // Invalidate providers to refresh
      ref.invalidate(allRemindersProvider);
      ref.invalidate(todayRemindersProvider);
      ref.invalidate(weeklyRemindersProvider);
      ref.invalidate(monthlyRemindersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Added: ${reminderData['title']}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );

        // Remove from AI suggestions
        setState(() {
          _aiGeneratedReminders.removeWhere(
            (r) => r['title'] == reminderData['title'],
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addAllReminders() async {
    if (_aiGeneratedReminders.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Add All Reminders?'),
            content: Text(
              'This will add all ${_aiGeneratedReminders.length} AI-generated '
              'reminders to your schedule. They will automatically repeat based on their frequency.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Add All'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Adding reminders...'),
                      ],
                    ),
                  ),
                ),
              ),
        );
      }

      final reminderDB = ref.read(reminderDatabaseProvider);
      int added = 0;

      for (var reminderData in _aiGeneratedReminders) {
        try {
          final reminder = Reminder(
            petId: widget.pet.id,
            title: reminderData['title'],
            description: reminderData['description'],
            reminderDate: reminderData['date'],
            reminderType: reminderData['frequency'],
            importanceLevel: reminderData['priority'] ?? 'medium',
          );

          await reminderDB.createReminder(reminder);
          added++;
        } catch (e) {
          print('Error adding reminder: $e');
        }
      }

      // Sync to Supabase
      final syncService = ref.read(unifiedSyncServiceProvider);
      final user = ref.read(currentUserProvider);

      if (user != null) {
        await syncService.syncRemindersToSupabase();
      }

      // Invalidate providers to refresh
      ref.invalidate(allRemindersProvider);
      ref.invalidate(todayRemindersProvider);
      ref.invalidate(weeklyRemindersProvider);
      ref.invalidate(monthlyRemindersProvider);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Successfully added $added reminders!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View All',
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );

        // Clear AI suggestions after successful add
        setState(() {
          _aiGeneratedReminders.clear();
        });

        // Show success dialog
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('All Set!')),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$added reminders have been added to your schedule.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Daily reminders will repeat every day.\n'
                        'Weekly reminders will repeat every week.\n'
                        'Monthly reminders will repeat every month.\n'
                        'One-time reminders will occur only once.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Stay Here'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Go to Reminders'),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reminders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _dismissReminder(int index) {
    final dismissed = _aiGeneratedReminders[index];

    setState(() {
      _aiGeneratedReminders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed: ${dismissed['title']}'),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _aiGeneratedReminders.insert(index, dismissed);
            });
          },
        ),
      ),
    );
  }
}
