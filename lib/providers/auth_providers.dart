// providers/auth_providers.dart
import 'package:flutter/material.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_upload_service.dart';
import '../models/user_profile.dart';

part 'auth_providers.g.dart';

// Supabase client provider
@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

// Auth state stream provider
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
}

// Current session provider - can be null for logged out users
@riverpod
Session? currentSession(CurrentSessionRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentSession;
}

// Fixed current user provider - simplified and safer
@riverpod
User? currentUser(CurrentUserRef ref) {
  final session = ref.watch(currentSessionProvider);
  if (session != null && !session.isExpired) {
    return session.user;
  }
  return null;
}

// Alternative: If you need to watch auth state changes, use this async version
@riverpod
Future<User?> currentUserAsync(CurrentUserAsyncRef ref) async {
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

// User profile provider - NOW RETURNS UserProfile? NOT Future<UserProfile?>
@riverpod
class UserProfileProvider extends _$UserProfileProvider {
  @override
  FutureOr<UserProfile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    final supabase = ref.watch(supabaseProvider);

    try {
      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Avatar upload service instance
  AvatarUploadService get _avatarService =>
      AvatarUploadService(ref.read(supabaseProvider));

  /// Upload avatar and update profile
  Future<String> uploadAvatar({
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    try {
      final avatarUrl = await _avatarService.uploadAvatar(
        userId: user.id,
        imageFile: imageFile,
        onProgress: onProgress,
      );

      await updateProfile(avatarUrl: avatarUrl);
      return avatarUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Pick and upload avatar image
  Future<String?> pickAndUploadAvatar({
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    try {
      final imageFile = await _avatarService.pickImage(source: source);
      if (imageFile == null) return null;

      return await uploadAvatar(imageFile: imageFile, onProgress: onProgress);
    } catch (e) {
      throw Exception('Failed to pick and upload avatar: $e');
    }
  }

  /// Show image picker dialog and upload
  Future<String?> showAvatarPickerAndUpload(
    BuildContext context, {
    Function(double)? onProgress,
  }) async {
    try {
      final imageFile = await _avatarService.showImageSourceDialog(context);
      if (imageFile == null) return null;

      return await uploadAvatar(imageFile: imageFile, onProgress: onProgress);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Delete current avatar
  Future<void> deleteAvatar() async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    try {
      final currentProfile = await future;
      if (currentProfile?.avatarUrl != null) {
        await _avatarService.deleteAvatar(currentProfile!.avatarUrl!);
        await updateProfile(avatarUrl: null);
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  /// Enhanced createProfile method with all new fields
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
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    final supabase = ref.read(supabaseProvider);

    final profileData = {
      'id': user.id,
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

    await supabase.from('profiles').upsert(profileData);
    ref.invalidateSelf();
  }

  /// Enhanced updateProfile method - now includes AppSettings
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
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    final supabase = ref.read(supabaseProvider);

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

    await supabase.from('profiles').update(updateData).eq('id', user.id);
    ref.invalidateSelf();
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await updateProfile(notificationPreferences: preferences);
  }

  /// Update app settings (theme, language, etc.)
  Future<void> updateAppSettings(AppSettings settings) async {
    await updateProfile(appSettings: settings);
  }

  /// Update just contact info
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

  /// Update just address
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

  /// Mark phone as verified
  Future<void> markPhoneAsVerified() async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    final supabase = ref.read(supabaseProvider);

    await supabase
        .from('profiles')
        .update({
          'phone_verified': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);

    ref.invalidateSelf();
  }

  /// Check if profile is complete
  Future<bool> isProfileComplete() async {
    final profileAsync = await future;
    final profile = profileAsync;

    if (profile == null) return false;
    return profile.hasCompleteProfile;
  }

  /// Get profile completion percentage
  Future<double> getProfileCompletionPercentage() async {
    final profileAsync = await future;
    final profile = profileAsync;

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

// Auth service provider
@riverpod
class AuthService extends _$AuthService {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> clearLocalDataForNewUser() async {
    try {
      print('🗑️ Clearing local database for new user...');

      final db = await LocalDatabaseService.instance.database;

      // Clear all user-specific data tables
      await db.delete('reminders');
      await db.delete('medical_records');
      await db.delete('activity_logs');
      await db.delete('pets');

      print('✅ Local database cleared successfully');
    } catch (e) {
      print('❌ Error clearing local database: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
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
        // Clear local data for new user
        await clearLocalDataForNewUser();

        // Sync new user's data
        final syncService = ref.read(unifiedSyncServiceProvider);
        await syncService.fullSync(response.user!.id);
      }

      // Update state and invalidate related providers
      state = const AsyncValue.data(null);
      ref.invalidate(currentSessionProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(userProfileProviderProvider);

      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
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
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signOut();
      await clearLocalDataForNewUser();

      state = const AsyncValue.data(null);

      ref.invalidate(currentSessionProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(userProfileProviderProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
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
    final session = ref.read(currentSessionProvider);
    return session != null && !session.isExpired;
  }
}
