import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/services/firebase_ai_service.dart';

// ============================================
// PHOTO ANALYSIS SCREEN
// ============================================

class PhotoAnalysisScreen extends StatefulWidget {
  const PhotoAnalysisScreen({super.key});

  @override
  State<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends State<PhotoAnalysisScreen> {
  final PetAIHelper _aiHelper = PetAIHelper();
  final ImagePicker _picker = ImagePicker();

  // Works on Web, Android and iOS
  Uint8List? _selectedImage;

  String? _analysis;
  bool _isAnalyzing = false;
  String _analysisType = 'breed';

  // ============================================
  // PICK IMAGE
  // ============================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        // Convert XFile to bytes
        final bytes = await image.readAsBytes();

        setState(() {
          _selectedImage = bytes;
          _analysis = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // ============================================
  // ANALYZE PHOTO
  // ============================================

  Future<void> _analyzePhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    try {
      final imageBytes = _selectedImage!;

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

      if (!mounted) return;

      setState(() {
        _analysis = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _analysis = 'Error analyzing photo: $e';
        _isAnalyzing = false;
      });
    }
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Photo Analysis'),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================
            // IMAGE DISPLAY
            // ============================================
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: Image.memory(
                  _selectedImage!,
                  height: 300,
                  width: double.infinity,
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

                    const SizedBox(height: 16),

                    Text(
                      'Select a photo to analyze',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ============================================
            // IMAGE SOURCE BUTTONS
            // ============================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },

                    icon: const Icon(Icons.camera_alt),

                    label: const Text('Camera'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },

                    icon: const Icon(Icons.photo_library),

                    label: const Text('Gallery'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ============================================
            // ANALYSIS OPTIONS
            // ============================================
            if (_selectedImage != null) ...[
              const Text(
                'What would you like to know?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,

                children: [
                  ChoiceChip(
                    label: const Text('Breed ID'),

                    selected: _analysisType == 'breed',

                    onSelected: (selected) {
                      setState(() {
                        _analysisType = 'breed';
                      });
                    },
                  ),

                  ChoiceChip(
                    label: const Text('Health Check'),

                    selected: _analysisType == 'health',

                    onSelected: (selected) {
                      setState(() {
                        _analysisType = 'health';
                      });
                    },
                  ),

                  ChoiceChip(
                    label: const Text('General Info'),

                    selected: _analysisType == 'general',

                    onSelected: (selected) {
                      setState(() {
                        _analysisType = 'general';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // ANALYZE BUTTON
              // ============================================
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzePhoto,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child:
                    _isAnalyzing
                        ? const SizedBox(
                          height: 20,
                          width: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Analyze Photo'),
              ),
            ],

            // ============================================
            // ANALYSIS RESULT
            // ============================================
            if (_analysis != null) ...[
              const SizedBox(height: 24),

              Card(
                elevation: 4,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: const [
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

                      const Divider(height: 24),
                      MarkdownBody(
                        data: _analysis!,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: Colors.black, fontSize: 14),
                          
                          strong: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                          h1: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          h2: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          h3: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          listBullet: TextStyle(color: Colors.black),
                        ),
                      ),

                      //  Text(
                      //     _analysis!,
                      //   ) ,
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
