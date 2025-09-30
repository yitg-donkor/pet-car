// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petsHash() => r'c8c66bb7b90ea77c53ac749de0b01c7d9499dc28';

/// See also [Pets].
@ProviderFor(Pets)
final petsProvider = AutoDisposeAsyncNotifierProvider<Pets, List<Pet>>.internal(
  Pets.new,
  name: r'petsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Pets = AutoDisposeAsyncNotifier<List<Pet>>;
String _$selectedPetHash() => r'0b5985e9b38fc224eb7ba14990005f6e40a61838';

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
String _$petMedicalRecordsHash() => r'333eece69d00aaec0d89fd9fdbb0ff26f3806a44';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PetMedicalRecords
    extends BuildlessAutoDisposeAsyncNotifier<List<MedicalRecord>> {
  late final String petId;

  FutureOr<List<MedicalRecord>> build(String petId);
}

/// See also [PetMedicalRecords].
@ProviderFor(PetMedicalRecords)
const petMedicalRecordsProvider = PetMedicalRecordsFamily();

/// See also [PetMedicalRecords].
class PetMedicalRecordsFamily extends Family<AsyncValue<List<MedicalRecord>>> {
  /// See also [PetMedicalRecords].
  const PetMedicalRecordsFamily();

  /// See also [PetMedicalRecords].
  PetMedicalRecordsProvider call(String petId) {
    return PetMedicalRecordsProvider(petId);
  }

  @override
  PetMedicalRecordsProvider getProviderOverride(
    covariant PetMedicalRecordsProvider provider,
  ) {
    return call(provider.petId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'petMedicalRecordsProvider';
}

/// See also [PetMedicalRecords].
class PetMedicalRecordsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PetMedicalRecords,
          List<MedicalRecord>
        > {
  /// See also [PetMedicalRecords].
  PetMedicalRecordsProvider(String petId)
    : this._internal(
        () => PetMedicalRecords()..petId = petId,
        from: petMedicalRecordsProvider,
        name: r'petMedicalRecordsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$petMedicalRecordsHash,
        dependencies: PetMedicalRecordsFamily._dependencies,
        allTransitiveDependencies:
            PetMedicalRecordsFamily._allTransitiveDependencies,
        petId: petId,
      );

  PetMedicalRecordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  FutureOr<List<MedicalRecord>> runNotifierBuild(
    covariant PetMedicalRecords notifier,
  ) {
    return notifier.build(petId);
  }

  @override
  Override overrideWith(PetMedicalRecords Function() create) {
    return ProviderOverride(
      origin: this,
      override: PetMedicalRecordsProvider._internal(
        () => create()..petId = petId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    PetMedicalRecords,
    List<MedicalRecord>
  >
  createElement() {
    return _PetMedicalRecordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PetMedicalRecordsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PetMedicalRecordsRef
    on AutoDisposeAsyncNotifierProviderRef<List<MedicalRecord>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _PetMedicalRecordsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PetMedicalRecords,
          List<MedicalRecord>
        >
    with PetMedicalRecordsRef {
  _PetMedicalRecordsProviderElement(super.provider);

  @override
  String get petId => (origin as PetMedicalRecordsProvider).petId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
