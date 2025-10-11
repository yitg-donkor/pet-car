import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_care/providers/offline_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final _notificationService = NotificationService();

  bool _remindersEnabled = true;
  bool _earlyNotificationsEnabled = true;
  bool _dailySummaryEnabled = true;
  TimeOfDay _summaryTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
      _earlyNotificationsEnabled = prefs.getBool('early_notifications') ?? true;
      _dailySummaryEnabled = prefs.getBool('daily_summary_enabled') ?? true;
      final hour = prefs.getInt('summary_hour') ?? 8;
      final minute = prefs.getInt('summary_minute') ?? 0;
      _summaryTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setBool('early_notifications', _earlyNotificationsEnabled);
    await prefs.setBool('daily_summary_enabled', _dailySummaryEnabled);
    await prefs.setInt('summary_hour', _summaryTime.hour);
    await prefs.setInt('summary_minute', _summaryTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          const Text(
            'Manage Notifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how and when you receive reminders',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          // Reminder Notifications
          _buildSettingCard(
            icon: Icons.notifications_active,
            title: 'Reminder Notifications',
            subtitle: 'Get notified for scheduled reminders',
            value: _remindersEnabled,
            onChanged: (value) async {
              setState(() => _remindersEnabled = value);
              await _saveSettings();

              if (value) {
                // Re-enable notifications
                final allReminders =
                    await ref.read(reminderDatabaseProvider).getAllReminders();
                await _notificationService.rescheduleAllReminders(
                  allReminders.where((r) => !r.isCompleted).toList(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications enabled'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                await _notificationService.cancelAllNotifications();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications disabled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 12),

          // Early Notifications
          _buildSettingCard(
            icon: Icons.access_time,
            title: 'Early Notifications',
            subtitle: 'Notify 15 minutes before each reminder',
            value: _earlyNotificationsEnabled,
            onChanged: (value) async {
              setState(() => _earlyNotificationsEnabled = value);
              await _saveSettings();
            },
          ),

          const SizedBox(height: 12),

          // Daily Summary
          _buildSettingCard(
            icon: Icons.summarize,
            title: 'Daily Summary',
            subtitle:
                'Get a summary of today\'s tasks at ${_summaryTime.format(context)}',
            value: _dailySummaryEnabled,
            onChanged: (value) async {
              setState(() => _dailySummaryEnabled = value);
              await _saveSettings();

              if (value) {
                // Schedule daily summary
                await _notificationService.scheduleDailySummary(
                  _summaryTime.hour,
                  _summaryTime.minute,
                  5, // This will be updated dynamically
                );
              }
            },
            trailing:
                _dailySummaryEnabled
                    ? IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                      onPressed: () async {
                        final newTime = await showTimePicker(
                          context: context,
                          initialTime: _summaryTime,
                        );
                        if (newTime != null) {
                          setState(() => _summaryTime = newTime);
                          await _saveSettings();
                          await _notificationService.scheduleDailySummary(
                            newTime.hour,
                            newTime.minute,
                            5,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Daily summary time updated to ${newTime.format(context)}',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    )
                    : null,
          ),

          const SizedBox(height: 30),

          // Test Notification Button
          _buildActionButton(
            icon: Icons.send,
            label: 'Send Test Notification',
            color: Colors.blue,
            onTap: () async {
              await _notificationService.showImmediateNotification(
                title: '🐾 Test Notification',
                body: 'If you see this, notifications are working!',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 12),

          // View Pending Notifications
          _buildActionButton(
            icon: Icons.list,
            label: 'View Pending Notifications',
            color: Colors.purple,
            onTap: () async {
              final pending =
                  await _notificationService.getPendingNotifications();
              if (mounted) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Pending Notifications'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total: ${pending.length} scheduled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (pending.isEmpty)
                                const Text('No pending notifications')
                              else
                                ...pending.map(
                                  (notification) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title ?? 'No title',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          notification.body ?? 'No body',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
            },
          ),

          const SizedBox(height: 30),

          // Information Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications work even when the app is closed. '
                    'Make sure to enable notifications in your device settings.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Permission Check
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery Optimization',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Disable battery optimization for this app to ensure timely notifications.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    required bool value,
    required Function(bool) onChanged,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF4CAF50),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
