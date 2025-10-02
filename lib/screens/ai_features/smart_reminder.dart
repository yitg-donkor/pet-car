import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class SmartRemindersScreen extends StatefulWidget {
  final String userId;

  const SmartRemindersScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<SmartRemindersScreen> createState() => _SmartRemindersScreenState();
}

class _SmartRemindersScreenState extends State<SmartRemindersScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  List<Map<String, dynamic>> _aiGeneratedReminders = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateSmartReminders();
  }

  Future<void> _generateSmartReminders() async {
    setState(() {
      _isGenerating = true;
      _aiGeneratedReminders = [];
    });

    try {
      // TODO: Fetch pet data and medical history from Firestore
      // Example: final petDoc = await FirebaseFirestore.instance
      //   .collection('pets')
      //   .doc(widget.petId)
      //   .get();

      final prompt = '''
Based on this pet profile:
- Species: Dog
- Breed: Golden Retriever
- Age: 3 years old
- Last vaccination: 6 months ago (Rabies booster)
- Last checkup: 8 months ago
- Last grooming: 1 month ago
- Current medications: None

Generate a list of 5-7 important care reminders for the next 3 months.

Format your response EXACTLY like this (one reminder per line):
REMINDER: [Title] | DATE: [days from now] | TYPE: [checkup/vaccination/medication/grooming/general] | DESC: [description]

Example:
REMINDER: Annual Wellness Exam | DATE: 14 | TYPE: checkup | DESC: Schedule yearly health checkup
REMINDER: Heartworm Medication | DATE: 7 | TYPE: medication | DESC: Monthly heartworm prevention due
''';

      final response = await _aiHelper.generateSmartReminders(prompt);

      // Parse AI response
      final reminders = _parseReminders(response);

      setState(() {
        _aiGeneratedReminders = reminders;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

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

  List<Map<String, dynamic>> _parseReminders(String response) {
    List<Map<String, dynamic>> reminders = [];
    final lines = response.split('\n');

    for (var line in lines) {
      if (line.trim().startsWith('REMINDER:')) {
        try {
          final parts = line.split('|');
          if (parts.length >= 4) {
            final title = parts[0].replaceFirst('REMINDER:', '').trim();
            final daysStr = parts[1].replaceFirst('DATE:', '').trim();
            final type = parts[2].replaceFirst('TYPE:', '').trim();
            final description = parts[3].replaceFirst('DESC:', '').trim();

            final days = int.tryParse(daysStr) ?? 7;

            reminders.add({
              'title': title,
              'date': DateTime.now().add(Duration(days: days)),
              'description': description,
              'type': type,
            });
          }
        } catch (e) {
          // Skip malformed lines
          continue;
        }
      }
    }

    // Fallback if parsing fails
    if (reminders.isEmpty) {
      reminders = [
        {
          'title': 'Annual Checkup',
          'date': DateTime.now().add(Duration(days: 14)),
          'description': 'Time for annual wellness exam',
          'type': 'checkup',
        },
        {
          'title': 'Heartworm Prevention',
          'date': DateTime.now().add(Duration(days: 7)),
          'description': 'Monthly heartworm medication due',
          'type': 'medication',
        },
        {
          'title': 'Vaccination Booster',
          'date': DateTime.now().add(Duration(days: 30)),
          'description': 'Check vaccination schedule',
          'type': 'vaccination',
        },
        {
          'title': 'Grooming Appointment',
          'date': DateTime.now().add(Duration(days: 21)),
          'description': 'Schedule grooming session',
          'type': 'grooming',
        },
      ];
    }

    // Sort by date
    reminders.sort((a, b) => a['date'].compareTo(b['date']));

    return reminders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Reminders'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('About Smart Reminders'),
                      content: Text(
                        'AI-powered reminders based on your pet\'s health history, '
                        'vaccination schedule, and care needs. These suggestions help '
                        'you stay on top of your pet\'s wellness routine.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Got it'),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isGenerating ? null : _generateSmartReminders,
          ),
        ],
      ),
      body:
          _isGenerating
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Generating smart reminders...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Analyzing your pet\'s care schedule',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : _aiGeneratedReminders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No reminders yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the refresh button to generate',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _generateSmartReminders,
                      icon: Icon(Icons.refresh),
                      label: Text('Generate Reminders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _generateSmartReminders,
                color: Colors.orange,
                child: Column(
                  children: [
                    // Header Info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.orange.shade50,
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Care Tasks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${_aiGeneratedReminders.length} AI-generated reminders',
                                  style: TextStyle(
                                    fontSize: 13,
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
                        padding: EdgeInsets.all(16),
                        itemCount: _aiGeneratedReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _aiGeneratedReminders[index];
                          return _buildReminderCard(reminder, index);
                        },
                      ),
                    ),

                    // Premium Badge
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade100,
                            Colors.orange.shade100,
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.amber.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Premium Feature - AI-powered care scheduling',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, int index) {
    final iconData = _getReminderIcon(reminder['type']);
    final color = _getReminderColor(reminder['type']);
    final daysUntil = reminder['date'].difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isUrgent
                ? BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(iconData, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reminder['title'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (isUrgent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6),
            Text(
              reminder['description'],
              style: TextStyle(fontSize: 14, height: 1.3),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                SizedBox(width: 6),
                Text(
                  _formatDate(reminder['date']),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  daysUntil == 0
                      ? 'Today'
                      : daysUntil == 1
                      ? 'Tomorrow'
                      : 'in $daysUntil days',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUrgent ? Colors.red : Colors.grey[600],
                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.alarm_add, color: color),
          onPressed: () {
            _addReminder(reminder);
          },
        ),
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
        return Icons.cut;
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

  void _addReminder(Map<String, dynamic> reminder) {
    // TODO: Integrate with device calendar or notification system
    // Example: Use flutter_local_notifications or device calendar

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Reminder'),
            content: Text(
              'Would you like to set a notification for "${reminder['title']}" on ${_formatDate(reminder['date'])}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Actually set the reminder/notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder set for ${reminder['title']}'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text('Set Reminder'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
