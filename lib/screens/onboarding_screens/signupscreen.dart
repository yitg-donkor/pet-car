import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';

class Signupscreen extends ConsumerStatefulWidget {
  const Signupscreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupscreenState();
}

class _SignupscreenState extends ConsumerState<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = ref.read(authServiceProvider.notifier);

    try {
      print('Starting signup process...');
      print('Email: ${_emailController.text.trim()}');

      // Sign up the user
      final response = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('Signup response received');
      print('User: ${response.user?.id}');
      print(
        'Session: ${response.session?.accessToken != null ? "Present" : "Null"}',
      );

      if (response.user != null) {
        print('User created successfully: ${response.user!.id}');

        // Create user profile after successful signup
        // ONLY if we have a session (user is auto-confirmed)
        if (response.session != null) {
          try {
            print('Creating profile for user: ${response.user!.id}');

            final userProfileProvider = ref.read(
              userProfileProviderProvider.notifier,
            );

            // Generate username from email
            final username = _emailController.text
                .trim()
                .split('@')[0]
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

            await userProfileProvider.createProfile(
              fullName: _nameController.text.trim(),
              username: username,
            );

            print('✅ Profile created successfully');

            _showSnackBar('Account created successfully!');

            // Navigate to profile setup or home
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/onboarding');
            }
          } catch (profileError) {
            print('❌ Profile creation failed: $profileError');
            _showSnackBar(
              'Account created but profile setup failed. Please update your profile in settings.',
              isError: true,
            );

            // Still navigate to app
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/');
            }
          }
        } else {
          // Email confirmation required
          print('Email confirmation required');
          _showSnackBar(
            'Please check your email to confirm your account before signing in.',
          );

          // Navigate to login screen
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } else {
        print('No user returned from signup');
        _showSnackBar('Signup failed - no user created', isError: true);
      }
    } catch (error, stackTrace) {
      print('Signup error: $error');
      print('Stack trace: $stackTrace');

      String errorMessage = 'Sign up failed. Please try again.';

      // Handle specific error messages from Supabase
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('user already registered') ||
          errorString.contains('already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (errorString.contains('invalid email') ||
          errorString.contains('email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (errorString.contains('password') &&
          errorString.contains('weak')) {
        errorMessage =
            'Password is too weak. Please choose a stronger password.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (errorString.contains('rate limit')) {
        errorMessage =
            'Too many attempts. Please wait a moment before trying again.';
      }

      _showSnackBar(errorMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignUp,
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
                            : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
