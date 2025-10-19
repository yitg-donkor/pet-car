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
    r'8a83264bee41f3f00fb77e94bf5ae9593c6fe373';

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
String _$dailyActivityLogsHash() => r'022d150379ccd4b989364075bdab0388ccab9588';

/// See also [dailyActivityLogs].
@ProviderFor(dailyActivityLogs)
final dailyActivityLogsProvider =
    AutoDisposeFutureProvider<Map<String, List<ActivityLog>>>.internal(
      dailyActivityLogs,
      name: r'dailyActivityLogsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$dailyActivityLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyActivityLogsRef =
    AutoDisposeFutureProviderRef<Map<String, List<ActivityLog>>>;
String _$healthActivityLogsHash() =>
    r'988f6dcaa548db0c193b25d2641446de780ce9fb';

/// See also [healthActivityLogs].
@ProviderFor(healthActivityLogs)
final healthActivityLogsProvider =
    AutoDisposeFutureProvider<List<ActivityLog>>.internal(
      healthActivityLogs,
      name: r'healthActivityLogsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$healthActivityLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HealthActivityLogsRef = AutoDisposeFutureProviderRef<List<ActivityLog>>;
String _$petActivityLogsHash() => r'e433b2854ea8f91f3253813a0689060ea211e3ce';

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

/// See also [petActivityLogs].
@ProviderFor(petActivityLogs)
const petActivityLogsProvider = PetActivityLogsFamily();

/// See also [petActivityLogs].
class PetActivityLogsFamily extends Family<AsyncValue<List<ActivityLog>>> {
  /// See also [petActivityLogs].
  const PetActivityLogsFamily();

  /// See also [petActivityLogs].
  PetActivityLogsProvider call(String petId) {
    return PetActivityLogsProvider(petId);
  }

  @override
  PetActivityLogsProvider getProviderOverride(
    covariant PetActivityLogsProvider provider,
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
  String? get name => r'petActivityLogsProvider';
}

/// See also [petActivityLogs].
class PetActivityLogsProvider
    extends AutoDisposeFutureProvider<List<ActivityLog>> {
  /// See also [petActivityLogs].
  PetActivityLogsProvider(String petId)
    : this._internal(
        (ref) => petActivityLogs(ref as PetActivityLogsRef, petId),
        from: petActivityLogsProvider,
        name: r'petActivityLogsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$petActivityLogsHash,
        dependencies: PetActivityLogsFamily._dependencies,
        allTransitiveDependencies:
            PetActivityLogsFamily._allTransitiveDependencies,
        petId: petId,
      );

  PetActivityLogsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<ActivityLog>> Function(PetActivityLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PetActivityLogsProvider._internal(
        (ref) => create(ref as PetActivityLogsRef),
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
  AutoDisposeFutureProviderElement<List<ActivityLog>> createElement() {
    return _PetActivityLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PetActivityLogsProvider && other.petId == petId;
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
mixin PetActivityLogsRef on AutoDisposeFutureProviderRef<List<ActivityLog>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _PetActivityLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<ActivityLog>>
    with PetActivityLogsRef {
  _PetActivityLogsProviderElement(super.provider);

  @override
  String get petId => (origin as PetActivityLogsProvider).petId;
}

String _$activityLogsByDateRangeHash() =>
    r'37ade153e577484a1928e5e327b2ee243da055ae';

/// See also [activityLogsByDateRange].
@ProviderFor(activityLogsByDateRange)
const activityLogsByDateRangeProvider = ActivityLogsByDateRangeFamily();

/// See also [activityLogsByDateRange].
class ActivityLogsByDateRangeFamily
    extends Family<AsyncValue<List<ActivityLog>>> {
  /// See also [activityLogsByDateRange].
  const ActivityLogsByDateRangeFamily();

  /// See also [activityLogsByDateRange].
  ActivityLogsByDateRangeProvider call(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return ActivityLogsByDateRangeProvider(petId, startDate, endDate);
  }

  @override
  ActivityLogsByDateRangeProvider getProviderOverride(
    covariant ActivityLogsByDateRangeProvider provider,
  ) {
    return call(provider.petId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityLogsByDateRangeProvider';
}

/// See also [activityLogsByDateRange].
class ActivityLogsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<ActivityLog>> {
  /// See also [activityLogsByDateRange].
  ActivityLogsByDateRangeProvider(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
        (ref) => activityLogsByDateRange(
          ref as ActivityLogsByDateRangeRef,
          petId,
          startDate,
          endDate,
        ),
        from: activityLogsByDateRangeProvider,
        name: r'activityLogsByDateRangeProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$activityLogsByDateRangeHash,
        dependencies: ActivityLogsByDateRangeFamily._dependencies,
        allTransitiveDependencies:
            ActivityLogsByDateRangeFamily._allTransitiveDependencies,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

  ActivityLogsByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String petId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<ActivityLog>> Function(ActivityLogsByDateRangeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityLogsByDateRangeProvider._internal(
        (ref) => create(ref as ActivityLogsByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ActivityLog>> createElement() {
    return _ActivityLogsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityLogsByDateRangeProvider &&
        other.petId == petId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityLogsByDateRangeRef
    on AutoDisposeFutureProviderRef<List<ActivityLog>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _ActivityLogsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<ActivityLog>>
    with ActivityLogsByDateRangeRef {
  _ActivityLogsByDateRangeProviderElement(super.provider);

  @override
  String get petId => (origin as ActivityLogsByDateRangeProvider).petId;
  @override
  DateTime get startDate =>
      (origin as ActivityLogsByDateRangeProvider).startDate;
  @override
  DateTime get endDate => (origin as ActivityLogsByDateRangeProvider).endDate;
}

String _$activityLogStatsHash() => r'ed9fe47c429245d8287029089e02552672baa6df';

/// See also [activityLogStats].
@ProviderFor(activityLogStats)
final activityLogStatsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
      activityLogStats,
      name: r'activityLogStatsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activityLogStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityLogStatsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
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

String _$petsOfflineHash() => r'0bec39850bcca0530d24d568c30f7704dc534429';

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

String _$activityLogsOfflineHash() =>
    r'f474b326cb137c2c3a789405ca3e8f7795b816ba';

/// See also [ActivityLogsOffline].
@ProviderFor(ActivityLogsOffline)
final activityLogsOfflineProvider = AutoDisposeAsyncNotifierProvider<
  ActivityLogsOffline,
  List<ActivityLog>
>.internal(
  ActivityLogsOffline.new,
  name: r'activityLogsOfflineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityLogsOfflineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActivityLogsOffline = AutoDisposeAsyncNotifier<List<ActivityLog>>;
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
String _$manualSyncHash() => r'f6275560a0214a2c9abd7a0d3dec2fd06e5f5227';

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
