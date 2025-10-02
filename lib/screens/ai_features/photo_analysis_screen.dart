import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/services/firebase_ai_service.dart';
// Import your PetAIHelper and models

// ============================================
// 1. PHOTO ANALYSIS SCREEN
// ============================================

class PhotoAnalysisScreen extends StatefulWidget {
  @override
  State<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends State<PhotoAnalysisScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _analysis;
  bool _isAnalyzing = false;
  String _analysisType = 'breed'; // breed, health, general

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysis = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _analyzePhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    try {
      final imageBytes = await _selectedImage!.readAsBytes();

      String query;
      switch (_analysisType) {
        case 'breed':
          query =
              'What breed is this pet? Provide detailed information about the breed characteristics.';
          break;
        case 'health':
          query =
              'Analyze this pet\'s physical appearance. Are there any visible health concerns or issues I should be aware of?';
          break;
        case 'general':
          query =
              'Describe this pet in detail. Include breed, age estimate, physical condition, and any notable features.';
          break;
        default:
          query = 'Analyze this pet photo.';
      }

      final result = await _aiHelper.analyzePetPhoto(imageBytes, query);

      setState(() {
        _analysis = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _analysis = 'Error analyzing photo: $e';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Photo Analysis'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Select a photo to analyze',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),

            // Image Source Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Analysis Type Selection
            if (_selectedImage != null) ...[
              Text(
                'What would you like to know?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text('Breed ID'),
                    selected: _analysisType == 'breed',
                    onSelected: (selected) {
                      setState(() => _analysisType = 'breed');
                    },
                  ),
                  ChoiceChip(
                    label: Text('Health Check'),
                    selected: _analysisType == 'health',
                    onSelected: (selected) {
                      setState(() => _analysisType = 'health');
                    },
                  ),
                  ChoiceChip(
                    label: Text('General Info'),
                    selected: _analysisType == 'general',
                    onSelected: (selected) {
                      setState(() => _analysisType = 'general');
                    },
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Analyze Button
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isAnalyzing
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text('Analyze Photo'),
              ),
            ],

            // Analysis Result
            if (_analysis != null) ...[
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
                          Icon(Icons.auto_awesome, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'AI Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24),
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
