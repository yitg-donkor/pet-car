// 7. MONTHLY REPORT SCREEN (Premium)
// ============================================

import 'package:flutter/material.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  final Pet pet;

  const MonthlyReportScreen({required this.pet});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  Map<String, dynamic>? _report;
  bool _isGenerating = false;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // TODO: Fetch actual data from db
      final prompt = '''
      Generate a comprehensive monthly pet care report for September 2025:
      
      Activities completed:
      - 60 walks (average 30 min each)
      - 3 vet visits
      - 4 grooming sessions
      - All medications on schedule
      
      Health metrics:
      - Weight: Stable
      - Energy level: High
      - Appetite: Normal
      
      Provide:
      1. Executive summary
      2. Key achievements
      3. Areas for improvement
      4. Recommendations for next month
      ''';

      final response = await _aiHelper.generateMonthlyReport(prompt);

      setState(() {
        _report = {
          'summary': response,
          'stats': {
            'walks': 60,
            'vet_visits': 3,
            'medications': '100% on time',
            'grooming': 4,
          },
          'highlights': [
            'All vaccinations completed',
            'Weight maintained perfectly',
            'Excellent activity levels',
          ],
        };
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Report'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Share report
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body:
          _isGenerating
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating monthly report...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Month Selector
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left),
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
                            Text(
                              _formatMonth(_selectedMonth),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month + 1,
                                  );
                                });
                                _generateReport();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Quick Stats
                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Walks',
                            _report?['stats']['walks'].toString() ?? '0',
                            Icons.directions_walk,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Vet Visits',
                            _report?['stats']['vet_visits'].toString() ?? '0',
                            Icons.local_hospital,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Medications',
                            _report?['stats']['medications'] ?? '0%',
                            Icons.medication,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Grooming',
                            _report?['stats']['grooming'].toString() ?? '0',
                            Icons.cut,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Highlights
                    Text(
                      'Month Highlights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),

                    ...((_report?['highlights'] as List?) ?? []).map((
                      highlight,
                    ) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.star, color: Colors.amber),
                          title: Text(highlight),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 24),

                    // AI Summary
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.deepPurple,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AI Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 24),
                            Text(
                              _report?['summary'] ?? 'No summary available',
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _generateReport,
                      icon: Icon(Icons.refresh),
                      label: Text('Regenerate Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
