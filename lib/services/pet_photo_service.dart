// services/pet_photo_service.dart
//
// Replaces services/storage_service.dart (Supabase Storage version).
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PetPhotoService {
  PetPhotoService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadPetPhoto(File imageFile, String petId) async {
    final fileName = '${petId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('pet-photos/$fileName');

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
