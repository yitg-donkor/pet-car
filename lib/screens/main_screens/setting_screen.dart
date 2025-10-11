import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // State variables
  bool _notificationsEnabled = true;
  bool _reminderNotifications = true;
  bool _healthAlerts = true;
  bool _marketingEmails = false;
  bool _darkMode = false;
  bool _syncOnCellular = false;
  bool _offlineMode = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  Future<void> _handleLogout(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider.notifier);
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              title: 'Profile Information',
              subtitle: 'View and edit your profile',
              onTap: () => _navigateTo('profile'),
            ),
            _buildSettingCard(
              icon: Icons.email,
              title: 'Email & Password',
              subtitle: 'Change your email or password',
              onTap: () => _navigateTo('email_password'),
            ),
            _buildSettingCard(
              icon: Icons.phone,
              title: 'Phone Number',
              subtitle: 'Verify and update your phone',
              onTap: () => _navigateTo('phone'),
            ),
            _buildSettingCard(
              icon: Icons.location_on,
              title: 'Location Settings',
              subtitle: 'Manage location permissions',
              onTap: () => _navigateTo('location'),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications & Reminders'),
            _buildSwitchCard(
              icon: Icons.notifications,
              title: 'All Notifications',
              subtitle: 'Turn on/off all notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
            if (_notificationsEnabled) ...[
              _buildSwitchCard(
                icon: Icons.alarm,
                title: 'Reminder Notifications',
                subtitle: 'Get notified about reminders',
                value: _reminderNotifications,
                onChanged: (value) {
                  setState(() => _reminderNotifications = value);
                },
                indent: true,
              ),
              _buildSwitchCard(
                icon: Icons.health_and_safety,
                title: 'Health Alerts',
                subtitle: 'Notifications about pet health',
                value: _healthAlerts,
                onChanged: (value) {
                  setState(() => _healthAlerts = value);
                },
                indent: true,
              ),
              _buildSwitchCard(
                icon: Icons.mail,
                title: 'Marketing Emails',
                subtitle: 'News and special offers',
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() => _marketingEmails = value);
                },
                indent: true,
              ),
            ],
            _buildSettingCard(
              icon: Icons.schedule,
              title: 'Notification Schedule',
              subtitle: 'Set quiet hours (9 PM - 8 AM)',
              onTap: () => _navigateTo('notification_schedule'),
            ),

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
              },
            ),
            _buildSwitchCard(
              icon: Icons.offline_bolt,
              title: 'Offline Mode',
              subtitle: 'Continue using app offline',
              value: _offlineMode,
              onChanged: (value) {
                setState(() => _offlineMode = value);
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
  }

  // Helper Widgets
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

  // Dialog Functions
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
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Dark'),
                  value: 'Dark',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('System'),
                  value: 'System',
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
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
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Spanish'),
                  value: 'Spanish',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('French'),
                  value: 'French',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('German'),
                  value: 'German',
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
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

  // Utility Functions
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

  void _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
