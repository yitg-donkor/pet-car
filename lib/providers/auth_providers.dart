// ============================================
// AUTH PROVIDERS (auth_providers.dart)
// ============================================

import 'package:flutter/material.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/providers/app_state_provider.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_upload_service.dart';
import '../models/user_profile.dart';

part 'auth_providers.g.dart';

// Supabase client provider with offline check
@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  final isOffline = ref.watch(isOfflineModeProvider);
  if (isOffline) {
    throw Exception('Offline mode - Supabase not available');
  }

  try {
    return Supabase.instance.client;
  } catch (e) {
    print('⚠️ Supabase not initialized: $e');
    throw Exception('Supabase not available');
  }
}

// Auth state stream provider with offline handling
@riverpod
Stream<AuthState> authState(AuthStateRef ref) async* {
  final isOffline = ref.watch(isOfflineModeProvider);

  if (isOffline) {
    yield const AuthState(AuthChangeEvent.signedOut, null);
    return;
  }

  try {
    final supabase = ref.watch(supabaseProvider);
    yield* supabase.auth.onAuthStateChange;
  } catch (e) {
    print('⚠️ Auth state error: $e');
    yield const AuthState(AuthChangeEvent.signedOut, null);
  }
}

// Current session provider
@riverpod
Session? currentSession(CurrentSessionRef ref) {
  final isOffline = ref.watch(isOfflineModeProvider);
  if (isOffline) return null;

  try {
    final supabase = ref.watch(supabaseProvider);
    return supabase.auth.currentSession;
  } catch (e) {
    print('⚠️ Current session error: $e');
    return null;
  }
}

// ============================================
// UNIFIED CURRENT USER PROFILE PROVIDER
// ============================================

@riverpod
Future<UserProfile?> currentUserProfile(CurrentUserProfileRef ref) async {
  final isOffline = ref.watch(isOfflineModeProvider);

  if (isOffline) {
    // In offline mode, get from local DB
    final profileLocalDB = ref.watch(profileLocalDBProvider);
    final profiles = await profileLocalDB.getAllProfiles();

    if (profiles.isEmpty) return null;

    // Return the first active profile
    return profiles.firstWhere((p) => p.isActive, orElse: () => profiles.first);
  }

  // Online mode - get from Supabase session
  final session = ref.watch(currentSessionProvider);
  if (session == null) {
    // Fallback to local DB if no session
    final profileLocalDB = ref.watch(profileLocalDBProvider);
    final profiles = await profileLocalDB.getAllProfiles();
    return profiles.isEmpty ? null : profiles.first;
  }

  try {
    final supabase = ref.watch(supabaseProvider);
    final response =
        await supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

    if (response == null) {
      // Fallback to local DB
      final profileLocalDB = ref.watch(profileLocalDBProvider);
      return await profileLocalDB.getProfileById(session.user.id);
    }

    final profile = UserProfile.fromJson(response);

    // Cache in local DB
    final profileLocalDB = ref.watch(profileLocalDBProvider);
    await profileLocalDB.upsertProfile(profile);

    return profile;
  } catch (e) {
    print('Error fetching user profile: $e');

    // Fallback to local DB
    final profileLocalDB = ref.watch(profileLocalDBProvider);
    final session = ref.read(currentSessionProvider);
    if (session != null) {
      return await profileLocalDB.getProfileById(session.user.id);
    }
    return null;
  }
}

// ============================================
// LEGACY CURRENT USER PROVIDER (For backwards compatibility)
// ============================================

@riverpod
User? currentUser(CurrentUserRef ref) {
  final isOffline = ref.watch(isOfflineModeProvider);

  if (isOffline) {
    // Cannot return User synchronously in offline mode
    // Consumers should use currentUserProfile instead
    return null;
  }

  final session = ref.watch(currentSessionProvider);
  if (session != null && !session.isExpired) {
    return session.user;
  }
  return null;
}

// Current user async version
@riverpod
Future<User?> currentUserAsync(CurrentUserAsyncRef ref) async {
  final isOffline = ref.watch(isOfflineModeProvider);
  if (isOffline) return null;

  final authStateAsync = ref.watch(authStateProvider);

  return authStateAsync.when(
    data: (authState) {
      final session = authState.session;
      if (session != null && !session.isExpired) {
        return session.user;
      }
      return null;
    },
    loading: () {
      final currentSession = ref.watch(currentSessionProvider);
      return currentSession?.user;
    },
    error: (_, __) => null,
  );
}

// ============================================
// USER PROFILE PROVIDER (Enhanced)
// ============================================

