import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_care/utils/countries.dart';

class LocationDetailsStep extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onSkip;

  const LocationDetailsStep({
    super.key,
    required this.initialData,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<LocationDetailsStep> createState() => _LocationDetailsStepState();
}

class _LocationDetailsStepState extends State<LocationDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _streetAddressController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  String? _selectedCountry;

  // Common countries list - you can expand this

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialData['country'];
    _streetAddressController.text = widget.initialData['streetAddress'] ?? '';
    _apartmentController.text = widget.initialData['apartment'] ?? '';
    _cityController.text = widget.initialData['city'] ?? '';
    _stateController.text = widget.initialData['state'] ?? '';
    _zipCodeController.text = widget.initialData['zipCode'] ?? '';
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ZIP/Postal code';
    }

    // Different validation based on country
    if (_selectedCountry == 'US') {
      if (value.length != 5) {
        return 'ZIP code must be 5 digits';
      }
    } else if (_selectedCountry == 'CA') {
      if (!RegExp(
        r'^[A-Z]\d[A-Z]\s?\d[A-Z]\d$',
      ).hasMatch(value.toUpperCase())) {
        return 'Invalid postal code format (e.g., K1A 0B1)';
      }
    } else if (_selectedCountry == 'GB') {
      if (value.length < 5 || value.length > 8) {
        return 'Invalid postcode format';
      }
    }
    // Add more country-specific validations as needed

    return null;
  }

  static String getStateLabel(String code) {
    switch (code) {
      case 'US':
        return 'State *';
      case 'CA':
        return 'Province *';
      case 'GB':
        return 'County';
      case 'AU':
        return 'State/Territory *';
      case 'IN':
        return 'State *';
      case 'JP':
        return 'Prefecture *';
      case 'CN':
        return 'Province *';
      case 'BR':
        return 'State *';
      case 'MX':
        return 'State *';
      default:
        return 'State/Province *';
    }
  }

  static String getZipLabel(String code) {
    switch (code) {
      case 'US':
        return 'ZIP Code *';
      case 'CA':
      case 'GB':
        return 'Postal Code *';
      case 'AU':
        return 'Postcode *';
      case 'IN':
        return 'PIN Code *';
      case 'JP':
        return 'Postal Code *';
      case 'BR':
        return 'CEP *';
      case 'MX':
        return 'Código Postal *';
      default:
        return 'ZIP/Postal Code *';
    }
  }

  static String getZipHint(String code) {
    switch (code) {
      case 'US':
        return '10001';
      case 'CA':
        return 'K1A 0B1';
      case 'GB':
        return 'SW1A 1AA';
      case 'AU':
        return '2000';
      case 'IN':
        return '110001';
      case 'DE':
        return '10115';
      case 'FR':
        return '75001';
      case 'IT':
        return '00184';
      case 'BR':
        return '01000-000';
      case 'JP':
        return '100-0001';
      default:
        return '12345';
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext({
      'country': _selectedCountry,
      'streetAddress': _streetAddressController.text.trim(),
      'apartment':
          _apartmentController.text.trim().isNotEmpty
              ? _apartmentController.text.trim()
              : null,
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.location_on_outlined,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Your Location',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We need your address for pet care services and home visits.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Country Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Country *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              hint: const Text('Select your country'),
              items:
                  CountryUtils.countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country.code, // Country code (e.g., "US")
                      child: Text(
                        '${country.flag} ${country.name}',
                      ), // Show flag + name
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  // Clear state and zip when country changes
                  _stateController.clear();
                  _zipCodeController.clear();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your country';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Street Address
            TextFormField(
              controller: _streetAddressController,
              decoration: const InputDecoration(
                labelText: 'Street Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_outlined),
                hintText: '123 Main Street',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your street address';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Apartment/Unit
            TextFormField(
              controller: _apartmentController,
              decoration: const InputDecoration(
                labelText: 'Apartment/Unit (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment_outlined),
                hintText: 'Apt 4B',
              ),
            ),

            const SizedBox(height: 20),

            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city_outlined),
                hintText: 'New York',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // State and ZIP Code Row
            Row(
              children: [
                // State/Province
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _stateController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: _selectedCountry == 'US' ? 2 : 50,
                    inputFormatters:
                        _selectedCountry == 'US'
                            ? [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]'),
                              ),
                              UpperCaseTextFormatter(),
                            ]
                            : null,
                    decoration: InputDecoration(
                      labelText: getStateLabel(_selectedCountry ?? ''),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.map_outlined),
                      hintText: _selectedCountry == 'US' ? 'NY' : 'State',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (_selectedCountry == 'US' && value.length != 2) {
                        return 'Use 2-letter code';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // ZIP/Postal Code
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _zipCodeController,
                    keyboardType:
                        _selectedCountry == 'US'
                            ? TextInputType.number
                            : TextInputType.text,
                    maxLength:
                        _selectedCountry == 'US'
                            ? 5
                            : (_selectedCountry == 'CA' ? 7 : 10),
                    inputFormatters:
                        _selectedCountry == 'US'
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : null,
                    textCapitalization:
                        _selectedCountry == 'CA' || _selectedCountry == 'GB'
                            ? TextCapitalization.characters
                            : TextCapitalization.none,
                    decoration: InputDecoration(
                      labelText: getZipLabel(_selectedCountry ?? ''),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                      hintText: getZipHint(_selectedCountry ?? ''),
                      counterText: '',
                    ),
                    validator: _validateZipCode,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleNext,
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 12),

            // Skip Button
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

// Upper case text formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
