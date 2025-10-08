// TRAINING TIPS SCREEN
// ============================================

import 'package:flutter/material.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
import 'package:pet_care/models/pet.dart'; // Import your Pet model

class TrainingTipsScreen extends StatefulWidget {
  final Pet pet;

  const TrainingTipsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<TrainingTipsScreen> createState() => _TrainingTipsScreenState();
}

class _TrainingTipsScreenState extends State<TrainingTipsScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();

  String _behaviorIssue = '';

  String? _tips;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Set the text controllers with pet data
    _speciesController.text = widget.pet.species;
    _breedController.text = widget.pet.breed ?? '';
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _generateTips() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _tips = null;
    });

    try {
      final tips = await _aiHelper.getTrainingTips(
        _speciesController.text,
        _breedController.text,
        _behaviorIssue,
      );

      setState(() {
        _tips = tips;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _tips = 'Error generating tips: $e';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Tips - ${widget.pet.name}'),
        backgroundColor: Colors.indigo,
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

                      // Only behavior issue is editable
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Behavior Issue',
                          hintText:
                              'e.g., Excessive barking, jumping on people',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the behavior';
                          }
                          return null;
                        },
                        onChanged: (value) => _behaviorIssue = value,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isGenerating ? null : _generateTips,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
                        : Text('Get Training Tips'),
              ),

              if (_tips != null) ...[
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
                            Icon(Icons.school, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text(
                              'Training Tips',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        Text(
                          _tips!,
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