@riverpod
class UserProfileProvider extends _$UserProfileProvider {
  @override
  FutureOr<UserProfile?> build() async {
    // Delegate to currentUserProfile for consistency
    return ref.watch(currentUserProfileProvider.future);
  }

  Future<UserProfile?> _loadLocalProfile() async {
    try {
      final profileDB = ProfileLocalDB();
      final profiles = await profileDB.getAllProfiles();

      if (profiles.isEmpty) return null;
      return profiles.firstWhere(
        (p) => p.isActive,
        orElse: () => profiles.first,
      );
    } catch (e) {
      print('Error loading local profile: $e');
      return null;
    }
  }

  Future<void> _saveLocalProfile(UserProfile profile) async {
    try {
      final profileDB = ProfileLocalDB();
      await profileDB.upsertProfile(profile);
    } catch (e) {
      print('Error saving local profile: $e');
    }
  }

  AvatarUploadService get _avatarService {
    try {
      final supabase = ref.read(supabaseProvider);
      return AvatarUploadService(supabase);
    } catch (e) {
      throw Exception('Cannot use avatar service in offline mode');
    }
  }

  Future<String> uploadAvatar({
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot upload avatar in offline mode');
    }

    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');

    try {
      final avatarUrl = await _avatarService.uploadAvatar(
        userId: profile.id,
        imageFile: imageFile,
        onProgress: onProgress,
      );

      await updateProfile(avatarUrl: avatarUrl);
      return avatarUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<String?> pickAndUploadAvatar({
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot upload avatar in offline mode');
    }

    try {
      final imageFile = await _avatarService.pickImage(source: source);
      if (imageFile == null) return null;

      return await uploadAvatar(imageFile: imageFile, onProgress: onProgress);
    } catch (e) {
      throw Exception('Failed to pick and upload avatar: $e');
    }
  }

  Future<String?> showAvatarPickerAndUpload(
    BuildContext context, {
    Function(double)? onProgress,
  }) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot upload avatar in offline mode');
    }

    try {
      final imageFile = await _avatarService.showImageSourceDialog(context);
      if (imageFile == null) return null;

      return await uploadAvatar(imageFile: imageFile, onProgress: onProgress);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> deleteAvatar() async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot delete avatar in offline mode');
    }

    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');

    try {
      if (profile.avatarUrl != null) {
        await _avatarService.deleteAvatar(profile.avatarUrl!);
        await updateProfile(avatarUrl: null);
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  Future<void> createProfile({
    required String fullName,
    required String username,
    String? bio,
    String? phoneNumber,
    String? streetAddress,
    String? apartment,
    String? country,
    String? city,
    String? state,
    String? zipCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    NotificationPreferences? notificationPreferences,
    AppSettings? appSettings,
  }) async {
    final profile = await ref.read(currentUserProfileProvider.future);
    final isOffline = ref.read(isOfflineModeProvider);

    final profileData = {
      'id':
          profile?.id ??
          'offline_user_${DateTime.now().millisecondsSinceEpoch}',
      'full_name': fullName,
      'username': username.toLowerCase(),
      'bio': bio,
      'phone_number': phoneNumber,
      'country': country,
      'street_address': streetAddress,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'notification_preferences':
          (notificationPreferences ?? NotificationPreferences()).toJson(),
      'app_settings': (appSettings ?? AppSettings()).toJson(),
      'phone_verified': false,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (!isOffline) {
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').upsert(profileData);
      } catch (e) {
        print('Error creating profile online: $e');
      }
    }

    await _saveLocalProfile(UserProfile.fromJson(profileData));
    ref.invalidateSelf();
    ref.invalidate(currentUserProfileProvider);
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? phoneNumber,
    String? country,
    String? streetAddress,
    String? apartment,
    String? city,
    String? state,
    String? zipCode,
    String? emergencyContactName,
    String? emergencyContactPhone,
    NotificationPreferences? notificationPreferences,
    AppSettings? appSettings,
    String? avatarUrl,
  }) async {
    final isOffline = ref.read(isOfflineModeProvider);
    final profile = await ref.read(currentUserProfileProvider.future);

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updateData['full_name'] = fullName;
    if (username != null) updateData['username'] = username.toLowerCase();
    if (bio != null) updateData['bio'] = bio;
    if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
    if (country != null) updateData['country'] = country;
    if (streetAddress != null) updateData['street_address'] = streetAddress;
    if (apartment != null) updateData['apartment'] = apartment;
    if (city != null) updateData['city'] = city;
    if (state != null) updateData['state'] = state;
    if (zipCode != null) updateData['zip_code'] = zipCode;
    if (emergencyContactName != null)
      updateData['emergency_contact_name'] = emergencyContactName;
    if (emergencyContactPhone != null)
      updateData['emergency_contact_phone'] = emergencyContactPhone;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (notificationPreferences != null) {
      updateData['notification_preferences'] = notificationPreferences.toJson();
    }
    if (appSettings != null) {
      updateData['app_settings'] = appSettings.toJson();
    }

    if (!isOffline && profile != null) {
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').update(updateData).eq('id', profile.id);
      } catch (e) {
        print('Error updating profile online: $e');
      }
    }

    final currentProfile = await _loadLocalProfile();
    if (currentProfile != null) {
      final updatedData = {...currentProfile.toJson(), ...updateData};
      await _saveLocalProfile(UserProfile.fromJson(updatedData));
    }

    ref.invalidateSelf();
    ref.invalidate(currentUserProfileProvider);
  }

  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await updateProfile(notificationPreferences: preferences);
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    await updateProfile(appSettings: settings);
  }

