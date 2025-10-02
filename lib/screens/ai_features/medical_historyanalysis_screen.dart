import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class MedicalHistoryAnalysisScreen extends StatefulWidget {
  final String petId;

  const MedicalHistoryAnalysisScreen({Key? key, required this.petId})
    : super(key: key);

  @override
  State<MedicalHistoryAnalysisScreen> createState() =>
      _MedicalHistoryAnalysisScreenState();
}

class _MedicalHistoryAnalysisScreenState
    extends State<MedicalHistoryAnalysisScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();

  String _summary = '';
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _analyzeMedicalHistory();
  }

  Future<void> _analyzeMedicalHistory() async {
    setState(() {
      _isAnalyzing = true;
      _summary = '';
    });

    try {
      // TODO: Fetch actual medical records from Firestore
      // Replace this with your actual Firestore query
      // Example: final records = await FirebaseFirestore.instance
      //   .collection('pets')
      //   .doc(widget.petId)
      //   .collection('medical_records')
      //   .orderBy('date', descending: true)
      //   .get();

      _records = [
        {
          'date': '2025-09-15',
          'title': 'Annual Checkup',
          'record_type': 'Checkup',
          'notes': 'General health good, all vitals normal',
        },
        {
          'date': '2025-08-01',
          'title': 'Rabies Vaccine',
          'record_type': 'Vaccination',
          'notes': 'Administered rabies booster, next due 2026',
        },
        {
          'date': '2025-06-20',
          'title': 'Dental Cleaning',
          'record_type': 'Procedure',
          'notes': 'Professional cleaning completed, minor tartar removed',
        },
        {
          'date': '2025-05-10',
          'title': 'Flea Treatment',
          'record_type': 'Medication',
          'notes': 'Monthly flea and tick prevention applied',
        },
        {
          'date': '2025-03-15',
          'title': 'Wellness Exam',
          'record_type': 'Checkup',
          'notes': 'Weight stable, heart and lungs clear',
        },
      ];

      final summary = await _aiHelper.summarizeMedicalHistory(_records);

      setState(() {
        _summary = summary;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _summary =
            'Error analyzing medical history: $e\n\nPlease check your internet connection and try again.';
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to analyze medical history'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _analyzeMedicalHistory,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical History Analysis'),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('About Medical Analysis'),
                      content: Text(
                        'This feature uses AI to analyze your pet\'s medical records and identify patterns, '
                        'upcoming care needs, and important health trends. The analysis is for informational '
                        'purposes and should not replace professional veterinary advice.',
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
                          Colors.purple,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Analyzing medical history...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Reviewing ${_records.length} records',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _analyzeMedicalHistory,
                color: Colors.purple,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Card(
                        color: Colors.purple.shade50,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.purple,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'AI-powered analysis of your pet\'s medical records',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.purple.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Records Summary
                      if (_records.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              color: Colors.purple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Medical Records (${_records.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                _records.length > 5 ? 5 : _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                elevation: 1,
                                child: ListTile(
                                  dense: true,
                                  leading: _getRecordIcon(
                                    record['record_type'],
                                  ),
                                  title: Text(
                                    record['title'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    record['date'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRecordTypeColor(
                                        record['record_type'],
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      record['record_type'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getRecordTypeColor(
                                          record['record_type'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        if (_records.length > 5)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '+ ${_records.length - 5} more records',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        SizedBox(height: 24),
                      ],

                      // AI Summary Card
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
                                      color: Colors.purple.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.purple,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'AI Analysis & Insights',
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
                                _summary.isEmpty
                                    ? 'No analysis available. Click "Refresh Analysis" to generate insights from your pet\'s medical records.'
                                    : _summary,
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

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isAnalyzing ? null : _analyzeMedicalHistory,
                              icon: Icon(Icons.refresh, size: 20),
                              label: Text(
                                'Refresh Analysis',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Disclaimer
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.amber.shade700,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Important Disclaimer',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'This AI analysis is for informational purposes only and should not replace professional veterinary advice. Always consult your veterinarian for medical decisions.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade900,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _getRecordIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'vaccination':
        icon = Icons.vaccines;
        color = Colors.blue;
        break;
      case 'checkup':
        icon = Icons.health_and_safety;
        color = Colors.green;
        break;
      case 'procedure':
        icon = Icons.medical_services;
        color = Colors.orange;
        break;
      case 'medication':
        icon = Icons.medication;
        color = Colors.purple;
        break;
      default:
        icon = Icons.description;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getRecordTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Colors.blue;
      case 'checkup':
        return Colors.green;
      case 'procedure':
        return Colors.orange;
      case 'medication':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
