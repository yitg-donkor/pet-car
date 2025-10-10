import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/reminder.dart';
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
      // Fetch real data from database
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      final reminderDB = ref.read(reminderDatabaseProvider);

      final medicalRecords = await medicalRecordDB.getMedicalRecordsForPet(
        widget.pet.id,
      );
      final existingReminders = await reminderDB.getAllReminders();
      final petReminders =
          existingReminders.where((r) => r.petId == widget.pet.id).toList();

      // Build comprehensive prompt with real data
      final prompt = _buildPromptFromData(medicalRecords, petReminders);

      final response = await _aiHelper.generateSmartReminders(prompt);

      // Parse AI response
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

    buffer.writeln('Based on this pet profile:');
    buffer.writeln('- Name: ${widget.pet.name}');
    buffer.writeln('- Species: ${widget.pet.species}');
    if (widget.pet.breed != null)
      buffer.writeln('- Breed: ${widget.pet.breed}');
    if (widget.pet.age != null)
      buffer.writeln('- Age: ${widget.pet.age} years');
    if (widget.pet.weight != null)
      buffer.writeln('- Weight: ${widget.pet.weight} kg');
    buffer.writeln();

    // Medical history
    if (medicalRecords.isNotEmpty) {
      buffer.writeln('MEDICAL HISTORY (${medicalRecords.length} records):');

      // Group by type
      final recordsByType = <String, List<MedicalRecord>>{};
      for (var record in medicalRecords) {
        recordsByType.putIfAbsent(record.recordType, () => []).add(record);
      }

      for (var entry in recordsByType.entries) {
        buffer.writeln('\n${entry.key.toUpperCase()}:');
        for (var record in entry.value.take(3)) {
          buffer.writeln('- ${record.title} (${_formatDate(record.date)})');
          if (record.nextDueDate != null) {
            buffer.writeln('  Next due: ${_formatDate(record.nextDueDate!)}');
          }
        }
      }
      buffer.writeln();
    } else {
      buffer.writeln('MEDICAL HISTORY: No records available');
      buffer.writeln('Note: Generate basic preventive care reminders.');
      buffer.writeln();
    }

    // Existing reminders
    if (existingReminders.isNotEmpty) {
      buffer.writeln(
        'EXISTING REMINDERS (${existingReminders.length} active):',
      );
      for (var reminder in existingReminders.take(5)) {
        buffer.writeln(
          '- ${reminder.title} (${_formatDate(reminder.reminderDate)})',
        );
      }
      buffer.writeln('\nAvoid duplicating these existing reminders.');
      buffer.writeln();
    }

    buffer.writeln(
      'Generate 5-8 important care reminders for the next 3 months.',
    );
    buffer.writeln('Focus on:');
    buffer.writeln('1. Upcoming vaccinations based on history');
    buffer.writeln('2. Regular checkups (if not already scheduled)');
    buffer.writeln('3. Preventive care (dental, parasite control)');
    buffer.writeln('4. Grooming needs');
    buffer.writeln('5. Medication refills (if applicable)');
    buffer.writeln('6. Follow-ups for recent medical records');
    buffer.writeln('7. Daily care routines (feeding, exercise)');
    buffer.writeln('8. Monthly care tasks (flea/tick prevention)');
    buffer.writeln();
    buffer.writeln('IMPORTANT: Set appropriate FREQUENCY for each reminder:');
    buffer.writeln(
      '- Use "daily" for: feeding, water changes, medication (if daily)',
    );
    buffer.writeln(
      '- Use "weekly" for: exercise routines, grooming basics, training sessions',
    );
    buffer.writeln(
      '- Use "monthly" for: flea/tick prevention, heartworm medication, nail trimming',
    );
    buffer.writeln(
      '- Use "once" for: one-time events like checkups, vaccinations, surgeries',
    );
    buffer.writeln();
    buffer.writeln(
      'Format your response EXACTLY like this (one reminder per line):',
    );
    buffer.writeln(
      'REMINDER: [Title] | DATE: [days from now] | TYPE: [checkup/vaccination/medication/grooming/feeding/exercise/general] | FREQUENCY: [daily/weekly/monthly/one-time] | PRIORITY: [high/medium/low] | DESC: [description]',
    );
    buffer.writeln();
    buffer.writeln('Examples:');
    buffer.writeln(
      'REMINDER: Morning Feeding | DATE: 1 | TYPE: feeding | FREQUENCY: daily | PRIORITY: high | DESC: Feed breakfast at 8 AM daily',
    );
    buffer.writeln(
      'REMINDER: Evening Walk | DATE: 1 | TYPE: exercise | FREQUENCY: daily | PRIORITY: medium | DESC: 30-minute walk every evening',
    );
    buffer.writeln(
      'REMINDER: Flea & Tick Prevention | DATE: 7 | TYPE: medication | FREQUENCY: monthly | PRIORITY: high | DESC: Monthly flea and tick treatment',
    );
    buffer.writeln(
      'REMINDER: Nail Trimming | DATE: 14 | TYPE: grooming | FREQUENCY: monthly | PRIORITY: medium | DESC: Trim nails to prevent overgrowth',
    );
    buffer.writeln(
      'REMINDER: Annual Wellness Exam | DATE: 30 | TYPE: checkup | FREQUENCY: once | PRIORITY: high | DESC: Schedule yearly health checkup',
    );

    return buffer.toString();
  }

  List<Map<String, dynamic>> _parseReminders(String response) {
    List<Map<String, dynamic>> reminders = [];
    final lines = response.split('\n');

    for (var line in lines) {
      if (line.trim().startsWith('REMINDER:')) {
        try {
          final parts = line.split('|');
          if (parts.length >= 5) {
            final title = parts[0].replaceFirst('REMINDER:', '').trim();
            final daysStr = parts[1].replaceFirst('DATE:', '').trim();
            final type = parts[2].replaceFirst('TYPE:', '').trim();
            final frequency = parts[3].replaceFirst('FREQUENCY:', '').trim();

            String priority = 'medium';
            String description = '';

            if (parts.length >= 6) {
              priority = parts[4].replaceFirst('PRIORITY:', '').trim();
              description = parts[5].replaceFirst('DESC:', '').trim();
            } else if (parts.length == 5) {
              description = parts[4].replaceFirst('DESC:', '').trim();
            }

            final days = int.tryParse(daysStr) ?? 7;

            reminders.add({
              'title': title,
              'date': DateTime.now().add(Duration(days: days)),
              'description': description,
              'type': type,
              'frequency': frequency,
              'priority': priority,
            });
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Fallback if parsing fails
    if (reminders.isEmpty) {
      reminders = [
        {
          'title': 'Morning Feeding',
          'date': DateTime.now().add(const Duration(days: 1)),
          'description': 'Feed breakfast at regular time',
          'type': 'feeding',
          'frequency': 'daily',
          'priority': 'high',
        },
        {
          'title': 'Evening Walk',
          'date': DateTime.now().add(const Duration(days: 1)),
          'description': '30-minute walk for exercise',
          'type': 'exercise',
          'frequency': 'daily',
          'priority': 'medium',
        },
        {
          'title': 'Flea & Tick Prevention',
          'date': DateTime.now().add(const Duration(days: 7)),
          'description': 'Monthly flea and tick treatment',
          'type': 'medication',
          'frequency': 'monthly',
          'priority': 'high',
        },
        {
          'title': 'Weekly Grooming',
          'date': DateTime.now().add(const Duration(days: 7)),
          'description': 'Brush and basic grooming',
          'type': 'grooming',
          'frequency': 'weekly',
          'priority': 'medium',
        },
        {
          'title': 'Annual Checkup',
          'date': DateTime.now().add(const Duration(days: 30)),
          'description': 'Time for annual wellness exam',
          'type': 'checkup',
          'frequency': 'once',
          'priority': 'high',
        },
        {
          'title': 'Vaccination Review',
          'date': DateTime.now().add(const Duration(days: 60)),
          'description': 'Check vaccination schedule',
          'type': 'vaccination',
          'frequency': 'once',
          'priority': 'high',
        },
      ];
    }

    // Sort by date
    reminders.sort((a, b) => a['date'].compareTo(b['date']));

    return reminders;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
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
            Icon(
              Icons.notifications_off_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Health Data Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add medical records to get personalized AI reminders based on ${widget.pet.name}\'s health history.',
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
                    Icons.lightbulb,
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
                        'AI-Generated Care Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_aiGeneratedReminders.length} personalized suggestions',
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

          // Premium Badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade100, Colors.orange.shade100],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Premium AI Feature',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, int index) {
    final iconData = _getReminderIcon(reminder['type']);
    final color = _getReminderColor(reminder['type']);
    final daysUntil = reminder['date'].difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;
    final priority = reminder['priority'] ?? 'medium';

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
                        _buildPriorityBadge(priority),
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
                  const SizedBox(width: 12),
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
                    label: const Text('Add to Reminders'),
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

    return Row(
      children: [
        Icon(icon, size: 14, color: badgeColor),
        const SizedBox(width: 4),
        Text(
          '${priority[0].toUpperCase()}${priority.substring(1)} Priority',
          style: TextStyle(
            fontSize: 12,
            color: badgeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      case 'general':
        return Colors.teal;
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
            content: const Text(
              'AI-powered reminders based on your pet\'s health history, '
              'vaccination schedule, and care needs. These suggestions help '
              'you stay on top of your pet\'s wellness routine.\n\n'
              'Tap "Add to Reminders" to save any suggestion to your main reminders.',
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
                  _buildDetailRow('Priority', reminder['priority'] ?? 'medium'),
                  _buildDetailRow('Date', _formatDate(reminder['date'])),
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
            width: 80,
            child: Text(
              label,
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
      await syncService.syncRemindersToSupabase();

      // Invalidate providers to refresh
      ref.invalidate(allRemindersProvider);
      ref.invalidate(todayRemindersProvider);

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
              'reminders to your main reminders list.',
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
                        CircularProgressIndicator(),
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
      await syncService.syncRemindersToSupabase();

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
                  content: Text(
                    '$added reminders have been added to your schedule. '
                    'You can view and manage them in the Reminders tab.',
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
    setState(() {
      _aiGeneratedReminders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder dismissed'),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Undo would be complex, so we'll just regenerate
            _generateSmartReminders();
          },
        ),
      ),
    );
  }
}
