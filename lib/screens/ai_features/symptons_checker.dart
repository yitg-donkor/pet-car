import 'package:flutter/material.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

class SymptomCheckerScreen extends StatefulWidget {
  final Pet pet;

  const SymptomCheckerScreen({required this.pet});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final TextEditingController _controller = TextEditingController();
  String? _analysis;
  bool _isLoading = false;

  Future<void> _analyzeSymptoms() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    try {
      final result = await _aiHelper.analyzeSymptoms(
        widget.pet.name,
        widget.pet.species,
        _controller.text,
      );

      setState(() {
        _analysis = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analysis = 'Error analyzing symptoms. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptom Checker')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.amber[800]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is not a substitute for professional veterinary care. Always consult your vet for proper diagnosis.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'What symptoms is ${widget.pet.name} experiencing?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Describe the symptoms in detail...\nExample: Not eating, lethargic, vomiting',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeSymptoms,
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text('Analyze Symptoms'),
            ),
            if (_analysis != null) ...[
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_hospital, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'AI Analysis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(_analysis!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
