import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';
// Adjust the import path as needed

class ProfileCreationScreen extends ConsumerStatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  ConsumerState<ProfileCreationScreen> createState() =>
      _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends ConsumerState<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isCheckingUsername = false;
  String? _usernameError;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    // Pre-populate fields if user data is available
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Set default full name from user metadata if available
      final userMetadata = user.userMetadata;
      if (userMetadata?['full_name'] != null) {
        _fullNameController.text = userMetadata!['full_name'];
      }

      // Set default username from email prefix
      if (user.email != null) {
        final emailPrefix = user.email!.split('@')[0];
        _usernameController.text = emailPrefix.toLowerCase().replaceAll(
          RegExp(r'[^a-zA-Z0-9_]'),
          '',
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to get display name from user or profile
  String _getDisplayName() {
    // First try to get from current user profile
    final profileAsync = ref.watch(userProfileProviderProvider);

    // If profile exists, use the username from profile
    final profile = profileAsync.valueOrNull;
    if (profile != null && profile.username.isNotEmpty) {
      return profile.username;
    }

    // Fallback to current user email or default
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@')[0];
    }

    return 'there'; // Default fallback
  }

  Future<void> _pickAvatar() async {
    if (_isUploadingAvatar) return;

    try {
      setState(() {
        _isUploadingAvatar = true;
        _uploadProgress = 0.0;
      });

      final userProfileProvider = ref.read(
        userProfileProviderProvider.notifier,
      );

      final avatarUrl = await userProfileProvider.showAvatarPickerAndUpload(
        context,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (avatarUrl != null) {
        setState(() {
          _avatarUrl = avatarUrl;
        });
        _showSnackBar('Avatar uploaded successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to upload avatar: $e', isError: true);
    } finally {
      setState(() {
        _isUploadingAvatar = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _removeAvatar() async {
    if (_avatarUrl == null) return;

    try {
      final userProfileProvider = ref.read(
        userProfileProviderProvider.notifier,
      );
      await userProfileProvider.deleteAvatar();

      setState(() {
        _avatarUrl = null;
      });

      _showSnackBar('Avatar removed successfully!');
    } catch (e) {
      _showSnackBar('Failed to remove avatar: $e', isError: true);
    }
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          // Avatar Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child:
                _avatarUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        _avatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                    : const Icon(Icons.person, size: 60, color: Colors.grey),
          ),

          // Upload Progress Indicator
          if (_isUploadingAvatar)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Camera/Edit Button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  _avatarUrl != null ? Icons.edit : Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'upload') {
                    _pickAvatar();
                  } else if (value == 'remove') {
                    _removeAvatar();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.upload),
                            SizedBox(width: 8),
                            Text('Upload Photo'),
                          ],
                        ),
                      ),
                      if (_avatarUrl != null)
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Remove Photo',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) return;

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final response =
          await supabase
              .from('profiles')
              .select('username')
              .eq('username', username.toLowerCase())
              .maybeSingle();

      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          if (response != null) {
            _usernameError = 'Username is already taken';
          } else {
            _usernameError = null;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _usernameError = 'Could not verify username availability';
        });
      }
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null) return;

    final userProfileProvider = ref.read(userProfileProviderProvider.notifier);

    try {
      await userProfileProvider.createProfile(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
      );
      if (_avatarUrl != null) {
        await userProfileProvider.updateProfile(avatarUrl: _avatarUrl);
      }

      _showSnackBar('Profile created successfully!');

      // Navigate to main app or home screen
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/location'); // Adjust route as needed
      }
    } catch (error) {
      print('Profile creation error: $error');

      String errorMessage = 'Failed to create profile. Please try again.';

      final errorString = error.toString().toLowerCase();
      if (errorString.contains('username') && errorString.contains('unique')) {
        errorMessage =
            'Username is already taken. Please choose a different one.';
        setState(() {
          _usernameError = 'Username is already taken';
        });
      } else if (errorString.contains('not authenticated')) {
        errorMessage = 'Authentication error. Please sign in again.';
      }

      _showSnackBar(errorMessage, isError: true);
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }

    final username = value.trim().toLowerCase();

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (username.startsWith('_') || username.endsWith('_')) {
      return 'Username cannot start or end with underscore';
    }

    return _usernameError;
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileProviderProvider);
    final isLoading = userProfileState.isLoading;
    //final currentUser = ref.watch(currentUserProvider);

    // Get the display name to show in welcome message
    final displayName = _getDisplayName();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // // Profile Avatar Section
                // Center(
                //   child: Stack(
                //     children: [
                //       Container(
                //         width: 120,
                //         height: 120,
                //         decoration: BoxDecoration(
                //           shape: BoxShape.circle,
                //           color: Colors.grey[200],
                //           border: Border.all(
                //             color: Colors.grey[300]!,
                //             width: 2,
                //           ),
                //         ),
                //         child: const Icon(
                //           Icons.person,
                //           size: 60,
                //           color: Colors.grey,
                //         ),
                //       ),
                //       Positioned(
                //         bottom: 0,
                //         right: 0,
                //         child: Container(
                //           decoration: BoxDecoration(
                //             color: Theme.of(context).primaryColor,
                //             shape: BoxShape.circle,
                //             border: Border.all(color: Colors.white, width: 2),
                //           ),
                //           child: IconButton(
                //             icon: const Icon(
                //               Icons.camera_alt,
                //               color: Colors.white,
                //               size: 20,
                //             ),
                //             onPressed: () {
                //               // TODO: Implement image picker functionality
                //               _showSnackBar('Photo upload coming soon!');
                //             },
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                _buildAvatarSection(),

                const SizedBox(height: 40),

                // Welcome Text - Now using the helper method
                Text(
                  'Welcome $displayName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s set up your profile to get started.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                    helperText:
                        'Your full name as you\'d like others to see it',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Name must be less than 50 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.alternate_email),
                    helperText:
                        'Choose a unique username (letters, numbers, and underscores only)',
                    suffixIcon:
                        _isCheckingUsername
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : _usernameError == null &&
                                _usernameController.text.length >= 3
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    // Debounced username checking
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (value == _usernameController.text &&
                          value.length >= 3) {
                        _checkUsernameAvailability(value);
                      }
                    });
                  },
                  validator: _validateUsername,
                ),

                const SizedBox(height: 20),

                // Bio Field (Optional)
                TextFormField(
                  controller: _bioController,
                  enabled: !isLoading,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: const InputDecoration(
                    labelText: 'Bio (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_outlined),
                    helperText: 'Tell others a bit about yourself',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value != null && value.length > 150) {
                      return 'Bio must be less than 150 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Create Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        isLoading || _isCheckingUsername
                            ? null
                            : _createProfile,
                    child:
                        isLoading
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
                              'Save and Continue',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms and Privacy
                Text(
                  'By creating a profile, you agree to our Terms of Service and Privacy Policy.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
