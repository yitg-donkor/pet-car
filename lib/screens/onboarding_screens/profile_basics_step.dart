import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';

class ProfileBasicsStep extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onSkip;

  const ProfileBasicsStep({
    super.key,
    required this.initialData,
    required this.onNext,
    required this.onSkip,
  });

  @override
  ConsumerState<ProfileBasicsStep> createState() => _ProfileBasicsStepState();
}

class _ProfileBasicsStepState extends ConsumerState<ProfileBasicsStep> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  // final _streetAddressController = TextEditingController();
  // final _apartmentController = TextEditingController();
  // final _cityController = TextEditingController();
  // final _stateController = TextEditingController();
  // final _zipCodeController = TextEditingController();

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
    // _streetAddressController.dispose();
    // _apartmentController.dispose();
    // _cityController.dispose();
    // _stateController.dispose();
    // _zipCodeController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _fullNameController.text = widget.initialData['fullName'] ?? '';
    _usernameController.text = widget.initialData['username'] ?? '';
    _bioController.text = widget.initialData['bio'] ?? '';
    _avatarUrl = widget.initialData['avatarUrl'];

    if (_fullNameController.text.isEmpty || _usernameController.text.isEmpty) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        if (_fullNameController.text.isEmpty) {
          final userMetadata = user.userMetadata;
          if (userMetadata?['full_name'] != null) {
            _fullNameController.text = userMetadata!['full_name'];
          }
        }

        if (_usernameController.text.isEmpty && user.email != null) {
          final emailPrefix = user.email!.split('@')[0];
          _usernameController.text = emailPrefix.toLowerCase().replaceAll(
            RegExp(r'[^a-zA-Z0-9_]'),
            '',
          );
        }
      }
    }
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

  // String? _validateZipCode(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return 'Please enter ZIP code';
  //   }
  //   if (value.length != 5) {
  //     return 'ZIP code must be 5 digits';
  //   }
  //   return null;
  // }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null) return;

    widget.onNext({
      'fullName': _fullNameController.text.trim(),
      'username': _usernameController.text.trim().toLowerCase(),
      'bio':
          _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : null,
      'avatarUrl': _avatarUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      // decoration: BoxDecoration(color: Colors.red),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                    ),
                    if (_isUploadingAvatar)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: _uploadProgress,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
              ),

              const SizedBox(height: 32),

              Text(
                'Create Your Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s start with the basics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 32),

              TextFormField(
                style: TextStyle(color: theme.colorScheme.onPrimary),
                controller: _fullNameController,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a full name';
                  }

                  final username = value.trim().toLowerCase();

                  if (username.length < 3) {
                    return 'Username must be at least 3 characters';
                  }

                  // if (username.length > 20) {
                  //   return 'Username must be less than 20 characters';
                  // }

                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name can only contain letters and spaces';
                  }

                  if (username.startsWith('_') || username.endsWith('_')) {
                    return 'Username cannot start or end with underscore';
                  }

                  return _usernameError;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                style: TextStyle(color: theme.colorScheme.onPrimary),
                controller: _usernameController,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                  labelText: 'Username',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.alternate_email),
                  helperText: 'Choose a unique username',
                  suffixIcon:
                      _isCheckingUsername
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : _usernameError == null &&
                              _usernameController.text.length >= 3
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                onChanged: (value) {
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

              TextFormField(
                style: TextStyle(color: theme.colorScheme.onPrimary),
                controller: _bioController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                  labelText: 'Bio (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                  helperText: 'Tell others about yourself',
                  alignLabelWithHint: true,
                ),
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
      ),
    );
  }
}

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
