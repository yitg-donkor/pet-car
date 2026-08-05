// providers/app_state_providers.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================
// CONNECTIVITY / OFFLINE MODE PROVIDERS
// ============================================

bool isConnectivityOnline(dynamic value) {
  if (value is List) {
    return value.isNotEmpty && !value.contains(ConnectivityResult.none);
  }

  return value != ConnectivityResult.none;
}

/// True when the device has a network connection.
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  final initialResult = await connectivity.checkConnectivity();
  yield isConnectivityOnline(initialResult);

  yield* connectivity.onConnectivityChanged.map(
    (result) => isConnectivityOnline(result),
  );
});

/// Derived from [connectivityStatusProvider]. Nothing needs to write to this
/// manually anymore - Firestore/Firebase Auth work offline on their own, so
/// this only drives UI (e.g. the offline banner), not functional branching.
final isOfflineModeProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStatusProvider);
  return connectivity.maybeWhen(
    data: (isOnline) => !isOnline,
    orElse: () => false,
  );
});

// ============================================
// ONBOARDING STATUS PROVIDER
// ============================================

/// Check if user has seen onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_onboarding') ?? false;
});

// /// Mark onboarding as seen
final markOnboardingSeenProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    ref.invalidate(hasSeenOnboardingProvider);
  };
});
