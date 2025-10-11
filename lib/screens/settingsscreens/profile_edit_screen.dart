import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/user_profile.dart';
import 'package:pet_care/providers/offline_providers.dart';

import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const ProfileEditScreen({Key? key, required this.profile}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _apartmentController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  bool _isLoading = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _usernameController = TextEditingController(text: widget.profile.username);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _phoneController = TextEditingController(
      text: widget.profile.phoneNumber ?? '',
    );
    _streetController = TextEditingController(
      text: widget.profile.streetAddress ?? '',
    );
    _apartmentController = TextEditingController(
      text: widget.profile.apartment ?? '',
    );
    _cityController = TextEditingController(text: widget.profile.city ?? '');
    _stateController = TextEditingController(text: widget.profile.state ?? '');
    _zipController = TextEditingController(text: widget.profile.zipCode ?? '');
    _countryController = TextEditingController(
      text: widget.profile.country ?? '',
    );
    _emergencyNameController = TextEditingController(
      text: widget.profile.emergencyContactName ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.profile.emergencyContactPhone ?? '',
    );
    _avatarPath = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name and username are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileDB = ref.read(profileLocalDBProvider);

      final updatedProfile = UserProfile(
        id: widget.profile.id,
        fullName: _fullNameController.text,
        username: _usernameController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        phoneVerified: widget.profile.phoneVerified,
        streetAddress:
            _streetController.text.isEmpty ? null : _streetController.text,
        apartment:
            _apartmentController.text.isEmpty
                ? null
                : _apartmentController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        state: _stateController.text.isEmpty ? null : _stateController.text,
        zipCode: _zipController.text.isEmpty ? null : _zipController.text,
        country:
            _countryController.text.isEmpty ? null : _countryController.text,
        emergencyContactName:
            _emergencyNameController.text.isEmpty
                ? null
                : _emergencyNameController.text,
        emergencyContactPhone:
            _emergencyPhoneController.text.isEmpty
                ? null
                : _emergencyPhoneController.text,
        notificationPreferences: widget.profile.notificationPreferences,
        avatarUrl: _avatarPath,
        isActive: widget.profile.isActive,
        createdAt: widget.profile.createdAt,
        updatedAt: widget.profile.updatedAt,
      );

      await profileDB.updateProfile(updatedProfile);

      // Sync to Supabase
      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.syncProfilesToSupabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
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
          'Edit Profile',
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
        actions: [
          _isLoading
              ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF4CAF50)),
                onPressed: _saveProfile,
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ).withOpacity(0.1),
                        backgroundImage:
                            _avatarPath != null
                                ? NetworkImage(_avatarPath!) as ImageProvider
                                : null,
                        child:
                            _avatarPath == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFF4CAF50),
                                )
                                : null,
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _fullNameController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${_usernameController.text}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Personal Information Section
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  onChanged: (_) => setState(() {}),
                ),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.email,
                ),
                _buildTextField(
                  controller: _bioController,
                  label: 'Bio',
                  icon: Icons.description,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Contact Information Section
            _buildSectionCard(
              title: 'Contact Information',
              icon: Icons.phone,
              children: [
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                if (widget.profile.phoneVerified)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: const Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Phone verified',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Address Section
            _buildSectionCard(
              title: 'Address',
              icon: Icons.location_on,
              children: [
                _buildTextField(
                  controller: _streetController,
                  label: 'Street Address',
                  icon: Icons.location_on,
                ),
                _buildTextField(
                  controller: _apartmentController,
                  label: 'Apartment/Suite (Optional)',
                  icon: Icons.home,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'State',
                        icon: Icons.map,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _zipController,
                        label: 'Zip Code',
                        icon: Icons.mail,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        icon: Icons.public,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Emergency Contact Section
            _buildSectionCard(
              title: 'Emergency Contact',
              icon: Icons.emergency,
              children: [
                _buildTextField(
                  controller: _emergencyNameController,
                  label: 'Contact Name',
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: _emergencyPhoneController,
                  label: 'Contact Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children
                .expand((child) => [child, const SizedBox(height: 12)])
                .toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
}
