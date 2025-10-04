// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petsOfflineHash() => r'8a50aa88634a46ede6650ea6784f6e89eed47204';

/// See also [PetsOffline].
@ProviderFor(PetsOffline)
final petsOfflineProvider =
    AutoDisposeAsyncNotifierProvider<PetsOffline, List<Pet>>.internal(
      PetsOffline.new,
      name: r'petsOfflineProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$petsOfflineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PetsOffline = AutoDisposeAsyncNotifier<List<Pet>>;
String _$selectedPetHash() => r'f7a2614d5bcc421b90966f481db10b226f3be385';

/// See also [SelectedPet].
@ProviderFor(SelectedPet)
final selectedPetProvider =
    AutoDisposeNotifierProvider<SelectedPet, Pet?>.internal(
      SelectedPet.new,
      name: r'selectedPetProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedPetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPet = AutoDisposeNotifier<Pet?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