  Future<void> updateContactInfo({
    required String phoneNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    await updateProfile(
      phoneNumber: phoneNumber,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );
  }

  Future<void> updateAddress({
    required String country,
    required String streetAddress,
    String? apartment,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    await updateProfile(
      country: country,
      streetAddress: streetAddress,
      apartment: apartment,
      city: city,
      state: state,
      zipCode: zipCode,
    );
  }

  Future<void> markPhoneAsVerified() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');

    final isOffline = ref.read(isOfflineModeProvider);

    if (!isOffline) {
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase
            .from('profiles')
            .update({
              'phone_verified': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', profile.id);
      } catch (e) {
        print('Error marking phone as verified online: $e');
      }
    }

    final currentProfile = await _loadLocalProfile();
    if (currentProfile != null) {
      final updatedData = {
        ...currentProfile.toJson(),
        'phone_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _saveLocalProfile(UserProfile.fromJson(updatedData));
    }

    ref.invalidateSelf();
    ref.invalidate(currentUserProfileProvider);
  }

  Future<bool> isProfileComplete() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) return false;
    return profile.hasCompleteProfile;
  }

  Future<double> getProfileCompletionPercentage() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) return 0.0;

    int completedFields = 0;
    const int totalEssentialFields = 6;

    if (profile.fullName.isNotEmpty) completedFields++;
    if (profile.username.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
      completedFields++;
    }
    if (profile.streetAddress != null && profile.streetAddress!.isNotEmpty) {
      completedFields++;
    }
    if (profile.city != null && profile.city!.isNotEmpty) completedFields++;
    if (profile.country != null && profile.country!.isNotEmpty) {
      completedFields++;
    }

    return completedFields / totalEssentialFields;
  }
}

// ============================================
// AUTH SERVICE PROVIDER
// ============================================

@riverpod
class AuthService extends _$AuthService {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> clearLocalDataForNewUser() async {
    try {
      print('🗑️ Clearing local database for new user...');

      final db = await LocalDatabaseService.instance.database;
      await db.delete('reminders');
      await db.delete('medical_records');
      await db.delete('activity_logs');
      await db.delete('pets');
      await db.delete('profiles');

      print('✅ Local database cleared successfully');
    } catch (e) {
      print('❌ Error clearing local database: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot sign in while offline');
    }

    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseProvider);

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Login failed - no session returned');
      }

      if (response.user != null) {
        await clearLocalDataForNewUser();

        final syncService = ref.read(unifiedSyncServiceProvider);
        await syncService.fullSync(response.user!.id);
      }

      state = const AsyncValue.data(null);
      ref.invalidate(currentSessionProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(userProfileProviderProvider);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot sign up while offline');
    }

    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseProvider);

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed - no user returned');
      }

      state = const AsyncValue.data(null);

      ref.invalidate(currentSessionProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(userProfileProviderProvider);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final isOffline = ref.read(isOfflineModeProvider);

      if (!isOffline) {
        try {
          final supabase = ref.read(supabaseProvider);
          await supabase.auth.signOut();
        } catch (e) {
          print('Error signing out from Supabase: $e');
        }
      }

      await clearLocalDataForNewUser();

      state = const AsyncValue.data(null);

      ref.invalidate(currentSessionProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(userProfileProviderProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      throw Exception('Cannot reset password while offline');
    }

    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseProvider);

      await supabase.auth.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<bool> isSignedIn() async {
    final isOffline = ref.read(isOfflineModeProvider);
    if (isOffline) {
      final db = await LocalDatabaseService.instance.database;
      final result = await db.query('profiles', limit: 1);
      return result.isNotEmpty;
    }

    final session = ref.read(currentSessionProvider);
    return session != null && !session.isExpired;
  }
}
