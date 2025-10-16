// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseHash() => r'338c6d1df36ede7b2a16c7ca6fbf7c187cb36510';

/// See also [supabase].
@ProviderFor(supabase)
final supabaseProvider = AutoDisposeProvider<SupabaseClient>.internal(
  supabase,
  name: r'supabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$supabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseRef = AutoDisposeProviderRef<SupabaseClient>;
String _$authStateHash() => r'96ace570059e60aafed95fc856482e23fdf0a845';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<AuthState>;
String _$currentSessionHash() => r'b7380f963c5c47c12d2708d534fea38568495a41';

/// See also [currentSession].
@ProviderFor(currentSession)
final currentSessionProvider = AutoDisposeProvider<Session?>.internal(
  currentSession,
  name: r'currentSessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSessionRef = AutoDisposeProviderRef<Session?>;
String _$currentUserProfileHash() =>
    r'4ad1a99a91347050e1364aaee1eeec6f9862c54c';

/// See also [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeFutureProvider<UserProfile?>.internal(
      currentUserProfile,
      name: r'currentUserProfileProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$currentUserProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeFutureProviderRef<UserProfile?>;
String _$currentUserHash() => r'd9fd088c7b682f0ef6552ae684ab448079f97bf0';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$currentUserAsyncHash() => r'0c3146863c936f68538b8dff8ae6de866e156cce';

/// See also [currentUserAsync].
@ProviderFor(currentUserAsync)
final currentUserAsyncProvider = AutoDisposeFutureProvider<User?>.internal(
  currentUserAsync,
  name: r'currentUserAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentUserAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserAsyncRef = AutoDisposeFutureProviderRef<User?>;
String _$userProfileProviderHash() =>
    r'cd8cb7fe0e1538f857fdcd02f5d3b00b3880046b';

/// See also [UserProfileProvider].
@ProviderFor(UserProfileProvider)
final userProfileProviderProvider = AutoDisposeAsyncNotifierProvider<
  UserProfileProvider,
  UserProfile?
>.internal(
  UserProfileProvider.new,
  name: r'userProfileProviderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserProfileProvider = AutoDisposeAsyncNotifier<UserProfile?>;
String _$authServiceHash() => r'51bf4a2155bcb6c6b3766fadcc2f619dd5d31d52';

/// See also [AuthService].
@ProviderFor(AuthService)
final authServiceProvider =
    AutoDisposeNotifierProvider<AuthService, AsyncValue<void>>.internal(
      AuthService.new,
      name: r'authServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthService = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
