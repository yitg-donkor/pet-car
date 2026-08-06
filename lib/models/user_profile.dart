// models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_helpers.dart';

class UserProfile {
  final String id; // matches the Firebase Auth UID

  // Basic Information
  final String fullName;
  final String username;
  final String? bio;

  // Contact Information
  final String? phoneNumber;
  final bool phoneVerified;

  // Address Information
  final String? streetAddress;
  final String? apartment;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  // Emergency Contact
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  // Preferences
  final NotificationPreferences notificationPreferences;
  final AppSettings appSettings;

  // Profile
  final String? avatarUrl;

  // Metadata
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phoneVerified,
    required this.notificationPreferences,
    required this.appSettings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.phoneNumber,
    this.streetAddress,
    this.apartment,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.avatarUrl,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      id: id,
      fullName: (data['fullName'] as String?) ?? '',
      username: (data['username'] as String?) ?? '',
      bio: data['bio'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      phoneVerified: data['phoneVerified'] as bool? ?? false,
      streetAddress: data['streetAddress'] as String?,
      apartment: data['apartment'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      zipCode: data['zipCode'] as String?,
      country: data['country'] as String?,
      emergencyContactName: data['emergencyContactName'] as String?,
      emergencyContactPhone: data['emergencyContactPhone'] as String?,
      // Nested maps - Firestore stores these natively, so the existing
      // fromJson/toJson on these two classes needs no changes at all.
      notificationPreferences: NotificationPreferences.fromJson(
        (data['notificationPreferences'] as Map<String, dynamic>?) ?? {},
      ),
      appSettings: AppSettings.fromJson(
        (data['appSettings'] as Map<String, dynamic>?) ?? {},
      ),
      avatarUrl: data['avatarUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: timestampToDateOrNow(data['createdAt']),
      updatedAt: timestampToDateOrNow(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'streetAddress': streetAddress,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'notificationPreferences': notificationPreferences.toJson(),
      'appSettings': appSettings.toJson(),
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': dateToTimestamp(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper getters
  String get fullAddress {
    final parts = <String>[];
    if (streetAddress != null) parts.add(streetAddress!);
    if (apartment != null) parts.add('Apt $apartment');
    if (city != null && state != null) {
      parts.add('$city, $state');
    }
    if (zipCode != null) parts.add(zipCode!);
    return parts.join(', ');
  }

  bool get hasCompleteProfile {
    return phoneNumber != null &&
        phoneVerified &&
        streetAddress != null &&
        city != null &&
        state != null &&
        zipCode != null;
  }

  bool get hasEmergencyContact {
    return emergencyContactName != null && emergencyContactPhone != null;
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? phoneNumber,
    bool? phoneVerified,
    String? streetAddress,
    String? apartment,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? emergencyContactName,
    String? emergencyContactPhone,
    NotificationPreferences? notificationPreferences,
    AppSettings? appSettings,
    String? avatarUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      streetAddress: streetAddress ?? this.streetAddress,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      appSettings: appSettings ?? this.appSettings,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

// ============================================
// NOTIFICATION PREFERENCES MODEL (unchanged - already a plain map)
// ============================================

class NotificationPreferences {
  final bool allNotificationsEnabled;
  final bool reminderNotifications;
  final bool healthAlerts;
  final bool marketingEmails;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationPreferences({
    this.allNotificationsEnabled = true,
    this.reminderNotifications = true,
    this.healthAlerts = true,
    this.marketingEmails = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '21:00',
    this.quietHoursEnd = '08:00',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      allNotificationsEnabled:
          json['all_notifications_enabled'] as bool? ?? true,
      reminderNotifications: json['reminder_notifications'] as bool? ?? true,
      healthAlerts: json['health_alerts'] as bool? ?? true,
      marketingEmails: json['marketing_emails'] as bool? ?? false,
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String? ?? '21:00',
      quietHoursEnd: json['quiet_hours_end'] as String? ?? '08:00',
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all_notifications_enabled': allNotificationsEnabled,
      'reminder_notifications': reminderNotifications,
      'health_alerts': healthAlerts,
      'marketing_emails': marketingEmails,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? allNotificationsEnabled,
    bool? reminderNotifications,
    bool? healthAlerts,
    bool? marketingEmails,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

// ============================================
// APP SETTINGS MODEL (unchanged - already a plain map)
// ============================================

class AppSettings {
  final String theme;
  final String language;
  final String textSize;
  final bool syncOnCellular;
  final bool offlineMode;
  final bool biometricLockEnabled;

  AppSettings({
    this.theme = 'Light',
    this.language = 'English',
    this.textSize = 'Normal',
    this.syncOnCellular = false,
    this.offlineMode = true,
    this.biometricLockEnabled = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] as String? ?? 'Light',
      language: json['language'] as String? ?? 'English',
      textSize: json['text_size'] as String? ?? 'Normal',
      syncOnCellular: json['sync_on_cellular'] as bool? ?? false,
      offlineMode: json['offline_mode'] as bool? ?? true,
      biometricLockEnabled: json['biometric_lock_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'text_size': textSize,
      'sync_on_cellular': syncOnCellular,
      'offline_mode': offlineMode,
      'biometric_lock_enabled': biometricLockEnabled,
    };
  }

  AppSettings copyWith({
    String? theme,
    String? language,
    String? textSize,
    bool? syncOnCellular,
    bool? offlineMode,
    bool? biometricLockEnabled,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      textSize: textSize ?? this.textSize,
      syncOnCellular: syncOnCellular ?? this.syncOnCellular,
      offlineMode: offlineMode ?? this.offlineMode,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
    );
  }
}
