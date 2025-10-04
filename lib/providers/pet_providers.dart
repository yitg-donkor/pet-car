// providers/pet_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/pet.dart';
import 'offline_providers.dart'; // This gives you access to all the providers from offline_providers
import 'auth_providers.dart';

part 'pet_providers.g.dart';

// ============================================
// OFFLINE-FIRST PETS PROVIDER
// ============================================

@riverpod
class PetsOffline extends _$PetsOffline {
  @override
  Future<List<Pet>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    // Always read from local DB first
    final petLocalDB = ref.watch(petLocalDBProvider);
    final localPets = await petLocalDB.getAllPets(user.id);

    // Sync in background
    final syncService = ref.watch(unifiedSyncServiceProvider);
    syncService.fullSync(user.id).catchError((e) {
      print('Background sync error: $e');
    });

    return localPets;
  }

  Future<void> addPet(Pet pet) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('User not logged in');

    final petLocalDB = ref.read(petLocalDBProvider);
    final petWithOwner = Pet(
      id: '',
      ownerId: user.id,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      birthDate: pet.birthDate,
      weight: pet.weight,
      photoUrl: pet.photoUrl,
      microchipId: pet.microchipId,
    );

    await petLocalDB.createPet(petWithOwner);

    // Sync in background
    final syncService = ref.read(unifiedSyncServiceProvider);
    syncService.syncPetsToSupabase().catchError((e) {
      print('Background sync error: $e');
    });

    ref.invalidateSelf();
  }

  Future<void> updatePet(Pet pet) async {
    final petLocalDB = ref.read(petLocalDBProvider);
    await petLocalDB.updatePet(pet);

    // Sync in background
    final syncService = ref.read(unifiedSyncServiceProvider);
    syncService.syncPetsToSupabase().catchError((e) {
      print('Background sync error: $e');
    });

    ref.invalidateSelf();
  }

  Future<void> deletePet(String petId) async {
    final petLocalDB = ref.read(petLocalDBProvider);
    await petLocalDB.deletePet(petId);

    // Delete from Supabase if online
    final syncService = ref.read(unifiedSyncServiceProvider);
    if (await syncService.hasInternetConnection()) {
      try {
        await syncService.supabase.from('pets').delete().eq('id', petId);
      } catch (e) {
        print('Error deleting from Supabase: $e');
      }
    }

    ref.invalidateSelf();
  }

  Future<void> manualSync() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final syncService = ref.read(unifiedSyncServiceProvider);
    await syncService.fullSync(user.id);
    ref.invalidateSelf();
  }
}

// ============================================
// SELECTED PET PROVIDER
// ============================================

@riverpod
class SelectedPet extends _$SelectedPet {
  @override
  Pet? build() {
    return null;
  }

  void selectPet(Pet pet) {
    state = pet;
  }

  void clearSelection() {
    state = null;
  }
}
