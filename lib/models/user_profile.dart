// models/user_profile.dart
class UserProfile {
  final String id;

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

  // Convert from JSON (from Supabase)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      phoneNumber: json['phone_number'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      streetAddress: json['street_address'] as String?,
      apartment: json['apartment'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      notificationPreferences: NotificationPreferences.fromJson(
        json['notification_preferences'] as Map<String, dynamic>? ?? {},
      ),
      appSettings: AppSettings.fromJson(
        json['app_settings'] as Map<String, dynamic>? ?? {},
      ),
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'bio': bio,
      'phone_number': phoneNumber,
      'phone_verified': phoneVerified,
      'street_address': streetAddress,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'notification_preferences': notificationPreferences.toJson(),
      'app_settings': appSettings.toJson(),
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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

  // CopyWith method for updates
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
// NOTIFICATION PREFERENCES MODEL
// ============================================

// Add this to your NotificationPreferences model in user_profile.dart
class NotificationPreferences {
  final bool allNotificationsEnabled;
  final bool reminderNotifications;
  final bool healthAlerts;
  final bool marketingEmails;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool soundEnabled; // NEW
  final bool vibrationEnabled; // NEW

  NotificationPreferences({
    this.allNotificationsEnabled = true,
    this.reminderNotifications = true,
    this.healthAlerts = true,
    this.marketingEmails = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '21:00',
    this.quietHoursEnd = '08:00',
    this.soundEnabled = true, // NEW
    this.vibrationEnabled = true, // NEW
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
      soundEnabled: json['sound_enabled'] as bool? ?? true, // NEW
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true, // NEW
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
      'sound_enabled': soundEnabled, // NEW
      'vibration_enabled': vibrationEnabled, // NEW
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
    bool? soundEnabled, // NEW
    bool? vibrationEnabled, // NEW
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
      soundEnabled: soundEnabled ?? this.soundEnabled, // NEW
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled, // NEW
    );
  }
}

// ============================================
// APP SETTINGS MODEL
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
