// providers/auth_providers.dart
import 'package:flutter/material.dart';
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
  // Just watch the current session directly
  final session = ref.watch(currentSessionProvider);

  // Return the user if session exists and is not expired
  if (session != null && !session.isExpired) {
    return session.user;
  }

  return null;
}

// Alternative: If you need to watch auth state changes, use this async version
@riverpod
Future<User?> currentUserAsync(CurrentUserAsyncRef ref) async {
  // Watch the auth state stream
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
      // While loading, check current session
      final currentSession = ref.watch(currentSessionProvider);
      return currentSession?.user;
    },
    error: (_, __) => null,
  );
}

// User profile provider
@riverpod
class UserProfileProvider extends _$UserProfileProvider {
  @override
  Future<UserProfile?> build() async {
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
      // Handle error gracefully - user might not have a profile yet
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Add these methods to your UserProfileProvider class:

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
      // Upload image to storage
      final avatarUrl = await _avatarService.uploadAvatar(
        userId: user.id,
        imageFile: imageFile,
        onProgress: onProgress,
      );

      // Update profile with new avatar URL
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
      // Pick image
      final imageFile = await _avatarService.pickImage(source: source);
      if (imageFile == null) return null;

      // Upload image
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
      // Show image source dialog
      final imageFile = await _avatarService.showImageSourceDialog(context);
      if (imageFile == null) return null;

      // Upload image
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
      // Get current profile to find avatar URL
      final currentProfile = await future;
      if (currentProfile?.avatarUrl != null) {
        // Delete from storage
        await _avatarService.deleteAvatar(currentProfile!.avatarUrl!);

        // Update profile to remove avatar URL
        await updateProfile(avatarUrl: null);
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  // Enhanced createProfile method with all new fields
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
          (notificationPreferences ??
                  NotificationPreferences(email: true, sms: true, push: true))
              .toJson(),
      'phone_verified': false,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('profiles').upsert(profileData);
    ref.invalidateSelf();
  }

  // Keep the old simple createProfile for backward compatibility
  Future<void> createSimpleProfile(String fullName, String username) async {
    await createProfile(fullName: fullName, username: username);
  }

  // Enhanced updateProfile method
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
    String? avatarUrl,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('No user logged in');

    final supabase = ref.read(supabaseProvider);

    // Build update data - only include non-null values
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

    await supabase.from('profiles').update(updateData).eq('id', user.id);
    ref.invalidateSelf();
  }

  // Keep the old simple updateProfile for backward compatibility
  Future<void> updateSimpleProfile(String fullName, String username) async {
    await updateProfile(fullName: fullName, username: username);
  }

  // New method: Update just contact info
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

  // New method: Update just address
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

  // New method: Update notification preferences
  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    await updateProfile(notificationPreferences: preferences);
  }

  // New method: Verify phone number (you'd implement SMS verification)
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

  // New method: Check if profile is complete
  Future<bool> isProfileComplete() async {
    final profileAsync = await future;
    final profile = profileAsync;

    if (profile == null) return false;

    return profile.hasCompleteProfile;
  }

  // New method: Get profile completion percentage
  Future<double> getProfileCompletionPercentage() async {
    final profileAsync = await future;
    final profile = profileAsync;

    if (profile == null) return 0.0;

    int completedFields = 0;
    int totalEssentialFields = 6; // fullName, username, phone, address fields

    if (profile.fullName.isNotEmpty) completedFields++;
    if (profile.username.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
      completedFields++;
    }
    if (profile.streetAddress != null && profile.streetAddress!.isNotEmpty) {
      completedFields++;
    }
    if (profile.city != null && profile.city!.isNotEmpty) completedFields++;

    if (profile.country != null && profile.country!.isNotEmpty)
      completedFields++;
    if (profile.state != null && profile.state!.isNotEmpty) completedFields++;

    return completedFields / totalEssentialFields;
  }
}

// Auth service provider
@riverpod
class AuthService extends _$AuthService {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

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

      state = const AsyncValue.data(null);

      // Invalidate relevant providers to refresh state
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

      // Invalidate relevant providers to refresh state
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

      state = const AsyncValue.data(null);

      // Invalidate relevant providers to clear state
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
