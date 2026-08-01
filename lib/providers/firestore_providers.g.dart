// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petRepositoryHash() => r'2691e1c639f0cc2a210b94ab1ee1137f192be145';

/// See also [petRepository].
@ProviderFor(petRepository)
final petRepositoryProvider =
    AutoDisposeProvider<FirestoreRepository<Pet>>.internal(
      petRepository,
      name: r'petRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$petRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetRepositoryRef = AutoDisposeProviderRef<FirestoreRepository<Pet>>;
String _$medicalRecordRepositoryHash() =>
    r'f1686fc762f88b7be6774f5064329c7041a23eb0';

/// See also [medicalRecordRepository].
@ProviderFor(medicalRecordRepository)
final medicalRecordRepositoryProvider =
    AutoDisposeProvider<FirestoreRepository<MedicalRecord>>.internal(
      medicalRecordRepository,
      name: r'medicalRecordRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$medicalRecordRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MedicalRecordRepositoryRef =
    AutoDisposeProviderRef<FirestoreRepository<MedicalRecord>>;
String _$reminderRepositoryHash() =>
    r'ce5d9b3befabc5514ae1982e2c28a4403f119495';

/// See also [reminderRepository].
@ProviderFor(reminderRepository)
final reminderRepositoryProvider =
    AutoDisposeProvider<FirestoreRepository<Reminder>>.internal(
      reminderRepository,
      name: r'reminderRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$reminderRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReminderRepositoryRef =
    AutoDisposeProviderRef<FirestoreRepository<Reminder>>;
String _$activityLogRepositoryHash() =>
    r'38584c5990aa618457b2f418d77f7d33a34f27f5';

/// See also [activityLogRepository].
@ProviderFor(activityLogRepository)
final activityLogRepositoryProvider =
    AutoDisposeProvider<FirestoreRepository<ActivityLog>>.internal(
      activityLogRepository,
      name: r'activityLogRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activityLogRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityLogRepositoryRef =
    AutoDisposeProviderRef<FirestoreRepository<ActivityLog>>;
String _$petsStreamHash() => r'b78026206f5adb8b3af33c5998f6ad80b3ba26f0';

/// See also [petsStream].
@ProviderFor(petsStream)
final petsStreamProvider = AutoDisposeStreamProvider<List<Pet>>.internal(
  petsStream,
  name: r'petsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetsStreamRef = AutoDisposeStreamProviderRef<List<Pet>>;
String _$allRemindersHash() => r'f4bfa8285e4813748274db0e15792221aa674dac';

/// See also [allReminders].
@ProviderFor(allReminders)
final allRemindersProvider = AutoDisposeStreamProvider<List<Reminder>>.internal(
  allReminders,
  name: r'allRemindersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allRemindersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRemindersRef = AutoDisposeStreamProviderRef<List<Reminder>>;
String _$todayRemindersHash() => r'9c4488412fc4423b2bc3ae148b264854f17d96d4';

/// See also [todayReminders].
@ProviderFor(todayReminders)
final todayRemindersProvider =
    AutoDisposeStreamProvider<List<Reminder>>.internal(
      todayReminders,
      name: r'todayRemindersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$todayRemindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRemindersRef = AutoDisposeStreamProviderRef<List<Reminder>>;
String _$weeklyRemindersHash() => r'cd823ce7ac75b7405e9baa8808b26c4073984c5b';

/// See also [weeklyReminders].
@ProviderFor(weeklyReminders)
final weeklyRemindersProvider =
    AutoDisposeStreamProvider<List<Reminder>>.internal(
      weeklyReminders,
      name: r'weeklyRemindersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$weeklyRemindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyRemindersRef = AutoDisposeStreamProviderRef<List<Reminder>>;
String _$monthlyRemindersHash() => r'4ebe8d039b747f348bc664a1d5cfc950d8e902f8';

/// See also [monthlyReminders].
@ProviderFor(monthlyReminders)
final monthlyRemindersProvider =
    AutoDisposeStreamProvider<List<Reminder>>.internal(
      monthlyReminders,
      name: r'monthlyRemindersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$monthlyRemindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyRemindersRef = AutoDisposeStreamProviderRef<List<Reminder>>;
String _$activityLogsForOwnerHash() =>
    r'dd62e13b4443b03b7825969a790fb9abaa6b0a35';

/// See also [activityLogsForOwner].
@ProviderFor(activityLogsForOwner)
final activityLogsForOwnerProvider =
    AutoDisposeStreamProvider<List<ActivityLog>>.internal(
      activityLogsForOwner,
      name: r'activityLogsForOwnerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activityLogsForOwnerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityLogsForOwnerRef =
    AutoDisposeStreamProviderRef<List<ActivityLog>>;
String _$petsControllerHash() => r'cd9f5d00c2831f35fbe81f2e17e8e667024b6167';

/// See also [PetsController].
@ProviderFor(PetsController)
final petsControllerProvider =
    AutoDisposeStreamNotifierProvider<PetsController, List<Pet>>.internal(
      PetsController.new,
      name: r'petsControllerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$petsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PetsController = AutoDisposeStreamNotifier<List<Pet>>;
String _$petMedicalRecordsHash() => r'5846014288b6980d1d36a0e4a32792c8a58ad872';

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
    extends BuildlessAutoDisposeStreamNotifier<List<MedicalRecord>> {
  late final String petId;

  Stream<List<MedicalRecord>> build(String petId);
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
        AutoDisposeStreamNotifierProviderImpl<
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
  Stream<List<MedicalRecord>> runNotifierBuild(
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
  AutoDisposeStreamNotifierProviderElement<
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
    on AutoDisposeStreamNotifierProviderRef<List<MedicalRecord>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _PetMedicalRecordsProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          PetMedicalRecords,
          List<MedicalRecord>
        >
    with PetMedicalRecordsRef {
  _PetMedicalRecordsProviderElement(super.provider);

  @override
  String get petId => (origin as PetMedicalRecordsProvider).petId;
}

String _$remindersControllerHash() =>
    r'deaca0c975c2c2774ec9be45a23a42a8f52b6c3c';

/// See also [RemindersController].
@ProviderFor(RemindersController)
final remindersControllerProvider = AutoDisposeStreamNotifierProvider<
  RemindersController,
  List<Reminder>
>.internal(
  RemindersController.new,
  name: r'remindersControllerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$remindersControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RemindersController = AutoDisposeStreamNotifier<List<Reminder>>;
String _$activityLogsControllerHash() =>
    r'1dc9d4dbd4d098efb97b471529cfa2cf8a96487f';

/// See also [ActivityLogsController].
@ProviderFor(ActivityLogsController)
final activityLogsControllerProvider = AutoDisposeStreamNotifierProvider<
  ActivityLogsController,
  List<ActivityLog>
>.internal(
  ActivityLogsController.new,
  name: r'activityLogsControllerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityLogsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActivityLogsController = AutoDisposeStreamNotifier<List<ActivityLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
