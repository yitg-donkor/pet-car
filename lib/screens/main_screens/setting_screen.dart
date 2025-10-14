import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/screens/settingsscreens/profile_edit_screen.dart';
import 'package:pet_care/services/notification_service.dart';
import 'package:pet_care/theme/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_care/models/user_profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _reminderNotifications = true;
  bool _healthAlerts = true;
  bool _marketingEmails = false;
  bool _syncOnCellular = false;
  bool _offlineMode = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  UserProfile? _currentProfile;
  bool _initialized = false;
  bool _isOffline = false;
  bool _notificationSound = true;
  bool _notificationVibration = true;
  Timer? _saveDebounceTimer;

  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  void _initializeSettingsFromProfile(UserProfile? userProfile) {
    if (userProfile != null && !_initialized) {
      _currentProfile = userProfile;
      _notificationsEnabled =
          userProfile.notificationPreferences.allNotificationsEnabled;
      _reminderNotifications =
          userProfile.notificationPreferences.reminderNotifications;
      _healthAlerts = userProfile.notificationPreferences.healthAlerts;
      _marketingEmails = userProfile.notificationPreferences.marketingEmails;
      _syncOnCellular = userProfile.appSettings.syncOnCellular;
      _offlineMode = userProfile.appSettings.offlineMode;
      _selectedLanguage = userProfile.appSettings.language;
      _selectedTheme = userProfile.appSettings.theme;
      _notificationSound = userProfile.notificationPreferences.soundEnabled;
      _notificationVibration =
          userProfile.notificationPreferences.vibrationEnabled;
      _initialized = true;

      print(
        '✅ Initialized settings from profile: sound=$_notificationSound, vibration=$_notificationVibration',
      );
    } else if (userProfile != null && _initialized && _currentProfile == null) {
      _currentProfile = userProfile;
    }
  }

  Future<UserProfile?> _loadProfileFromOfflineDB(String userId) async {
    try {
      final profileLocalDB = ref.read(profileLocalDBProvider);
      final profile = await profileLocalDB.getProfileById(userId);
      return profile;
    } catch (e) {
      print('Error loading profile from offline DB: $e');
      return null;
    }
  }

  Future<void> _handleLogout(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider.notifier);
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _debouncedSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _saveSettingsToProfile();
    });
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveSettingsToProfile() async {
    if (_currentProfile == null) {
      debugPrint('❌ Cannot save: _currentProfile is null');
      return;
    }

    debugPrint('💾 Saving settings:');
    debugPrint('   Sound: $_notificationSound');
    debugPrint('   Vibration: $_notificationVibration');
    debugPrint('   All notifications: $_notificationsEnabled');

    try {
      // Create updated profile
      final updatedProfile = _currentProfile!.copyWith(
        notificationPreferences: _currentProfile!.notificationPreferences
            .copyWith(
              allNotificationsEnabled: _notificationsEnabled,
              reminderNotifications: _reminderNotifications,
              healthAlerts: _healthAlerts,
              marketingEmails: _marketingEmails,
              soundEnabled: _notificationSound,
              vibrationEnabled: _notificationVibration,
            ),
        appSettings: _currentProfile!.appSettings.copyWith(
          syncOnCellular: _syncOnCellular,
          offlineMode: _offlineMode,
          language: _selectedLanguage,
          theme: _selectedTheme,
        ),
      );

      debugPrint('📦 Updated profile notification preferences:');
      debugPrint(
        '   Sound: ${updatedProfile.notificationPreferences.soundEnabled}',
      );
      debugPrint(
        '   Vibration: ${updatedProfile.notificationPreferences.vibrationEnabled}',
      );

      // Update notification service immediately (synchronous)
      _notificationService.setPreferences(
        updatedProfile.notificationPreferences,
      );

      // Save to local DB in the background
      unawaited(
        Future(() async {
          try {
            final profileLocalDB = ref.read(profileLocalDBProvider);
            await profileLocalDB.upsertProfile(updatedProfile);
            debugPrint('✅ Saved to local DB');
          } catch (e) {
            debugPrint('❌ Error saving to local DB: $e');
          }
        }),
      );

      // Handle remote sync in the background if online
      if (!_isOffline) {
        unawaited(
          Future(() async {
            try {
              await ref
                  .read(userProfileProviderProvider.notifier)
                  .updateNotificationPreferences(
                    updatedProfile.notificationPreferences,
                  );
              await ref
                  .read(userProfileProviderProvider.notifier)
                  .updateAppSettings(updatedProfile.appSettings);
              debugPrint('✅ Synced to remote');
            } catch (e) {
              debugPrint('⚠️ Remote sync failed: $e');
            }
          }),
        );
      }

      // Update reminders in the background if needed
      if (_notificationsEnabled) {
        unawaited(
          Future(() async {
            try {
              final reminderDB = ref.read(reminderDatabaseProvider);
              final reminders = await reminderDB.getAllReminders();
              await _notificationService.rescheduleAllReminders(
                reminders.where((r) => !r.isCompleted).toList(),
              );
            } catch (e) {
              debugPrint('⚠️ Error rescheduling reminders: $e');
            }
          }),
        );
      }

      // Show feedback to user
      if (mounted) {
        final message =
            _isOffline
                ? 'Settings saved offline. Will sync when online.'
                : 'Settings updated!';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving settings: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProviderProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final authStateAsync = ref.watch(authStateProvider);

    return connectivityAsync.when(
      data: (isOnline) {
        _isOffline = !isOnline;

        return userProfileAsync.when(
          data: (userProfile) {
            if (userProfile == null) {
              return authStateAsync.when(
                data: (authState) {
                  final userId = authState.session?.user.id;
                  if (userId != null) {
                    return FutureBuilder<UserProfile?>(
                      future: _loadProfileFromOfflineDB(userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final offlineProfile = snapshot.data!;
                          if (_currentProfile == null) {
                            _initializeSettingsFromProfile(offlineProfile);
                            _notificationService.setPreferences(
                              offlineProfile.notificationPreferences,
                            );
                          }
                          return _buildMainSettings(
                            context,
                            theme,
                            offlineProfile,
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingScaffold(context, theme);
                        }
                        return _buildErrorScaffold(
                          context,
                          theme,
                          'Could not load offline profile',
                        );
                      },
                    );
                  }
                  return _buildErrorScaffold(context, theme, 'No user session');
                },
                loading: () => _buildLoadingScaffold(context, theme),
                error:
                    (e, st) =>
                        _buildErrorScaffold(context, theme, 'Auth error: $e'),
              );
            }

            if (_currentProfile == null) {
              _initializeSettingsFromProfile(userProfile);
              _notificationService.setPreferences(
                userProfile.notificationPreferences,
              );
            }

            return _buildMainSettings(context, theme, userProfile);
          },
          loading: () => _buildLoadingScaffold(context, theme),
          error:
              (error, stack) =>
                  _buildErrorScaffold(context, theme, 'Error: $error'),
        );
      },
      loading: () => _buildLoadingScaffold(context, theme),
      error:
          (e, st) => _buildErrorScaffold(context, theme, 'Connectivity error'),
    );
  }

  Widget _buildMainSettings(
    BuildContext context,
    ThemeData theme,
    UserProfile userProfile,
  ) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionHeader('Account'),
            _buildSettingCard(
              icon: Icons.person,
              title: 'Profile Information',
              subtitle: 'View and edit your profile',
              onTap: () async {
                final result = await Navigator.push<UserProfile>(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProfileEditScreen(profile: userProfile),
                  ),
                );
                if (result != null && mounted) {
                  setState(() {
                    _initializeSettingsFromProfile(result);
                  });
                }
              },
            ),
            _buildSettingCard(
              icon: Icons.email,
              title: 'Email & Password',
              subtitle: 'Change your email or password',
              onTap: () => _navigateTo('email_password'),
            ),
            const SizedBox(height: 24),
            _buildNotificationsSection(userProfile),

            // Add this after the All Notifications switch in _buildNotificationsSection
            // _buildSwitchCard(
            //   icon: Icons.volume_up,
            //   title: 'Sound',
            //   subtitle: 'Play sound for notifications',
            //   value: _notificationSound, // Add this bool to your state
            //   onChanged: (value) {
            //     setState(() => _notificationSound = value);
            //     _saveSettingsToProfile();
            //   },
            //   indent: true,
            // ),

            // _buildSwitchCard(
            //   icon: Icons.vibration,
            //   title: 'Vibration',
            //   subtitle: 'Vibrate for notifications',
            //   value: _notificationVibration, // Add this bool to your state
            //   onChanged: (value) {
            //     setState(() => _notificationVibration = value);
            //     _saveSettingsToProfile();
            //   },
            //   indent: true,
            // ),
            const SizedBox(height: 24),
            _buildDisplaySection(userProfile),
            const SizedBox(height: 24),
            _buildSectionHeader('Data & Sync'),
            _buildSwitchCard(
              icon: Icons.cloud_sync,
              title: 'Automatic Sync',
              subtitle: 'Automatically sync with cloud',
              value: true,
              onChanged: (_) {},
            ),
            _buildSwitchCard(
              icon: Icons.sim_card,
              title: 'Sync on Cellular',
              subtitle: 'Allow syncing over mobile data',
              value: _syncOnCellular,
              onChanged: (value) {
                setState(() => _syncOnCellular = value);
                _debouncedSave();
              },
            ),
            _buildSwitchCard(
              icon: Icons.offline_bolt,
              title: 'Offline Mode',
              subtitle: 'Continue using app offline',
              value: _offlineMode,
              onChanged: (value) {
                setState(() => _offlineMode = value);
                _debouncedSave();
              },
            ),
            _buildSettingCard(
              icon: Icons.storage,
              title: 'Storage & Cache',
              subtitle: 'Manage app storage (256 MB)',
              onTap: () => _showStorageOptions(),
            ),
            _buildSettingCard(
              icon: Icons.backup,
              title: 'Backup & Restore',
              subtitle: 'Backup your data to cloud',
              onTap: () => _navigateTo('backup'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Privacy & Security'),
            _buildSettingCard(
              icon: Icons.lock,
              title: 'Biometric Lock',
              subtitle: 'Use fingerprint to unlock app',
              onTap: () => _navigateTo('biometric'),
            ),
            _buildSettingCard(
              icon: Icons.security,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _launchUrl('https://example.com/privacy'),
            ),
            _buildSettingCard(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              onTap: () => _launchUrl('https://example.com/terms'),
            ),
            _buildSettingCard(
              icon: Icons.visibility,
              title: 'Data Permissions',
              subtitle: 'Control what data we access',
              onTap: () => _navigateTo('permissions'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Pet Settings'),
            _buildSettingCard(
              icon: Icons.pets,
              title: 'Pet Profile Templates',
              subtitle: 'Quick setup for new pets',
              onTap: () => _navigateTo('pet_templates'),
            ),
            _buildSettingCard(
              icon: Icons.medical_services,
              title: 'Medical Record Settings',
              subtitle: 'Default units and categories',
              onTap: () => _navigateTo('medical_settings'),
            ),
            _buildSettingCard(
              icon: Icons.calendar_today,
              title: 'Reminder Defaults',
              subtitle: 'Set default reminder times',
              onTap: () => _navigateTo('reminder_defaults'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Support & About'),
            _buildSettingCard(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              onTap: () => _navigateTo('help'),
            ),
            _buildSettingCard(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Tell us what you think',
              onTap: () => _showFeedbackDialog(),
            ),
            _buildSettingCard(
              icon: Icons.bug_report,
              title: 'Report a Bug',
              subtitle: 'Report technical issues',
              onTap: () => _showBugReportDialog(),
            ),
            _buildSettingCard(
              icon: Icons.info,
              title: 'About Pet Care',
              subtitle: 'Version 1.0.0 • Build 1001',
              onTap: () => _showAboutDialog(),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Danger Zone', isDanger: true),
            _buildDangerCard(
              icon: Icons.download,
              title: 'Download My Data',
              subtitle: 'Export all your data',
              onTap: () => _showDownloadDataDialog(),
            ),
            _buildDangerCard(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () => _showDeleteAccountDialog(),
            ),
            _buildDangerCard(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () => _showLogoutDialog(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context, ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    ThemeData theme,
    String errorMessage,
  ) {
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : theme.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool indent = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.fromLTRB(indent ? 48 : 16, 6, 16, 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading:
            !indent
                ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary),
                )
                : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDangerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.red,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: onTap,
      ),
    );
  }

  void _showThemeOptions() {
    final currentTheme = ref.watch(themeProvider);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.palette, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Text('Select Theme'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ LIGHT THEME - Already correct
                RadioListTile<AppThemeMode>(
                  title: const Row(
                    children: [
                      Icon(Icons.light_mode, size: 20),
                      SizedBox(width: 8),
                      Text('Light'),
                    ],
                  ),
                  value: AppThemeMode.light,
                  groupValue: currentTheme,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setTheme(value);
                      setState(() => _selectedTheme = 'Light');
                      _debouncedSave();
                      Navigator.pop(context);
                    }
                  },
                ),

                // ✅ DARK THEME - REMOVE 'async'
                RadioListTile<AppThemeMode>(
                  title: const Row(
                    children: [
                      Icon(Icons.dark_mode, size: 20),
                      SizedBox(width: 8),
                      Text('Dark'),
                    ],
                  ),
                  value: AppThemeMode.dark,
                  groupValue: currentTheme,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    // ✅ NO 'async' HERE
                    if (value != null) {
                      ref.read(themeProvider.notifier).setTheme(value);
                      setState(() => _selectedTheme = 'Dark');
                      _debouncedSave(); // ✅ NO 'await' HERE
                      Navigator.pop(context);
                    }
                  },
                ),

                // ✅ SYSTEM THEME - REMOVE 'async'
                RadioListTile<AppThemeMode>(
                  title: const Row(
                    children: [
                      Icon(Icons.brightness_auto, size: 20),
                      SizedBox(width: 8),
                      Text('System'),
                    ],
                  ),
                  subtitle: const Text(
                    'Follow system theme',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: AppThemeMode.system,
                  groupValue: currentTheme,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    // ✅ NO 'async' HERE
                    if (value != null) {
                      ref.read(themeProvider.notifier).setTheme(value);
                      setState(() => _selectedTheme = 'System');
                      _debouncedSave(); // ✅ NO 'await' HERE
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('English'),
                  value: 'English',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _debouncedSave();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Spanish'),
                  value: 'Spanish',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _debouncedSave();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showStorageOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Storage Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Storage Usage: 256 MB / 1 GB'),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: 0.256),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Send Feedback'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Help us improve Pet Care'),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Report a Bug'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Describe the issue you encountered'),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'What went wrong?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for reporting!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Report'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('About Pet Care'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pet Care v1.0.0 (Build 1001)'),
                SizedBox(height: 16),
                Text('Your complete pet health companion'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download My Data'),
            content: const Text('Export all your data...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text('Permanently delete your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleLogout(ref, context);
                  Navigator.pop(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildNotificationsSection(UserProfile userProfile) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Notifications & Reminders'),
        _buildSwitchCard(
          icon: Icons.notifications,
          title: 'All Notifications',
          subtitle: 'Turn on/off all notifications',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _debouncedSave();
          },
        ),
        _buildSwitchCard(
          icon: Icons.volume_up,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: _notificationSound,
          onChanged: (value) {
            // ✅ Simple and clean
            setState(() => _notificationSound = value);
            _debouncedSave();
          },
          indent: true,
        ),
        _buildSwitchCard(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: _notificationVibration,
          onChanged: (value) {
            setState(() => _notificationVibration = value);
            _debouncedSave();
          },
          indent: true,
        ),
        _buildSettingCard(
          icon: Icons.send,
          title: 'Send Test Notification',
          subtitle: 'Test if notifications are working',
          onTap: () => _sendTestNotification(),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(UserProfile? userProfile) {
    if (userProfile == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Display & Theme'),
        _buildSettingCard(
          icon: Icons.palette,
          title: 'App Theme',
          subtitle: 'Current: $_selectedTheme',
          onTap: () => _showThemeOptions(),
        ),
        _buildSettingCard(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'Current: $_selectedLanguage',
          onTap: () => _showLanguageOptions(),
        ),
      ],
    );
  }

  void _navigateTo(String route) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigate to $route')));
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildtestNotificationsSection(UserProfile userProfile) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Notifications & Reminders'),
        _buildSwitchCard(
          icon: Icons.notifications,
          title: 'All Notifications',
          subtitle: 'Turn on/off all notifications',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _debouncedSave();
          },
        ),
        // ADD TEST NOTIFICATION BUTTON HERE
        _buildSettingCard(
          icon: Icons.send,
          title: 'Send Test Notification',
          subtitle: 'Test if notifications are working',
          onTap: () => _sendTestNotification(),
        ),
      ],
    );
  }

  // Add this method to your _SettingsScreenState class
  Future<void> _sendTestNotification() async {
    if (!_notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable notifications first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('=== TEST NOTIFICATION DEBUG ===');
    print('UI State:');
    print('  _notificationSound: $_notificationSound');
    print('  _notificationVibration: $_notificationVibration');
    print('  _notificationsEnabled: $_notificationsEnabled');
    print('Current Profile Preferences:');
    if (_currentProfile != null) {
      print(
        '  soundEnabled: ${_currentProfile!.notificationPreferences.soundEnabled}',
      );
      print(
        '  vibrationEnabled: ${_currentProfile!.notificationPreferences.vibrationEnabled}',
      );
    } else {
      print('  _currentProfile is NULL!');
    }
    print('================================');

    try {
      await _notificationService.showImmediateNotification(
        title: '🐾 Pet Care Test',
        body: 'Sound: $_notificationSound, Vibration: $_notificationVibration',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Test notification sent! Check your notification bar.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
