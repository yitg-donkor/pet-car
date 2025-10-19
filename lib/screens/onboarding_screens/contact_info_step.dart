import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactInfoStep extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onSkip;

  const ContactInfoStep({
    super.key,
    required this.initialData,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<ContactInfoStep> createState() => _ContactInfoStepState();
}

class _ContactInfoStepState extends State<ContactInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.initialData['phoneNumber'] ?? '';
    _emergencyNameController.text =
        widget.initialData['emergencyContactName'] ?? '';
    _emergencyPhoneController.text =
        widget.initialData['emergencyContactPhone'] ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }

    return null;
  }

  String? _validateEmergencyPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }

    return null;
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext({
      'phoneNumber': _phoneController.text.trim(),
      'emergencyContactName':
          _emergencyNameController.text.trim().isNotEmpty
              ? _emergencyNameController.text.trim()
              : null,
      'emergencyContactPhone':
          _emergencyPhoneController.text.trim().isNotEmpty
              ? _emergencyPhoneController.text.trim()
              : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
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
                Icons.contact_phone_outlined,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Contact Information',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us reach you and your emergency contact in case of urgent situations.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            TextFormField(
              style: TextStyle(color: theme.colorScheme.onPrimary),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                _PhoneNumberFormatter(),
              ],
              decoration: InputDecoration(
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '(555) 123-4567',
                helperText: 'We\'ll use this for appointment reminders',
              ),
              validator: _validatePhone,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Emergency Contact (Optional)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 24),

            TextFormField(
              style: TextStyle(color: theme.colorScheme.onPrimary),
              controller: _emergencyNameController,
              decoration: InputDecoration(
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
                labelText: 'Emergency Contact Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'John Doe',
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              style: TextStyle(color: theme.colorScheme.onPrimary),
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
                _PhoneNumberFormatter(),
              ],
              decoration: InputDecoration(
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
                labelText: 'Emergency Contact Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '(555) 123-4567',
              ),
              validator: _validateEmergencyPhone,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleNext,
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: widget.onSkip,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      buffer.write(text[i]);
      if (i == 2) {
        buffer.write(') ');
      } else if (i == 5) {
        buffer.write('-');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
