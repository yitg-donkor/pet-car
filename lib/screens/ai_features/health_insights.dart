import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class HealthInsightsScreen extends StatefulWidget {
  final String petId;

  const HealthInsightsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<HealthInsightsScreen> createState() => _HealthInsightsScreenState();
}

class _HealthInsightsScreenState extends State<HealthInsightsScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  Map<String, dynamic> _insights = {
    'score': 0.0,
    'analysis': '',
    'trends': <String>[],
  };
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  Future<void> _generateInsights() async {
    setState(() {
      _isAnalyzing = true;
      _insights = {'score': 0.0, 'analysis': '', 'trends': <String>[]};
    });

    try {
      // TODO: Fetch actual health data from Firestore
      final prompt = '''
Analyze this pet's health data and provide insights:

Recent Activity:
- Weight: Stable at 30kg
- Exercise: 2 walks daily, 30 minutes each
- Appetite: Normal
- Recent checkup: All clear
- Sleep: 12-14 hours daily

Medical History:
- Vaccinations up to date
- No chronic conditions
- Minor dental tartar noted
- Last vet visit: 2 months ago

Provide a response in this exact format:

SCORE: [number from 1.0-10.0]

TRENDS:
- [trend 1]
- [trend 2]
- [trend 3]
- [trend 4]

ANALYSIS:
[Provide detailed analysis with:
1. Overall health assessment
2. Recommendations for improvement
3. Areas to monitor
4. Preventive care suggestions]
''';

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
        score = 7.5;
      }

      if (trends.isEmpty) {
        trends = [
          'Weight stable and within healthy range',
          'Good activity level maintained',
          'Dental care recommended',
          'All vaccinations current',
        ];
      }

      if (analysis.isEmpty) {
        analysis = response;
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate health insights'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Insights'),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('About Health Insights'),
                      content: Text(
                        'AI-powered health analysis based on your pet\'s medical records, '
                        'activity levels, and overall care history. This provides general '
                        'guidance and should not replace professional veterinary advice.',
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
        ],
      ),
      body:
          _isAnalyzing
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.lightBlue,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Analyzing health data...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _generateInsights,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Health Score Card
                      Card(
                        elevation: 8,
                        color: Colors.lightBlue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
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
                              SizedBox(height: 20),
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
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
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

                      SizedBox(height: 28),

                      // Health Trends Section
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.lightBlue),
                          SizedBox(width: 8),
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
                      SizedBox(height: 16),

                      if ((_insights['trends'] as List<String>).isEmpty)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No trends available. Generate insights to see health trends.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ...(_insights['trends'] as List<String>).map((trend) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                trend,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                      SizedBox(height: 28),

                      // AI Analysis Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.lightBlue,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
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
                              Divider(height: 32, thickness: 1),
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

                      SizedBox(height: 24),

                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _generateInsights,
                        icon: Icon(Icons.refresh, size: 22),
                        label: Text(
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
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),

                      SizedBox(height: 20),

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
                            SizedBox(width: 12),
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
                                  SizedBox(height: 4),
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

                      SizedBox(height: 16),
                    ],
                  ),
                ),
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
