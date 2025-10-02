import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class FeedingScheduleScreen extends StatefulWidget {
  final String petId;

  const FeedingScheduleScreen({required this.petId});

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final _formKey = GlobalKey<FormState>();

  String _species = 'Dog';
  String _breed = '';
  double _weight = 10.0;
  int _age = 1;

  String? _schedule;
  bool _isGenerating = false;

  Future<void> _generateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _schedule = null;
    });

    try {
      final schedule = await _aiHelper.generateFeedingSchedule(
        _species,
        _breed,
        _weight,
        _age,
      );

      setState(() {
        _schedule = schedule;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _schedule = 'Error generating schedule: $e';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Schedule'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pet Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Species Dropdown
                      DropdownButtonFormField<String>(
                        value: _species,
                        decoration: InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Dog', 'Cat', 'Bird', 'Rabbit']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _species = value!);
                        },
                      ),

                      SizedBox(height: 16),

                      // Breed
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Breed',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter breed';
                          }
                          return null;
                        },
                        onChanged: (value) => _breed = value,
                      ),

                      SizedBox(height: 16),

                      // Weight
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _weight.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                        onChanged:
                            (value) => _weight = double.tryParse(value) ?? 10.0,
                      ),

                      SizedBox(height: 16),

                      // Age
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age (years)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _age.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter age';
                          }
                          return null;
                        },
                        onChanged: (value) => _age = int.tryParse(value) ?? 1,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isGenerating ? null : _generateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isGenerating
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text('Generate Schedule'),
              ),

              if (_schedule != null) ...[
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, color: Colors.teal),
                            SizedBox(width: 8),
                            Text(
                              'Feeding Schedule',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        Text(
                          _schedule!,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
