import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/activity_log.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/local_db/sqflite_db.dart';

class HealthInsightsScreen extends ConsumerStatefulWidget {
  final String petId;

  const HealthInsightsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  ConsumerState<HealthInsightsScreen> createState() =>
      _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends ConsumerState<HealthInsightsScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  Map<String, dynamic> _insights = {
    'score': 0.0,
    'analysis': '',
    'trends': <String>[],
  };
  bool _isAnalyzing = false;
  bool _hasNoData = false;
  bool _hasLimitedData = false;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  Future<void> _generateInsights() async {
    setState(() {
      _isAnalyzing = true;
      _hasNoData = false;
      _hasLimitedData = false;
      _insights = {'score': 0.0, 'analysis': '', 'trends': <String>[]};
    });

    try {
      // Fetch real data from database
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      final activityLogDB = ActivityLogLocalDB();

      final medicalRecords = await medicalRecordDB.getMedicalRecordsForPet(
        widget.petId,
      );
      final activityLogs = await activityLogDB.getActivityLogsForPet(
        widget.petId,
      );

      // Check if we have any data at all
      if (medicalRecords.isEmpty && activityLogs.isEmpty) {
        setState(() {
          _hasNoData = true;
          _isAnalyzing = false;
          _insights = {
            'score': 0.0,
            'analysis':
                'No data available to generate health insights. Start by:\n\n'
                '1. Adding medical records (vaccinations, checkups, etc.)\n'
                '2. Logging daily activities (walks, meals, etc.)\n\n'
                'Once you have some data, come back here to get AI-powered health insights!',
            'trends': <String>[],
          };
        });
        return;
      }

      // Check if we have limited data
      if (medicalRecords.length < 2 && activityLogs.length < 5) {
        _hasLimitedData = true;
      }

      // Build the prompt with real data
      final prompt = _buildPromptFromData(medicalRecords, activityLogs);

      final response = await _aiHelper.generateHealthInsights(prompt);

      // Parse the AI response
      double score = 0.0;
      List<String> trends = [];
      String analysis = '';

      final lines = response.split('\n');
      String currentSection = '';

      for (var line in lines) {
        final trimmedLine = line.trim();

        if (trimmedLine.startsWith('SCORE:')) {
          final scoreMatch = RegExp(r'[\d.]+').firstMatch(trimmedLine);
          if (scoreMatch != null) {
            score = double.tryParse(scoreMatch.group(0)!) ?? 0.0;
            if (score > 10.0) score = 10.0;
            if (score < 0.0) score = 0.0;
          }
          currentSection = '';
        } else if (trimmedLine.startsWith('TRENDS:')) {
          currentSection = 'trends';
        } else if (trimmedLine.startsWith('ANALYSIS:')) {
          currentSection = 'analysis';
        } else if (trimmedLine.startsWith('-') && currentSection == 'trends') {
          final trend = trimmedLine.substring(1).trim();
          if (trend.isNotEmpty) {
            trends.add(trend);
          }
        } else if (currentSection == 'analysis' && trimmedLine.isNotEmpty) {
          analysis += (analysis.isEmpty ? '' : '\n') + trimmedLine;
        }
      }

      // Fallback values if parsing fails
      if (score == 0.0) {
        score = _hasLimitedData ? 6.0 : 7.5;
      }

      if (trends.isEmpty) {
        trends = _generateFallbackTrends(medicalRecords, activityLogs);
      }

      if (analysis.isEmpty) {
        analysis = response;
      }

      // Add data limitation warning if needed
      if (_hasLimitedData) {
        analysis =
            '⚠️ LIMITED DATA NOTICE: This analysis is based on limited records. Add more medical records and activity logs for more accurate insights.\n\n$analysis';
      }

      setState(() {
        _insights = {'score': score, 'analysis': analysis, 'trends': trends};
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _insights = {
          'score': 0.0,
          'analysis':
              'Error generating insights: $e\n\nPlease try again or check your internet connection.',
          'trends': <String>[],
        };
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate health insights'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _generateInsights,
            ),
          ),
        );
      }
    }
  }

  String _buildPromptFromData(
    List<MedicalRecord> medicalRecords,
    List<ActivityLog> activityLogs,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Analyze this pet\'s health data and provide insights:\n');

    // Medical Records Section
    buffer.writeln('MEDICAL RECORDS (${medicalRecords.length} total):');
    if (medicalRecords.isEmpty) {
      buffer.writeln('- No medical records available');
    } else {
      // Group by type
      final recordsByType = <String, List<MedicalRecord>>{};
      for (var record in medicalRecords) {
        recordsByType.putIfAbsent(record.recordType, () => []).add(record);
      }

      for (var entry in recordsByType.entries) {
        buffer.writeln('\n${entry.key.toUpperCase()} (${entry.value.length}):');
        for (var record in entry.value.take(5)) {
          // Limit to 5 most recent
          buffer.writeln('- ${record.title} (${_formatDate(record.date)})');
          if (record.description != null && record.description!.isNotEmpty) {
            buffer.writeln('  Details: ${record.description}');
          }
          if (record.veterinarian != null) {
            buffer.writeln('  Vet: ${record.veterinarian}');
          }
          if (record.nextDueDate != null) {
            buffer.writeln('  Next due: ${_formatDate(record.nextDueDate!)}');
          }
        }
      }
    }

    buffer.writeln('\n');

    // Activity Logs Section
    buffer.writeln('ACTIVITY LOGS (${activityLogs.length} total):');
    if (activityLogs.isEmpty) {
      buffer.writeln('- No activity logs available');
    } else {
      // Group by type
      final logsByType = <String, List<ActivityLog>>{};
      for (var log in activityLogs) {
        logsByType.putIfAbsent(log.activityType, () => []).add(log);
      }

      for (var entry in logsByType.entries) {
        buffer.writeln('\n${entry.key.toUpperCase()} (${entry.value.length}):');
        final recentLogs = entry.value.take(5).toList();
        for (var log in recentLogs) {
          buffer.writeln('- ${log.title} (${_formatDateTime(log.timestamp)})');
          if (log.details != null && log.details!.isNotEmpty) {
            buffer.writeln('  Details: ${log.details}');
          }
          if (log.duration != null) {
            buffer.writeln('  Duration: ${log.duration} minutes');
          }
          if (log.amount != null) {
            buffer.writeln('  Amount: ${log.amount}');
          }
        }
      }

      // Get health-related logs
      final healthLogs =
          activityLogs.where((log) => log.isHealthRelated).toList();
      if (healthLogs.isNotEmpty) {
        buffer.writeln('\nHEALTH-RELATED ACTIVITIES (${healthLogs.length}):');
        for (var log in healthLogs.take(5)) {
          buffer.writeln('- ${log.title} (${_formatDateTime(log.timestamp)})');
        }
      }
    }

    buffer.writeln('\n');
    buffer.writeln('DATA COMPLETENESS:');
    buffer.writeln('- Medical Records: ${medicalRecords.length}');
    buffer.writeln('- Activity Logs: ${activityLogs.length}');
    buffer.writeln(
      '- Health Logs: ${activityLogs.where((log) => log.isHealthRelated).length}',
    );

    if (_hasLimitedData) {
      buffer.writeln(
        '\nNOTE: Limited data available. Provide insights based on what we have, '
        'but mention that more comprehensive analysis would be possible with additional records.',
      );
    }

    buffer.writeln('\nProvide a response in this exact format:\n');
    buffer.writeln('SCORE: [number from 1.0-10.0]\n');
    buffer.writeln('TRENDS:');
    buffer.writeln('- [trend 1]');
    buffer.writeln('- [trend 2]');
    buffer.writeln('- [trend 3]');
    buffer.writeln('- [trend 4]\n');
    buffer.writeln('ANALYSIS:');
    buffer.writeln('[Provide detailed analysis with:');
    buffer.writeln('1. Overall health assessment based on available data');
    buffer.writeln('2. Recommendations for improvement');
    buffer.writeln('3. Areas to monitor');
    buffer.writeln('4. Preventive care suggestions');
    buffer.writeln('5. What additional data would be helpful]');

    return buffer.toString();
  }

  List<String> _generateFallbackTrends(
    List<MedicalRecord> medicalRecords,
    List<ActivityLog> activityLogs,
  ) {
    final trends = <String>[];

    // Medical record trends
    if (medicalRecords.isNotEmpty) {
      final recentRecords = medicalRecords.take(3).toList();
      final types = recentRecords.map((r) => r.recordType).toSet();

      if (types.contains('vaccination')) {
        trends.add('Vaccinations are being tracked');
      }
      if (types.contains('checkup')) {
        trends.add('Regular checkups being maintained');
      }
      if (types.contains('medication')) {
        trends.add('Medications being administered');
      }
    }

    // Activity trends
    if (activityLogs.isNotEmpty) {
      final recentLogs = activityLogs.take(7).toList();
      final types = recentLogs.map((l) => l.activityType).toSet();

      if (types.contains('exercise') || types.contains('walk')) {
        trends.add('Active lifestyle with regular exercise');
      }
      if (types.contains('feeding') || types.contains('meal')) {
        trends.add('Regular feeding schedule maintained');
      }
      if (types.contains('grooming')) {
        trends.add('Grooming care being tracked');
      }
    }

    // If still no trends
    if (trends.isEmpty) {
      trends.add('Health tracking has been initiated');
      if (_hasLimitedData) {
        trends.add('More data needed for comprehensive trends');
      }
    }

    return trends;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('About Health Insights'),
                      content: const Text(
                        'AI-powered health analysis based on your pet\'s medical records, '
                        'activity levels, and overall care history. This provides general '
                        'guidance and should not replace professional veterinary advice.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isAnalyzing
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.lightBlue,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing health data...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : _hasNoData
              ? _buildNoDataState()
              : RefreshIndicator(
                onRefresh: _generateInsights,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Limited Data Warning
                      if (_hasLimitedData) _buildLimitedDataWarning(),

                      // Health Score Card
                      Card(
                        elevation: 8,
                        color: Colors.lightBlue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Overall Health Score',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: CircularProgressIndicator(
                                      value:
                                          (_insights['score'] as double) / 10,
                                      strokeWidth: 14,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getScoreColor(
                                          _insights['score'] as double,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        (_insights['score'] as double)
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: _getScoreColor(
                                            _insights['score'] as double,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'out of 10',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(
                                    _insights['score'] as double,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getScoreColor(
                                      _insights['score'] as double,
                                    ).withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _getScoreLabel(_insights['score'] as double),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(
                                      _insights['score'] as double,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Health Trends Section
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.lightBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Health Trends',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if ((_insights['trends'] as List<String>).isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No trends available. Add more data to see health trends.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ...(_insights['trends'] as List<String>).map((trend) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                trend,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                      const SizedBox(height: 28),

                      // AI Analysis Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                      color: Colors.lightBlue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.lightBlue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Detailed Analysis',
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
                                (_insights['analysis'] as String).isEmpty
                                    ? 'No analysis available yet.'
                                    : _insights['analysis'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _generateInsights,
                        icon: const Icon(Icons.refresh, size: 22),
                        label: const Text(
                          'Refresh Insights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Premium Badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade100,
                              Colors.orange.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.amber.shade700,
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
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Advanced AI health monitoring and insights',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
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
            Icon(Icons.analytics_outlined, size: 100, color: Colors.grey[400]),
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
              'To generate health insights, you need to:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              icon: Icons.medical_services,
              title: 'Add Medical Records',
              description: 'Track vaccinations, checkups, and treatments',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.fitness_center,
              title: 'Log Activities',
              description: 'Record walks, meals, and daily routines',
              color: Colors.green,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
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

  Widget _buildActionCard({
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

  Widget _buildLimitedDataWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited Data',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add more records for comprehensive insights',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    if (score >= 4.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 8.0) return 'Excellent Health';
    if (score >= 6.0) return 'Good Health';
    if (score >= 4.0) return 'Fair Health';
    if (score >= 2.0) return 'Needs Attention';
    return 'Critical - See Vet';
  }
}
