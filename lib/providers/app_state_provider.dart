// providers/app_state_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/widgets/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================
// OFFLINE MODE PROVIDER
// ============================================

/// Global offline mode state
/// This is separate from auth_providers to avoid circular dependencies
final isOfflineModeProvider = StateProvider<bool>((ref) => false);

// ============================================
// ONBOARDING STATUS PROVIDER
// ============================================

/// Check if user has seen onboarding
// final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getBool('has_seen_onboarding') ?? false;
// });

// /// Mark onboarding as seen
final markOnboardingSeenProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    ref.invalidate(hasSeenOnboardingProvider);
  };
});
