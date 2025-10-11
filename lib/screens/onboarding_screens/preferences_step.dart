import 'package:flutter/material.dart';
import 'package:pet_care/models/user_profile.dart';

class PreferencesStep extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onComplete;

  const PreferencesStep({
    super.key,
    required this.initialData,
    required this.onComplete,
  });

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  late bool _allNotificationsEnabled;
  late bool _reminderNotifications;
  late bool _healthAlerts;
  late bool _marketingEmails;
  late String _quietHoursStart;
  late String _quietHoursEnd;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData['notificationPreferences'] != null) {
      final prefs =
          widget.initialData['notificationPreferences']
              as NotificationPreferences;
      _allNotificationsEnabled = prefs.allNotificationsEnabled;
      _reminderNotifications = prefs.reminderNotifications;
      _healthAlerts = prefs.healthAlerts;
      _marketingEmails = prefs.marketingEmails;
      _quietHoursStart = prefs.quietHoursStart;
      _quietHoursEnd = prefs.quietHoursEnd;
    } else {
      _allNotificationsEnabled = true;
      _reminderNotifications = true;
      _healthAlerts = true;
      _marketingEmails = false;
      _quietHoursStart = '21:00';
      _quietHoursEnd = '08:00';
    }
  }

  void _handleComplete() async {
    setState(() {
      _isCreating = true;
    });

    final preferences = NotificationPreferences(
      allNotificationsEnabled: _allNotificationsEnabled,
      reminderNotifications: _reminderNotifications,
      healthAlerts: _healthAlerts,
      marketingEmails: _marketingEmails,
      quietHoursStart: _quietHoursStart,
      quietHoursEnd: _quietHoursEnd,
    );

    widget.onComplete({'notificationPreferences': preferences});
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(
          (isStart ? _quietHoursStart : _quietHoursEnd).split(':')[0],
        ),
        minute: int.parse(
          (isStart ? _quietHoursStart : _quietHoursEnd).split(':')[1],
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        final timeString =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _quietHoursStart = timeString;
        } else {
          _quietHoursEnd = timeString;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notification Preferences',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to receive updates about your pets.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Main Notifications Toggle
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: SwitchListTile(
              value: _allNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _allNotificationsEnabled = value;
                });
              },
              title: const Text('All Notifications'),
              subtitle: const Text('Enable or disable all notifications'),
              secondary: const Icon(Icons.notifications_outlined),
            ),
          ),

          const SizedBox(height: 16),

          // Conditional notification types
          if (_allNotificationsEnabled) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _reminderNotifications,
                    onChanged: (value) {
                      setState(() {
                        _reminderNotifications = value;
                      });
                    },
                    title: const Text('Reminder Notifications'),
                    subtitle: const Text(
                      'Appointment and medication reminders',
                    ),
                    secondary: const Icon(Icons.alarm_outlined),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SwitchListTile(
                    value: _healthAlerts,
                    onChanged: (value) {
                      setState(() {
                        _healthAlerts = value;
                      });
                    },
                    title: const Text('Health Alerts'),
                    subtitle: const Text('Important pet health updates'),
                    secondary: const Icon(Icons.health_and_safety_outlined),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SwitchListTile(
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() {
                        _marketingEmails = value;
                      });
                    },
                    title: const Text('Marketing Emails'),
                    subtitle: const Text('News, tips, and special offers'),
                    secondary: const Icon(Icons.mail_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quiet Hours Section
            Text(
              'Quiet Hours',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No notifications during these hours',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectTime(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _quietHoursStart,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectTime(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _quietHoursEnd,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Profile Summary
          Text(
            'Profile Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow(
                    Icons.person_outline,
                    'Name',
                    widget.initialData['fullName'] ?? 'Not provided',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    Icons.alternate_email,
                    'Username',
                    '@${widget.initialData['username'] ?? 'Not provided'}',
                  ),
                  if (widget.initialData['phoneNumber'] != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.phone_outlined,
                      'Phone',
                      widget.initialData['phoneNumber'],
                    ),
                  ],
                  if (widget.initialData['streetAddress'] != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.location_on_outlined,
                      'Address',
                      _formatAddress(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Complete Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _handleComplete,
              child:
                  _isCreating
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Complete Profile',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ),
          const SizedBox(height: 16),

          // Terms Text
          Text(
            'By completing your profile, you agree to our Terms of Service and Privacy Policy.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress() {
    final parts = <String>[];

    if (widget.initialData['streetAddress'] != null) {
      parts.add(widget.initialData['streetAddress']);
    }
    if (widget.initialData['apartment'] != null &&
        widget.initialData['apartment'].toString().isNotEmpty) {
      parts.add(widget.initialData['apartment']);
    }
    if (widget.initialData['city'] != null) {
      parts.add(widget.initialData['city']);
    }
    if (widget.initialData['state'] != null) {
      parts.add(widget.initialData['state']);
    }
    if (widget.initialData['zipCode'] != null) {
      parts.add(widget.initialData['zipCode']);
    }

    return parts.join(', ');
  }
}
