// providers/pet_providers.dart
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/services/avatar_upload_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/pet.dart';
import '../models/medical_record.dart';
import 'auth_providers.dart';

part 'pet_providers.g.dart';

// Pets list provider
@riverpod
class Pets extends _$Pets {
  @override
  Future<List<Pet>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final supabase = ref.watch(supabaseProvider);
    final response = await supabase
        .from('pets')
        .select()
        .eq('owner_id', user.id)
        .order('created_at');

    return (response as List).map((json) => Pet.fromJson(json)).toList();
  }

  Future<void> addPet(Pet pet) async {
    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) throw Exception('User not logged in');

    await supabase.from('pets').insert({
      'owner_id': user.id,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'birth_date': pet.birthDate?.toIso8601String(),
      'weight': pet.weight,
      'photo_url': pet.photoUrl,
      'microchip_id': pet.microchipId,
    });

    ref.invalidateSelf();
  }

  Future<void> updatePet(Pet pet) async {
    final supabase = ref.read(supabaseProvider);

    await supabase
        .from('pets')
        .upsert({
          'name': pet.name,
          'species': pet.species,
          'breed': pet.breed,
          'birth_date': pet.birthDate?.toIso8601String(),
          'weight': pet.weight,
          'photo_url': pet.photoUrl,
          'microchip_id': pet.microchipId,
        })
        .eq('id', pet.id);

    ref.invalidateSelf();
  }

  Future<void> deletePet(String petId) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('pets').delete().eq('id', petId);
    ref.invalidateSelf();
  }

  AvatarUploadService get _avatarService =>
      AvatarUploadService(ref.read(supabaseProvider));

  //     Future<String> uploadPetAvatar({
  //   required XFile imageFile,
  //   Function(double)? onProgress,
  // }) async {
  //   final user = ref.read(currentUserProvider);
  //   if (user == null) throw Exception('No user logged in');

  //   try {
  //     // Upload image to storage
  //     final petAvatarUrl = await _avatarService.uploadAvatar(
  //       userId: user.id,
  //       imageFile: imageFile,
  //       onProgress: onProgress,
  //     );

  //     // Update profile with new avatar URL
  //     await updatePet(

  //       photo_url: petAvatarUrl
  //     );

  //     return petAvatarUrl;
  //   } catch (e) {
  //     throw Exception('Failed to upload avatar: $e');
  //   }
  // }
}

// Selected pet provider (for pet details screen)
@riverpod
class SelectedPet extends _$SelectedPet {
  @override
  Pet? build() {
    print('SelectedPet provider initialized with state: null');
    return null;
  }

  void selectPet(Pet pet) {
    print('Selecting pet: ${pet.name} (id: ${pet.id})');
    state = pet;
  }

  void clearSelection() {
    print('Clearing selected pet');
    state = null;
  }
}

// Pet medical records provider
@riverpod
class PetMedicalRecords extends _$PetMedicalRecords {
  @override
  Future<List<MedicalRecord>> build(String petId) async {
    final supabase = ref.watch(supabaseProvider);
    final response = await supabase
        .from('medical_records')
        .select()
        .eq('pet_id', petId)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => MedicalRecord.fromJson(json))
        .toList();
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    final supabase = ref.read(supabaseProvider);

    await supabase.from('medical_records').insert({
      'pet_id': record.petId,
      'record_type': record.recordType,
      'title': record.title,
      'description': record.description,
      'date': record.date.toIso8601String(),
      'veterinarian': record.veterinarian,
      'cost': record.cost,
      'next_due_date': record.nextDueDate?.toIso8601String(),
    });

    ref.invalidateSelf();
  }
}
