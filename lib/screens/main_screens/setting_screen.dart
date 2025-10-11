import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';

import 'package:pet_care/screens/settingsscreens/profile_edit_screen.dart';
import 'package:pet_care/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_care/models/user_profile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _reminderNotifications;
  late bool _healthAlerts;
  late bool _marketingEmails;
  late bool _syncOnCellular;
  late bool _offlineMode;
  late String _selectedLanguage;
  late String _selectedTheme;
  UserProfile? _currentProfile;
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  void _initializeSettingsFromProfile(UserProfile? userProfile) {
    if (userProfile != null) {
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
    } else {
      _notificationsEnabled = true;
      _reminderNotifications = true;
      _healthAlerts = true;
      _marketingEmails = false;
      _syncOnCellular = false;
      _offlineMode = true;
      _selectedLanguage = 'English';
      _selectedTheme = 'Light';
    }
  }

  Future<void> _handleLogout(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider.notifier);
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _saveSettingsToProfile() async {
    if (_currentProfile == null) return;

    try {
      final updatedProfile = _currentProfile!.copyWith(
        notificationPreferences: _currentProfile!.notificationPreferences
            .copyWith(
              allNotificationsEnabled: _notificationsEnabled,
              reminderNotifications: _reminderNotifications,
              healthAlerts: _healthAlerts,
              marketingEmails: _marketingEmails,
            ),
        appSettings: _currentProfile!.appSettings.copyWith(
          syncOnCellular: _syncOnCellular,
          offlineMode: _offlineMode,
          language: _selectedLanguage,
          theme: _selectedTheme,
        ),
      );

      // Update via provider
      await ref
          .read(userProfileProviderProvider.notifier)
          .updateNotificationPreferences(
            updatedProfile.notificationPreferences,
          );

      await ref
          .read(userProfileProviderProvider.notifier)
          .updateAppSettings(updatedProfile.appSettings);

      // Update notification service with new preferences
      _notificationService.setPreferences(
        updatedProfile.notificationPreferences,
      );

      // Handle notification rescheduling based on changes
      if (_notificationsEnabled) {
        final reminderDB = ref.read(reminderDatabaseProvider);
        final reminders = await reminderDB.getAllReminders();
        await _notificationService.rescheduleAllReminders(
          reminders.where((r) => !r.isCompleted).toList(),
        );
      } else {
        await _notificationService.cancelAllNotifications();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProviderProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile != null && _currentProfile == null) {
          _initializeSettingsFromProfile(userProfile);

          _notificationService.setPreferences(
            userProfile.notificationPreferences,
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Account Section
                _buildSectionHeader('Account'),
                _buildSettingCard(
                  icon: Icons.person,
                  title: 'Profile Informationant',
                  subtitle: 'View and edit your profile',
                  onTap: () async {
                    if (userProfile != null) {
                      final result = await Navigator.push<UserProfile>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProfileEditScreen(profile: userProfile),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          _initializeSettingsFromProfile(result);
                        });
                      }
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

                // Notifications Section
                _buildNotificationsSection(userProfile),

                const SizedBox(height: 24),

                // Display Section
                _buildSectionHeader('Display & Theme'),
                _buildSettingCard(
                  icon: Icons.palette,
                  title: 'App Theme',
                  subtitle: 'Current: $_selectedTheme',
                  onTap: () => _showThemeOptions(),
                  trailing: Text(
                    _selectedTheme,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingCard(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Current: $_selectedLanguage',
                  onTap: () => _showLanguageOptions(),
                  trailing: Text(
                    _selectedLanguage,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSettingCard(
                  icon: Icons.text_fields,
                  title: 'Text Size',
                  subtitle: 'Adjust text size for readability',
                  onTap: () => _navigateTo('text_size'),
                ),
                const SizedBox(height: 24),

                // Data & Sync Section
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
                    _saveSettingsToProfile();
                  },
                ),
                _buildSwitchCard(
                  icon: Icons.offline_bolt,
                  title: 'Offline Mode',
                  subtitle: 'Continue using app offline',
                  value: _offlineMode,
                  onChanged: (value) {
                    setState(() => _offlineMode = value);
                    _saveSettingsToProfile();
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

                // Privacy & Security Section
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

                // Pet Settings Section
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

                // Support & About Section
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

                // Danger Zone Section
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
      },
      loading:
          () => Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              ),
            ),
          ),
      error:
          (error, stack) => Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(child: Text('Error loading settings: $error')),
          ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Colors.black,
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50)),
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
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF4CAF50)),
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
          activeColor: const Color(0xFF4CAF50),
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
          child: Icon(icon, color: Colors.red),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('Light'),
                  value: 'Light',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    _saveSettingsToProfile();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Dark'),
                  value: 'Dark',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    _saveSettingsToProfile();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('System'),
                  value: 'System',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    _saveSettingsToProfile();
                    Navigator.pop(context);
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
                    _saveSettingsToProfile();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Spanish'),
                  value: 'Spanish',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _saveSettingsToProfile();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('French'),
                  value: 'French',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _saveSettingsToProfile();
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('German'),
                  value: 'German',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    _saveSettingsToProfile();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage Usage: 256 MB / 1 GB',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.256,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Photos'),
                  subtitle: const Text('128 MB'),
                  onTap: () => _clearStorageCategory('photos'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Documents'),
                  subtitle: const Text('64 MB'),
                  onTap: () => _clearStorageCategory('documents'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('64 MB'),
                  onTap: () => _clearStorageCategory('cache'),
                ),
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
    final controller = TextEditingController();
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
                  controller: controller,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showBugReportDialog() {
    final controller = TextEditingController();
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
                  controller: controller,
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pet Care v1.0.0 (Build 1001)'),
                const SizedBox(height: 8),
                const Text('Your complete pet health companion'),
                const SizedBox(height: 16),
                const Text(
                  'Features:\n'
                  '• Medical record tracking\n'
                  '• AI health insights\n'
                  '• Smart reminders\n'
                  '• Offline support',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Developed with care for pet owners worldwide',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Download My Data'),
            content: const Text(
              'This will create a downloadable file containing all your data including pet profiles, medical records, reminders, and activity logs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download started...')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Account'),
            content: const Text(
              'Warning: This will permanently delete your account and all associated data. This action cannot be undone.',
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
                      content: Text('Account deletion initiated...'),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Permanently'),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging out...')),
                  );
                  _handleLogout(ref, context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildNotificationsSection(UserProfile? userProfile) {
    if (userProfile == null) {
      return const SizedBox.shrink();
    }

    final notifPrefs = userProfile.notificationPreferences;

    return Column(
      children: [
        const SizedBox(height: 24),

        // Status Card
        _buildNotificationStatusCard(notifPrefs),

        const SizedBox(height: 16),
        _buildSectionHeader('Notifications & Reminders'),

        // All Notifications Master Toggle
        _buildSwitchCard(
          icon: Icons.notifications,
          title: 'All Notifications',
          subtitle: 'Turn on/off all notifications',
          value: _notificationsEnabled,
          onChanged: (value) async {
            setState(() => _notificationsEnabled = value);
            await _saveSettingsToProfile();
          },
        ),

        // Sub-settings (only show if notifications are enabled)
        if (_notificationsEnabled) ...[
          _buildSwitchCard(
            icon: Icons.alarm,
            title: 'Reminder Notifications',
            subtitle: 'Get notified about reminders',
            value: _reminderNotifications,
            onChanged: (value) async {
              setState(() => _reminderNotifications = value);
              await _saveSettingsToProfile();
            },
            indent: true,
          ),

          _buildSwitchCard(
            icon: Icons.health_and_safety,
            title: 'Health Alerts',
            subtitle: 'Notifications about pet health',
            value: _healthAlerts,
            onChanged: (value) async {
              setState(() => _healthAlerts = value);
              await _saveSettingsToProfile();
            },
            indent: true,
          ),

          _buildSwitchCard(
            icon: Icons.mail,
            title: 'Marketing Emails',
            subtitle: 'News and special offers',
            value: _marketingEmails,
            onChanged: (value) async {
              setState(() => _marketingEmails = value);
              await _saveSettingsToProfile();
            },
            indent: true,
          ),
        ],

        // Quiet Hours
        _buildSettingCard(
          icon: Icons.nightlight,
          title: 'Quiet Hours',
          subtitle:
              notifPrefs.quietHoursEnabled
                  ? 'Active: ${notifPrefs.quietHoursStart} - ${notifPrefs.quietHoursEnd}'
                  : 'Disabled',
          onTap: () => _showQuietHoursDialog(notifPrefs),
          trailing: Switch(
            value: notifPrefs.quietHoursEnabled,
            onChanged: (value) async {
              await ref
                  .read(userProfileProviderProvider.notifier)
                  .updateNotificationPreferences(
                    notifPrefs.copyWith(quietHoursEnabled: value),
                  );
              setState(() {});
            },
            activeColor: const Color(0xFF4CAF50),
          ),
        ),

        // Test Notification
        _buildSettingCard(
          icon: Icons.send,
          title: 'Send Test Notification',
          subtitle: 'Test if notifications are working',
          onTap: () => _sendTestNotification(notifPrefs),
        ),
      ],
    );
  }

  // ADD Status Card Widget:
  Widget _buildNotificationStatusCard(NotificationPreferences notifPrefs) {
    final isEnabled = notifPrefs.allNotificationsEnabled;

    // Check if in quiet hours
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    bool isQuietTime = false;
    if (notifPrefs.quietHoursEnabled) {
      final startParts = notifPrefs.quietHoursStart.split(':');
      final endParts = notifPrefs.quietHoursEnd.split(':');
      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final currentMinutes = now.hour * 60 + now.minute;

      if (startMinutes < endMinutes) {
        isQuietTime =
            currentMinutes >= startMinutes && currentMinutes < endMinutes;
      } else {
        isQuietTime =
            currentMinutes >= startMinutes || currentMinutes < endMinutes;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          isEnabled
              ? (isQuietTime ? Colors.blue.shade50 : Colors.green.shade50)
              : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isEnabled
                  ? (isQuietTime ? Icons.bedtime : Icons.notifications_active)
                  : Icons.notifications_off,
              color:
                  isEnabled
                      ? (isQuietTime ? Colors.blue : Colors.green)
                      : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnabled
                        ? (isQuietTime
                            ? 'Quiet Hours Active'
                            : 'Notifications Active')
                        : 'Notifications Disabled',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isEnabled
                              ? (isQuietTime
                                  ? Colors.blue.shade900
                                  : Colors.green.shade900)
                              : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled
                        ? (isQuietTime
                            ? '🌙 Silent mode until ${notifPrefs.quietHoursEnd}'
                            : 'You\'ll receive notifications')
                        : 'Turn on to receive reminders',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isEnabled
                              ? (isQuietTime
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700)
                              : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE Quiet Hours Dialog:
  void _showQuietHoursDialog(NotificationPreferences notifPrefs) {
    // Parse current quiet hours
    final startParts = notifPrefs.quietHoursStart.split(':');
    final endParts = notifPrefs.quietHoursEnd.split(':');

    int startHour = int.parse(startParts[0]);
    int endHour = int.parse(endParts[0]);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.nightlight, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('Quiet Hours'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Notifications will be silent during these hours',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Start Time
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Start Time:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownButton<int>(
                          value: startHour,
                          items: List.generate(24, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(
                                '${index.toString().padLeft(2, '0')}:00',
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setDialogState(() {
                              startHour = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // End Time
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'End Time:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownButton<int>(
                          value: endHour,
                          items: List.generate(24, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(
                                '${index.toString().padLeft(2, '0')}:00',
                              ),
                            );
                          }),
                          onChanged: (value) {
                            setDialogState(() {
                              endHour = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Notifications will not make sound or vibrate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newPrefs = notifPrefs.copyWith(
                        quietHoursStart:
                            '${startHour.toString().padLeft(2, '0')}:00',
                        quietHoursEnd:
                            '${endHour.toString().padLeft(2, '0')}:00',
                      );

                      await ref
                          .read(userProfileProviderProvider.notifier)
                          .updateNotificationPreferences(newPrefs);

                      // Update notification service
                      _notificationService.setPreferences(newPrefs);

                      setState(() {});
                      Navigator.pop(context);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Quiet hours: ${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // ADD Test Notification Method:
  Future<void> _sendTestNotification(NotificationPreferences notifPrefs) async {
    if (!notifPrefs.allNotificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable notifications first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _notificationService.showImmediateNotification(
      title: '🐾 Pet Care Test',
      body: 'Notifications are working perfectly!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateTo(String route) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigate to $route')));
  }

  void _clearStorageCategory(String category) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Cleared $category')));
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
