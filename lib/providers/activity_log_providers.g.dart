// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$dailyActivityLogsHash() => r'829db107c5c3c6e2029e3127f244800e093320d2';

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
String _$activityLogsOfflineHash() =>
    r'0ff824d2d8fa976a84bd3f31955537438488516c';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
