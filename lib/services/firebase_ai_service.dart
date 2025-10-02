import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class FirebaseAIService {
  late final GenerativeModel _model;

  FirebaseAIService() {
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
  }

  Future<String> generateText(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      throw Exception('Error generating text: $e');
    }
  }

  Stream<String> generateTextStream(String prompt) async* {
    try {
      final response = _model.generateContentStream([Content.text(prompt)]);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  Future<String> analyzeImage(String prompt, List<int> imageBytes) async {
    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ]);
      return response.text ?? 'No response generated';
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }

  ChatSession startChat({List<Content>? history}) {
    return _model.startChat(history: history);
  }
}

class PetAIHelper {
  final FirebaseAIService _aiService = FirebaseAIService();

  Future<String> chatAboutPet(
    String petName,
    String species,
    String userMessage,
  ) async {
    final prompt = '''
    I have a $species named $petName.
    Question: $userMessage
    
    Please provide helpful, practical advice. Always remind me to consult 
    a veterinarian for proper diagnosis and treatment.
    ''';

    return await _aiService.generateText(prompt);
  }

  // Generate pet care advice
  Future<String> getPetCareAdvice(String species, String breed, int age) async {
    final prompt = '''
    Give me specific care advice for a $age year old $breed $species.
    Include:
    - Daily care routine
    - Dietary recommendations
    - Exercise needs
    - Health considerations
    Keep it concise and practical.
    ''';

    return await _aiService.generateText(prompt);
  }

  Future<String> analyzeSymptoms(
    String petName,
    String species,
    String symptoms,
  ) async {
    final prompt = '''
    A $species named $petName is showing these symptoms: $symptoms
    
    Provide:
    1. Possible causes (general information only)
    2. Whether immediate veterinary care is recommended
    3. Home care suggestions if appropriate
    
    Important: This is for informational purposes only, not a diagnosis.
    Always recommend consulting a veterinarian for proper medical advice.
    ''';

    return await _aiService.generateText(prompt);
  }

  Future<String> summarizeMedicalHistory(
    List<Map<String, dynamic>> records,
  ) async {
    final recordsText = records
        .map((r) => '- ${r['date']}: ${r['title']} (${r['record_type']})')
        .join('\n');

    final prompt = '''
    Summarize this pet's medical history and identify any patterns or upcoming care needs:
    
    $recordsText
    
    Provide a brief summary highlighting:
    - Key health events
    - Upcoming vaccinations or checkups
    - Any patterns to monitor
    ''';

    return await _aiService.generateText(prompt);
  }

  // Analyze pet photo (breed identification, health check)
  Future<String> analyzePetPhoto(List<int> imageBytes, String query) async {
    final prompt = '''
    $query
    Please provide detailed observations about this pet.
    ''';

    return await _aiService.analyzeImage(prompt, imageBytes);
  }

  // Generate feeding schedule
  Future<String> generateFeedingSchedule(
    String species,
    String breed,
    double weight,
    int age,
  ) async {
    final prompt = '''
    Create a detailed feeding schedule for:
    - Species: $species
    - Breed: $breed
    - Weight: $weight kg
    - Age: $age years
    
    Include:
    - Meal frequency
    - Portion sizes
    - Recommended food types
    - Feeding times
    ''';

    return await _aiService.generateText(prompt);
  }

  // Get training tips
  Future<String> getTrainingTips(
    String species,
    String breed,
    String behaviorIssue,
  ) async {
    final prompt = '''
    Provide training tips for a $breed $species with this behavior: $behaviorIssue
    
    Include:
    - Step-by-step training approach
    - Positive reinforcement techniques
    - Common mistakes to avoid
    - Expected timeline for improvement
    ''';

    return await _aiService.generateText(prompt);
  }

  Stream<String> chatWithVetAssistant(
    String message,
    List<Content> chatHistory,
  ) {
    final chat = _aiService.startChat(history: chatHistory);

    return Stream.fromFuture(
      chat.sendMessage(Content.text(message)),
    ).asyncExpand((response) async* {
      yield response.text ?? '';
    });
  }

  Future<String> generateMonthlyReport(String prompt) async {
    return await _aiService.generateText(prompt);
  }

  Future<String> generateSmartReminders(String prompt) async {
    return await _aiService.generateText(prompt);
  }

  Future<String> generateHealthInsights(String prompt) async {
    return await _aiService.generateText(prompt);
  }
}
