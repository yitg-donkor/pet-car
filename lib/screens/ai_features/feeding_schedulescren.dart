// FEEDING SCHEDULE SCREEN
// ============================================

import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
import 'package:pet_care/models/pet.dart'; // Import your Pet model

class FeedingScheduleScreen extends StatefulWidget {
  final Pet pet;

  const FeedingScheduleScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<FeedingScheduleScreen> createState() => _FeedingScheduleScreenState();
}

class _FeedingScheduleScreenState extends State<FeedingScheduleScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _schedule;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with pet data
    _speciesController.text = widget.pet.species;
    _breedController.text = widget.pet.breed ?? '';
    _weightController.text = widget.pet.weight?.toString() ?? '0';
    _ageController.text = widget.pet.age?.toString() ?? '0';
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _generateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _schedule = null;
    });

    try {
      final weight = double.tryParse(_weightController.text) ?? 10.0;
      final age = int.tryParse(_ageController.text) ?? 1;

      final schedule = await _aiHelper.generateFeedingSchedule(
        _speciesController.text,
        _breedController.text,
        weight,
        age,
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
        title: Text('Feeding Schedule - ${widget.pet.name}'),
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

                      // Display Species (read-only)
                      TextFormField(
                        controller: _speciesController,
                        decoration: InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        readOnly: true,
                      ),

                      SizedBox(height: 16),

                      // Display Breed (read-only)
                      TextFormField(
                        controller: _breedController,
                        decoration: InputDecoration(
                          labelText: 'Breed',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        readOnly: true,
                      ),

                      SizedBox(height: 16),

                      // Weight (editable in case it needs updating)
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Age (editable in case it needs updating)
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age (years)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
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
