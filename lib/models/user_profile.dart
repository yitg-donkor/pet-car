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

class NotificationPreferences {
  final bool email;
  final bool sms;
  final bool push;

  NotificationPreferences({
    required this.email,
    required this.sms,
    required this.push,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      email: json['email'] as bool? ?? true,
      sms: json['sms'] as bool? ?? true,
      push: json['push'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'sms': sms, 'push': push};
  }

  NotificationPreferences copyWith({bool? email, bool? sms, bool? push}) {
    return NotificationPreferences(
      email: email ?? this.email,
      sms: sms ?? this.sms,
      push: push ?? this.push,
    );
  }
}

// ============================================
// EXAMPLE USAGE IN YOUR PROVIDER
// ============================================

/*
// Update your existing UserProfileProvider methods:

Future<void> createProfile({
  required String fullName,
  required String username,
  String? bio,
  String? phoneNumber,
  String? streetAddress,
  String? apartment,
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
    'street_address': streetAddress,
    'apartment': apartment,
    'city': city,
    'state': state,
    'zip_code': zipCode,
    'country': 'US',
    'emergency_contact_name': emergencyContactName,
    'emergency_contact_phone': emergencyContactPhone,
    'notification_preferences': (notificationPreferences ?? 
      NotificationPreferences(email: true, sms: true, push: true)).toJson(),
    'phone_verified': false,
    'is_active': true,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  await supabase.from('profiles').upsert(profileData);
  ref.invalidateSelf();
}

Future<void> updateProfile(UserProfile updatedProfile) async {
  final user = ref.read(currentUserProvider);
  if (user == null) throw Exception('No user logged in');

  final supabase = ref.read(supabaseProvider);
  
  final profileData = updatedProfile.toJson();
  profileData['updated_at'] = DateTime.now().toIso8601String();
  
  await supabase.from('profiles').update(profileData).eq('id', user.id);
  ref.invalidateSelf();
}
*/
