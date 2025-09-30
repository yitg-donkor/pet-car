// services/pet_service.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/providers/auth_providers.dart';

part 'pet_service.g.dart';

@riverpod
class PetService extends _$PetService {
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
    await supabase.from('pets').insert(pet.toJson());
    ref.invalidateSelf();
  }

  Future<void> updatePet(Pet pet) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('pets').update(pet.toJson()).eq('id', pet.id);
    ref.invalidateSelf();
  }

  Future<void> deletePet(String petId) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('pets').delete().eq('id', petId);
    ref.invalidateSelf();
  }
}
