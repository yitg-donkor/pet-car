// services/storage_service.dart
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String?> uploadPetPhoto(File imageFile, String petId) async {
    final String fileName =
        '${petId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from('pet-photos').upload(fileName, imageFile);

    return _supabase.storage.from('pet-photos').getPublicUrl(fileName);
  }
}
