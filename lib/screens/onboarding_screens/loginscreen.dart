import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = ref.read(authServiceProvider.notifier);

    try {
      print('Starting login process...');
      print('Email: ${_emailController.text.trim()}');

      final response = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('Login response received');
      print('User: ${response.user?.id}');
      print(
        'Session: ${response.session?.accessToken != null ? "Present" : "Null"}',
      );

      if (response.user != null && response.session != null) {
        _showSnackBar('Login successful!');

        // Navigate to main app or home screen
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacementNamed('/home'); // Adjust route as needed
        }
      } else {
        _showSnackBar('Login failed - please try again', isError: true);
      }
    } catch (error, stackTrace) {
      print('Login error: $error');
      print('Stack trace: $stackTrace');

      String errorMessage = 'Login failed. Please try again.';

      // Handle specific error messages from Supabase
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials.';
      } else if (errorString.contains('email not confirmed')) {
        errorMessage = 'Please confirm your email address before signing in.';
      } else if (errorString.contains('too many requests') ||
          errorString.contains('rate limit')) {
        errorMessage =
            'Too many login attempts. Please wait a moment before trying again.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (errorString.contains('user not found')) {
        errorMessage = 'No account found with this email address.';
      }

      _showSnackBar(errorMessage, isError: true);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email address first', isError: true);
      return;
    }

    final authService = ref.read(authServiceProvider.notifier);

    try {
      await authService.resetPassword(_emailController.text.trim());
      _showSnackBar('Password reset email sent! Check your inbox.');
    } catch (error) {
      print('Password reset error: $error');
      _showSnackBar(
        'Failed to send password reset email. Please try again.',
        isError: true,
      );
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
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
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
                    // Basic email validation
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
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : _handleForgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
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
                            : const Text('Login'),
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
                            ).pushReplacementNamed('/signup');
                          },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
