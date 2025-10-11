// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localDatabaseHash() => r'bffbff587b52ac4587a834ae9c95a6d08bfb4ce4';

/// See also [localDatabase].
@ProviderFor(localDatabase)
final localDatabaseProvider =
    AutoDisposeProvider<LocalDatabaseService>.internal(
      localDatabase,
      name: r'localDatabaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$localDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalDatabaseRef = AutoDisposeProviderRef<LocalDatabaseService>;
String _$petLocalDBHash() => r'6400aa77eeb56e54731f479ec9d20340cb22757c';

/// See also [petLocalDB].
@ProviderFor(petLocalDB)
final petLocalDBProvider = AutoDisposeProvider<PetLocalDB>.internal(
  petLocalDB,
  name: r'petLocalDBProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petLocalDBHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetLocalDBRef = AutoDisposeProviderRef<PetLocalDB>;
String _$medicalRecordLocalDBHash() =>
    r'7a61aecdb8e211f0f3ed49feb32af5f6031153db';

/// See also [medicalRecordLocalDB].
@ProviderFor(medicalRecordLocalDB)
final medicalRecordLocalDBProvider =
    AutoDisposeProvider<MedicalRecordLocalDB>.internal(
      medicalRecordLocalDB,
      name: r'medicalRecordLocalDBProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$medicalRecordLocalDBHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MedicalRecordLocalDBRef = AutoDisposeProviderRef<MedicalRecordLocalDB>;
String _$reminderDatabaseHash() => r'd08208add688acd32a7a49330fcc2d5a998dfbc6';

/// See also [reminderDatabase].
@ProviderFor(reminderDatabase)
final reminderDatabaseProvider =
    AutoDisposeProvider<ReminderDatabaseService>.internal(
      reminderDatabase,
      name: r'reminderDatabaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$reminderDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReminderDatabaseRef = AutoDisposeProviderRef<ReminderDatabaseService>;
String _$activityLogLocalDBHash() =>
    r'3620ba922c9c818bfd487bb1c7ec477ab2c8d321';

/// See also [activityLogLocalDB].
@ProviderFor(activityLogLocalDB)
final activityLogLocalDBProvider =
    AutoDisposeProvider<ActivityLogLocalDB>.internal(
      activityLogLocalDB,
      name: r'activityLogLocalDBProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activityLogLocalDBHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityLogLocalDBRef = AutoDisposeProviderRef<ActivityLogLocalDB>;
String _$profileLocalDBHash() => r'693d3bb2bcc5c9a03ab254bc39dc2bb9782a337e';

/// See also [profileLocalDB].
@ProviderFor(profileLocalDB)
final profileLocalDBProvider = AutoDisposeProvider<ProfileLocalDB>.internal(
  profileLocalDB,
  name: r'profileLocalDBProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileLocalDBHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileLocalDBRef = AutoDisposeProviderRef<ProfileLocalDB>;
String _$unifiedSyncServiceHash() =>
    r'6ba690bd1af526908c4c37223ceff07aacf59734';

/// See also [unifiedSyncService].
@ProviderFor(unifiedSyncService)
final unifiedSyncServiceProvider =
    AutoDisposeProvider<UnifiedSyncService>.internal(
      unifiedSyncService,
      name: r'unifiedSyncServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$unifiedSyncServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnifiedSyncServiceRef = AutoDisposeProviderRef<UnifiedSyncService>;
String _$allRemindersRefreshHash() =>
    r'3f0ecee30216c4428e5385d43e496f2587827d52';

/// See also [allRemindersRefresh].
@ProviderFor(allRemindersRefresh)
final allRemindersRefreshProvider =
    AutoDisposeFutureProvider<List<Reminder>>.internal(
      allRemindersRefresh,
      name: r'allRemindersRefreshProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$allRemindersRefreshHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRemindersRefreshRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$todayRemindersHash() => r'a54a51af54527dfa70a2ea4d2e97bc0bdbedcdcc';

/// See also [todayReminders].
@ProviderFor(todayReminders)
final todayRemindersProvider =
    AutoDisposeFutureProvider<List<Reminder>>.internal(
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
typedef TodayRemindersRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$weeklyRemindersHash() => r'9830d4dfd69d63aa4a576f912eedbc377d7b1eeb';

/// See also [weeklyReminders].
@ProviderFor(weeklyReminders)
final weeklyRemindersProvider =
    AutoDisposeFutureProvider<List<Reminder>>.internal(
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
typedef WeeklyRemindersRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$monthlyRemindersHash() => r'aadce614feb1c8f3b603515ed493bb511cd81298';

/// See also [monthlyReminders].
@ProviderFor(monthlyReminders)
final monthlyRemindersProvider =
    AutoDisposeFutureProvider<List<Reminder>>.internal(
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
typedef MonthlyRemindersRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$allRemindersHash() => r'a2de527924e94ffb17cc73532d6629678acf0370';

/// See also [allReminders].
@ProviderFor(allReminders)
final allRemindersProvider = AutoDisposeFutureProvider<List<Reminder>>.internal(
  allReminders,
  name: r'allRemindersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allRemindersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRemindersRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$connectivityStatusHash() =>
    r'e757f3286b7fa85493de283453ec8e5f498253ea';

/// See also [connectivityStatus].
@ProviderFor(connectivityStatus)
final connectivityStatusProvider = AutoDisposeStreamProvider<bool>.internal(
  connectivityStatus,
  name: r'connectivityStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectivityStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStatusRef = AutoDisposeStreamProviderRef<bool>;
String _$periodicSyncManagerHash() =>
    r'7d7dbad827902f7b04310f21ee487c5837fafe9f';

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

/// See also [periodicSyncManager].
@ProviderFor(periodicSyncManager)
const periodicSyncManagerProvider = PeriodicSyncManagerFamily();

/// See also [periodicSyncManager].
class PeriodicSyncManagerFamily extends Family<PeriodicSyncManager> {
  /// See also [periodicSyncManager].
  const PeriodicSyncManagerFamily();

  /// See also [periodicSyncManager].
  PeriodicSyncManagerProvider call(String userId) {
    return PeriodicSyncManagerProvider(userId);
  }

  @override
  PeriodicSyncManagerProvider getProviderOverride(
    covariant PeriodicSyncManagerProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'periodicSyncManagerProvider';
}

/// See also [periodicSyncManager].
class PeriodicSyncManagerProvider
    extends AutoDisposeProvider<PeriodicSyncManager> {
  /// See also [periodicSyncManager].
  PeriodicSyncManagerProvider(String userId)
    : this._internal(
        (ref) => periodicSyncManager(ref as PeriodicSyncManagerRef, userId),
        from: periodicSyncManagerProvider,
        name: r'periodicSyncManagerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$periodicSyncManagerHash,
        dependencies: PeriodicSyncManagerFamily._dependencies,
        allTransitiveDependencies:
            PeriodicSyncManagerFamily._allTransitiveDependencies,
        userId: userId,
      );

  PeriodicSyncManagerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    PeriodicSyncManager Function(PeriodicSyncManagerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeriodicSyncManagerProvider._internal(
        (ref) => create(ref as PeriodicSyncManagerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<PeriodicSyncManager> createElement() {
    return _PeriodicSyncManagerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodicSyncManagerProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeriodicSyncManagerRef on AutoDisposeProviderRef<PeriodicSyncManager> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PeriodicSyncManagerProviderElement
    extends AutoDisposeProviderElement<PeriodicSyncManager>
    with PeriodicSyncManagerRef {
  _PeriodicSyncManagerProviderElement(super.provider);

  @override
  String get userId => (origin as PeriodicSyncManagerProvider).userId;
}

String _$petMedicalRecordsOfflineHash() =>
    r'1009452753671f6c623c87bdfe6ef043951f92f7';

abstract class _$PetMedicalRecordsOffline
    extends BuildlessAutoDisposeAsyncNotifier<List<MedicalRecord>> {
  late final String petId;

  FutureOr<List<MedicalRecord>> build(String petId);
}

/// See also [PetMedicalRecordsOffline].
@ProviderFor(PetMedicalRecordsOffline)
const petMedicalRecordsOfflineProvider = PetMedicalRecordsOfflineFamily();

/// See also [PetMedicalRecordsOffline].
class PetMedicalRecordsOfflineFamily
    extends Family<AsyncValue<List<MedicalRecord>>> {
  /// See also [PetMedicalRecordsOffline].
  const PetMedicalRecordsOfflineFamily();

  /// See also [PetMedicalRecordsOffline].
  PetMedicalRecordsOfflineProvider call(String petId) {
    return PetMedicalRecordsOfflineProvider(petId);
  }

  @override
  PetMedicalRecordsOfflineProvider getProviderOverride(
    covariant PetMedicalRecordsOfflineProvider provider,
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
  String? get name => r'petMedicalRecordsOfflineProvider';
}

/// See also [PetMedicalRecordsOffline].
class PetMedicalRecordsOfflineProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PetMedicalRecordsOffline,
          List<MedicalRecord>
        > {
  /// See also [PetMedicalRecordsOffline].
  PetMedicalRecordsOfflineProvider(String petId)
    : this._internal(
        () => PetMedicalRecordsOffline()..petId = petId,
        from: petMedicalRecordsOfflineProvider,
        name: r'petMedicalRecordsOfflineProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$petMedicalRecordsOfflineHash,
        dependencies: PetMedicalRecordsOfflineFamily._dependencies,
        allTransitiveDependencies:
            PetMedicalRecordsOfflineFamily._allTransitiveDependencies,
        petId: petId,
      );

  PetMedicalRecordsOfflineProvider._internal(
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
    covariant PetMedicalRecordsOffline notifier,
  ) {
    return notifier.build(petId);
  }

  @override
  Override overrideWith(PetMedicalRecordsOffline Function() create) {
    return ProviderOverride(
      origin: this,
      override: PetMedicalRecordsOfflineProvider._internal(
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
    PetMedicalRecordsOffline,
    List<MedicalRecord>
  >
  createElement() {
    return _PetMedicalRecordsOfflineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PetMedicalRecordsOfflineProvider && other.petId == petId;
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
mixin PetMedicalRecordsOfflineRef
    on AutoDisposeAsyncNotifierProviderRef<List<MedicalRecord>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _PetMedicalRecordsOfflineProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PetMedicalRecordsOffline,
          List<MedicalRecord>
        >
    with PetMedicalRecordsOfflineRef {
  _PetMedicalRecordsOfflineProviderElement(super.provider);

  @override
  String get petId => (origin as PetMedicalRecordsOfflineProvider).petId;
}

String _$syncStatusHash() => r'ee28491b4940f9ce39c12a8d43ff797a8742c9cc';

/// See also [SyncStatus].
@ProviderFor(SyncStatus)
final syncStatusProvider =
    AutoDisposeAsyncNotifierProvider<SyncStatus, Map<String, int>>.internal(
      SyncStatus.new,
      name: r'syncStatusProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$syncStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncStatus = AutoDisposeAsyncNotifier<Map<String, int>>;
String _$manualSyncHash() => r'0145f5ac6bda8ce05e561f030a74602d54525994';

/// See also [ManualSync].
@ProviderFor(ManualSync)
final manualSyncProvider =
    AutoDisposeNotifierProvider<ManualSync, bool>.internal(
      ManualSync.new,
      name: r'manualSyncProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$manualSyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualSync = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
