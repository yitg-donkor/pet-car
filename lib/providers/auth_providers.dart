// ============================================
// AUTH PROVIDERS (Firebase Auth + Firestore)
// ============================================
//
// Replaces the Supabase-based auth_providers.dart. Notable simplifications
// versus the old version:
//   - No more isOffline branching that reads/writes a local sqflite copy of
//     the profile as a fallback - Firestore's own offline cache does this,
//     and Firebase Auth persists the signed-in session locally too.
//   - createProfile/createProfileSimple duplication removed - one method.
//   - Avatar upload now goes through Firebase Storage (see
//     services/avatar_upload_service.dart) instead of Supabase Storage.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_profile.dart';
import '../services/avatar_upload_service.dart';
import '../services/firestore_repository.dart';

part 'auth_providers.g.dart';

// ============================================
// CORE FIREBASE PROVIDERS
// ============================================

@riverpod
fb_auth.FirebaseAuth firebaseAuth(FirebaseAuthRef ref) =>
    fb_auth.FirebaseAuth.instance;

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

@riverpod
FirestoreRepository<UserProfile> userProfileRepository(
  UserProfileRepositoryRef ref,
) {
  return FirestoreRepository<UserProfile>(
    collectionPath: 'users',
    fromFirestore: UserProfile.fromFirestore,
    toFirestore: (profile) => profile.toFirestore(),
  );
}

// Auth state stream - fires on sign in / sign out / token refresh.
@riverpod
Stream<fb_auth.User?> authState(AuthStateRef ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

// Convenience sync accessor for the current user, derived from authState.
@riverpod
fb_auth.User? currentUser(CurrentUserRef ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

// ============================================
// CURRENT USER PROFILE (Firestore document)
// ============================================

@riverpod
Future<UserProfile?> currentUserProfile(CurrentUserProfileRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.get(user.uid);
}

@riverpod
class UserProfileController extends _$UserProfileController {
  @override
  FutureOr<UserProfile?> build() {
    return ref.watch(currentUserProfileProvider.future);
  }

  AvatarUploadService get _avatarService => AvatarUploadService();

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
    if (user == null) {
      throw Exception('Cannot create profile: user not authenticated');
    }

    final now = DateTime.now();
    final profile = UserProfile(
      id: user.uid,
      fullName: fullName,
      username: username.toLowerCase(),
      bio: bio,
      phoneNumber: phoneNumber,
      phoneVerified: false,
      streetAddress: streetAddress,
      apartment: apartment,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      notificationPreferences:
          notificationPreferences ?? NotificationPreferences(),
      appSettings: appSettings ?? AppSettings(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(userProfileRepositoryProvider).set(user.uid, profile);

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
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');

    final updated = profile.copyWith(
      fullName: fullName,
      username: username?.toLowerCase(),
      bio: bio,
      phoneNumber: phoneNumber,
      streetAddress: streetAddress,
      apartment: apartment,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      notificationPreferences: notificationPreferences,
      appSettings: appSettings,
      avatarUrl: avatarUrl,
      updatedAt: DateTime.now(),
    );

    await ref.read(userProfileRepositoryProvider).set(profile.id, updated);

    ref.invalidateSelf();
    ref.invalidate(currentUserProfileProvider);
  }

  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) => updateProfile(notificationPreferences: preferences);

  Future<void> updateAppSettings(AppSettings settings) =>
      updateProfile(appSettings: settings);

  Future<String> uploadAvatar({
    required XFile imageFile,
    Function(double)? onProgress,
  }) async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');

    final avatarUrl = await _avatarService.uploadAvatar(
      userId: profile.id,
      imageFile: imageFile,
      onProgress: onProgress,
    );
    await updateProfile(avatarUrl: avatarUrl);
    return avatarUrl;
  }

  Future<String?> pickAndUploadAvatar({
    ImageSource source = ImageSource.gallery,
    Function(double)? onProgress,
  }) async {
    final imageFile = await _avatarService.pickImage(source: source);
    if (imageFile == null) return null;
    return uploadAvatar(imageFile: imageFile, onProgress: onProgress);
  }

  Future<String?> showAvatarPickerAndUpload(
    BuildContext context, {
    Function(double)? onProgress,
  }) async {
    final imageFile = await _avatarService.showImageSourceDialog(context);
    if (imageFile == null) return null;
    return uploadAvatar(imageFile: imageFile, onProgress: onProgress);
  }

  Future<void> deleteAvatar() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (profile == null) throw Exception('No user logged in');
    if (profile.avatarUrl == null) return;

    await _avatarService.deleteAvatar(profile.avatarUrl!);
    await updateProfile(avatarUrl: null);
  }
}

// ============================================
// AUTH ACTIONS (sign in / sign up / sign out)
// ============================================

@riverpod
class AuthService extends _$AuthService {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<fb_auth.UserCredential> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);

      state = const AsyncValue.data(null);
      ref.invalidate(currentUserProfileProvider);
      return credential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Signs up and creates the Firestore profile in one step. [fullName] and
  /// [username] are required up front so callers don't end up with an auth
  /// account that has no matching `users/{uid}` document.
  Future<fb_auth.UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) throw Exception('Sign up failed - no user returned');

      final now = DateTime.now();
      final profile = UserProfile(
        id: user.uid,
        fullName: fullName,
        username: username.toLowerCase(),
        phoneVerified: false,
        notificationPreferences: NotificationPreferences(),
        appSettings: AppSettings(),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(userProfileRepositoryProvider).set(user.uid, profile);

      state = const AsyncValue.data(null);
      ref.invalidate(currentUserProfileProvider);
      return credential;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).signOut();
      state = const AsyncValue.data(null);
      ref.invalidate(currentUserProfileProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(
        email: email,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  bool get isSignedIn => ref.read(firebaseAuthProvider).currentUser != null;
}
