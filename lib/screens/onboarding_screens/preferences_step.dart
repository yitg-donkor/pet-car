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
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _pushNotifications = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData['notificationPreferences'] != null) {
      final prefs =
          widget.initialData['notificationPreferences']
              as NotificationPreferences;
      _emailNotifications = prefs.email;
      _smsNotifications = prefs.sms;
      _pushNotifications = prefs.push;
    }
  }

  void _handleComplete() async {
    setState(() {
      _isCreating = true;
    });

    final preferences = NotificationPreferences(
      email: _emailNotifications,
      sms: _smsNotifications,
      push: _pushNotifications,
    );

    widget.onComplete({'notificationPreferences': preferences});
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

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Appointment reminders and updates'),
                  secondary: const Icon(Icons.email_outlined),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                SwitchListTile(
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  },
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Text message alerts'),
                  secondary: const Icon(Icons.sms_outlined),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                SwitchListTile(
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                  title: const Text('Push Notifications'),
                  subtitle: const Text('In-app notifications'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

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
