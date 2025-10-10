import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/activity_log.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:intl/intl.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const MonthlyReportScreen({Key? key, required this.pet}) : super(key: key);

  @override
  ConsumerState<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  Map<String, dynamic>? _report;
  bool _isGenerating = false;
  bool _hasNoData = false;
  DateTime _selectedMonth = DateTime.now();

  // Statistics
  int _totalActivities = 0;
  int _walks = 0;
  int _meals = 0;
  int _grooming = 0;
  int _vetVisits = 0;
  int _medications = 0;
  int _completedReminders = 0;
  int _totalReminders = 0;
  double _reminderCompletionRate = 0.0;
  Map<String, int> _activityBreakdown = {};
  Map<String, int> _medicalRecordBreakdown = {};
  List<String> _highlights = [];
  List<String> _concerns = [];

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _hasNoData = false;
    });

    try {
      // Fetch real data from database
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      final activityLogDB = ActivityLogLocalDB();
      final reminderDB = ref.read(reminderDatabaseProvider);

      // Get date range for selected month
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      // Fetch data
      final allMedicalRecords = await medicalRecordDB.getMedicalRecordsForPet(
        widget.pet.id,
      );
      final allActivityLogs = await activityLogDB.getActivityLogsForPet(
        widget.pet.id,
      );
      final allReminders = await reminderDB.getAllReminders();

      // Filter for selected month
      final medicalRecords =
          allMedicalRecords
              .where(
                (record) =>
                    record.date.isAfter(
                      startDate.subtract(const Duration(days: 1)),
                    ) &&
                    record.date.isBefore(endDate.add(const Duration(days: 1))),
              )
              .toList();

      final activityLogs =
          allActivityLogs
              .where(
                (log) =>
                    log.timestamp.isAfter(
                      startDate.subtract(const Duration(days: 1)),
                    ) &&
                    log.timestamp.isBefore(
                      endDate.add(const Duration(days: 1)),
                    ),
              )
              .toList();

      final reminders =
          allReminders
              .where(
                (reminder) =>
                    reminder.petId == widget.pet.id &&
                    reminder.reminderDate.isAfter(
                      startDate.subtract(const Duration(days: 1)),
                    ) &&
                    reminder.reminderDate.isBefore(
                      endDate.add(const Duration(days: 1)),
                    ),
              )
              .toList();

      // Check if we have any data
      if (medicalRecords.isEmpty && activityLogs.isEmpty && reminders.isEmpty) {
        setState(() {
          _hasNoData = true;
          _isGenerating = false;
        });
        return;
      }

      // Calculate statistics
      _calculateStatistics(medicalRecords, activityLogs, reminders);

      // Generate AI report
      final prompt = _buildPromptFromData(
        medicalRecords,
        activityLogs,
        reminders,
      );

      final aiResponse = await _aiHelper.generateMonthlyReport(prompt);

      // Parse AI response
      final parsedReport = _parseAIResponse(aiResponse);

      setState(() {
        _report = parsedReport;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _generateReport,
            ),
          ),
        );
      }
    }
  }

  void _calculateStatistics(
    List<MedicalRecord> medicalRecords,
    List<ActivityLog> activityLogs,
    List<Reminder> reminders,
  ) {
    // Reset counters
    _totalActivities = activityLogs.length;
    _walks = 0;
    _meals = 0;
    _grooming = 0;
    _vetVisits = 0;
    _medications = 0;
    _activityBreakdown = {};
    _medicalRecordBreakdown = {};
    _highlights = [];
    _concerns = [];

    // Count activities by type
    for (var log in activityLogs) {
      final type = log.activityType.toLowerCase();
      _activityBreakdown[type] = (_activityBreakdown[type] ?? 0) + 1;

      if (type.contains('walk') || type.contains('exercise')) _walks++;
      if (type.contains('meal') || type.contains('feed')) _meals++;
      if (type.contains('groom')) _grooming++;
    }

    // Count medical records by type
    for (var record in medicalRecords) {
      final type = record.recordType.toLowerCase();
      _medicalRecordBreakdown[type] = (_medicalRecordBreakdown[type] ?? 0) + 1;

      if (type.contains('checkup') || type.contains('vet')) _vetVisits++;
      if (type.contains('medication')) _medications++;
    }

    // Reminder statistics
    _totalReminders = reminders.length;
    _completedReminders = reminders.where((r) => r.isCompleted).length;
    _reminderCompletionRate =
        _totalReminders > 0
            ? (_completedReminders / _totalReminders) * 100
            : 0.0;

    // Generate highlights and concerns
    if (_walks >= 30) {
      _highlights.add('Excellent exercise routine: $_walks walks this month');
    } else if (_walks > 0) {
      _concerns.add(
        'Exercise could be increased: Only $_walks walks this month',
      );
    }

    if (_reminderCompletionRate >= 90) {
      _highlights.add(
        'Outstanding reminder completion: ${_reminderCompletionRate.toStringAsFixed(0)}%',
      );
    } else if (_reminderCompletionRate < 70 && _totalReminders > 0) {
      _concerns.add(
        'Reminder completion needs improvement: ${_reminderCompletionRate.toStringAsFixed(0)}%',
      );
    }

    if (_vetVisits > 0) {
      _highlights.add(
        '$_vetVisits vet visit${_vetVisits > 1 ? 's' : ''} completed',
      );
    }

    if (_medicalRecordBreakdown.containsKey('vaccination')) {
      _highlights.add('Vaccinations up to date');
    }

    if (_grooming >= 2) {
      _highlights.add('Good grooming maintenance: $_grooming sessions');
    }

    if (_totalActivities == 0) {
      _concerns.add('No activities logged this month');
    }

    if (medicalRecords.isEmpty &&
        _selectedMonth.month == DateTime.now().month) {
      _concerns.add('No medical records added this month');
    }
  }

  String _buildPromptFromData(
    List<MedicalRecord> medicalRecords,
    List<ActivityLog> activityLogs,
    List<Reminder> reminders,
  ) {
    final buffer = StringBuffer();
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    buffer.writeln(
      'Generate a comprehensive monthly pet care report for ${widget.pet.name} - $monthName\n',
    );

    // Summary statistics
    buffer.writeln('MONTHLY STATISTICS:');
    buffer.writeln('- Total Activities: $_totalActivities');
    buffer.writeln('- Walks/Exercise: $_walks');
    buffer.writeln('- Meals Logged: $_meals');
    buffer.writeln('- Grooming Sessions: $_grooming');
    buffer.writeln('- Vet Visits: $_vetVisits');
    buffer.writeln('- Medical Records Added: ${medicalRecords.length}');
    buffer.writeln(
      '- Reminders Completed: $_completedReminders/$_totalReminders (${_reminderCompletionRate.toStringAsFixed(0)}%)\n',
    );

    // Activity breakdown
    if (_activityBreakdown.isNotEmpty) {
      buffer.writeln('ACTIVITY BREAKDOWN:');
      _activityBreakdown.forEach((type, count) {
        buffer.writeln('- ${_capitalize(type)}: $count times');
      });
      buffer.writeln();
    }

    // Medical records breakdown
    if (medicalRecords.isNotEmpty) {
      buffer.writeln('MEDICAL RECORDS (${medicalRecords.length} total):');
      _medicalRecordBreakdown.forEach((type, count) {
        buffer.writeln('- ${_capitalize(type)}: $count');
      });

      buffer.writeln('\nRecent Medical Events:');
      for (var record in medicalRecords.take(5)) {
        buffer.writeln('- ${record.title} (${_formatDate(record.date)})');
        if (record.veterinarian != null) {
          buffer.writeln('  Vet: ${record.veterinarian}');
        }
      }
      buffer.writeln();
    }

    // Notable activities
    if (activityLogs.isNotEmpty) {
      buffer.writeln('NOTABLE ACTIVITIES:');
      final healthLogs =
          activityLogs.where((log) => log.isHealthRelated).toList();
      if (healthLogs.isNotEmpty) {
        buffer.writeln('Health-related activities: ${healthLogs.length}');
        for (var log in healthLogs.take(3)) {
          buffer.writeln('- ${log.title}');
        }
      }
      buffer.writeln();
    }

    // Reminders performance
    if (reminders.isNotEmpty) {
      buffer.writeln('REMINDER PERFORMANCE:');
      buffer.writeln(
        '- Completion Rate: ${_reminderCompletionRate.toStringAsFixed(1)}%',
      );
      final overdueReminders =
          reminders
              .where(
                (r) =>
                    !r.isCompleted && r.reminderDate.isBefore(DateTime.now()),
              )
              .length;
      if (overdueReminders > 0) {
        buffer.writeln('- Overdue Reminders: $overdueReminders');
      }
      buffer.writeln();
    }

    // Highlights and concerns
    if (_highlights.isNotEmpty) {
      buffer.writeln('HIGHLIGHTS:');
      for (var highlight in _highlights) {
        buffer.writeln('- $highlight');
      }
      buffer.writeln();
    }

    if (_concerns.isNotEmpty) {
      buffer.writeln('AREAS FOR IMPROVEMENT:');
      for (var concern in _concerns) {
        buffer.writeln('- $concern');
      }
      buffer.writeln();
    }

    buffer.writeln('Please provide a comprehensive report with:');
    buffer.writeln('1. Executive Summary (2-3 sentences)');
    buffer.writeln('2. Key Achievements');
    buffer.writeln('3. Health & Wellness Assessment');
    buffer.writeln('4. Areas for Improvement');
    buffer.writeln('5. Recommendations for Next Month');
    buffer.writeln('6. Overall Grade (A-F)');

    return buffer.toString();
  }

  Map<String, dynamic> _parseAIResponse(String response) {
    final summary = response
        .split('\n\n')
        .firstWhere((para) => para.isNotEmpty, orElse: () => response);

    return {
      'summary': response,
      'executive_summary': summary,
      'grade': _extractGrade(response),
    };
  }

  String _extractGrade(String response) {
    final gradeRegex = RegExp(r'Grade[:\s]+([A-F][+-]?)');
    final match = gradeRegex.firstMatch(response);
    return match?.group(1) ?? 'B+';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _hasNoData ? null : _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _hasNoData ? null : _shareReport,
            tooltip: 'Share Report',
          ),
        ],
      ),
      body:
          _isGenerating
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing ${widget.pet.name}\'s data...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generating comprehensive report',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : _hasNoData
              ? _buildNoDataState()
              : RefreshIndicator(
                onRefresh: _generateReport,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Month Selector
                      _buildMonthSelector(),
                      const SizedBox(height: 24),

                      // Pet Info Card
                      _buildPetInfoCard(),
                      const SizedBox(height: 24),

                      // Overall Grade
                      if (_report != null) _buildGradeCard(),
                      if (_report != null) const SizedBox(height: 24),

                      // Quick Stats Grid
                      _buildQuickStatsSection(),
                      const SizedBox(height: 24),

                      // Activity Breakdown
                      if (_activityBreakdown.isNotEmpty)
                        _buildActivityBreakdown(),
                      if (_activityBreakdown.isNotEmpty)
                        const SizedBox(height: 24),

                      // Medical Records Section
                      if (_medicalRecordBreakdown.isNotEmpty)
                        _buildMedicalSection(),
                      if (_medicalRecordBreakdown.isNotEmpty)
                        const SizedBox(height: 24),

                      // Highlights & Concerns
                      _buildHighlightsAndConcerns(),
                      const SizedBox(height: 24),

                      // AI Summary
                      if (_report != null) _buildAISummary(),
                      if (_report != null) const SizedBox(height: 24),

                      // Action Button
                      _buildActionButton(),
                      const SizedBox(height: 16),

                      // Premium Badge
                      _buildPremiumBadge(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildMonthSelector() {
    final canGoForward = _selectedMonth.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
                _generateReport();
              },
            ),
            Column(
              children: [
                Text(
                  DateFormat('MMMM').format(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(_selectedMonth),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: 32,
                color: canGoForward ? Colors.black : Colors.grey[300],
              ),
              onPressed:
                  canGoForward
                      ? () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                        _generateReport();
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.deepPurple.shade100,
              child:
                  widget.pet.photoUrl != null
                      ? ClipOval(
                        child: Image.network(
                          widget.pet.photoUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.pets,
                                size: 35,
                                color: Colors.deepPurple,
                              ),
                        ),
                      )
                      : Icon(Icons.pets, size: 35, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.pet.species}${widget.pet.breed != null ? ' • ${widget.pet.breed}' : ''}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (widget.pet.age != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${widget.pet.age} years old',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard() {
    final grade = _report!['grade'] as String;
    final gradeColor = _getGradeColor(grade);

    return Card(
      elevation: 8,
      color: gradeColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: gradeColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Overall Grade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: gradeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  grade,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getGradeLabel(grade),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: gradeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Activities',
                _totalActivities.toString(),
                Icons.celebration,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Walks',
                _walks.toString(),
                Icons.directions_walk,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Vet Visits',
                _vetVisits.toString(),
                Icons.local_hospital,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Grooming',
                _grooming.toString(),
                Icons.content_cut,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Reminder Completion',
          '${_reminderCompletionRate.toStringAsFixed(0)}%',
          Icons.check_circle,
          _reminderCompletionRate >= 80 ? Colors.green : Colors.orange,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isWide = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child:
            isWide
                ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 32, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Icon(icon, size: 36, color: color),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text(
              'Activity Breakdown',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children:
                  _activityBreakdown.entries.map((entry) {
                    final percentage =
                        (_totalActivities > 0
                            ? (entry.value / _totalActivities) * 100
                            : 0.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _capitalize(entry.key),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services, color: Colors.red),
            const SizedBox(width: 8),
            const Text(
              'Medical Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children:
                  _medicalRecordBreakdown.entries.map((entry) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getMedicalIcon(entry.key),
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        _capitalize(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsAndConcerns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_highlights.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Month Highlights',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._highlights.map((highlight) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.amber),
                ),
                title: Text(highlight, style: const TextStyle(fontSize: 15)),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
        if (_concerns.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Areas for Improvement',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._concerns.map((concern) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.orange),
                ),
                title: Text(concern, style: const TextStyle(fontSize: 15)),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildAISummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI-Powered Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            Text(
              _report!['summary'] ?? 'No summary available',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _isGenerating ? null : _generateReport,
      icon: const Icon(Icons.refresh, size: 22),
      label: const Text(
        'Regenerate Report',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: Colors.deepPurple.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Feature',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-powered monthly insights and comprehensive reports',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Data for $monthName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities, medical records, or reminders found for ${widget.pet.name} this month.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildNoDataActionCard(
              icon: Icons.add_circle,
              title: 'Start Logging',
              description: 'Add activities, medical records, and set reminders',
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 12),
            _buildNoDataActionCard(
              icon: Icons.calendar_month,
              title: 'Try Another Month',
              description: 'Select a different month with existing data',
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime.now();
                    });
                    _generateReport();
                  },
                  icon: const Icon(Icons.today),
                  label: const Text('This Month'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final letter = grade.substring(0, 1).toUpperCase();
    switch (letter) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getGradeLabel(String grade) {
    final letter = grade.substring(0, 1).toUpperCase();
    switch (letter) {
      case 'A':
        return 'Outstanding Performance!';
      case 'B':
        return 'Great Job!';
      case 'C':
        return 'Good Effort';
      case 'D':
        return 'Needs Improvement';
      case 'F':
        return 'Requires Attention';
      default:
        return 'Not Rated';
    }
  }

  IconData _getMedicalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'checkup':
        return Icons.health_and_safety;
      case 'medication':
        return Icons.medication;
      case 'surgery':
        return Icons.local_hospital;
      case 'grooming':
        return Icons.content_cut;
      default:
        return Icons.medical_services;
    }
  }

  void _exportReport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _shareReport() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
