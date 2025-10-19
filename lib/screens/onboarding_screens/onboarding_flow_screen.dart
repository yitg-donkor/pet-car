import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/screens/onboarding_screens/contact_info_step.dart';
import 'package:pet_care/screens/onboarding_screens/location_details_step.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/screens/onboarding_screens/preferences_step.dart';
import 'package:pet_care/screens/onboarding_screens/profile_basics_step.dart';

// Main onboarding coordinator widget
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Store data from each step
  final Map<String, dynamic> _onboardingData = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final userProfileProvider = ref.read(
        userProfileProviderProvider.notifier,
      );

      // Create basic profile first
      await userProfileProvider.createProfile(
        fullName: _onboardingData['fullName'] ?? '',
        username: _onboardingData['username'] ?? '',
        bio: _onboardingData['bio'],
        phoneNumber: _onboardingData['phoneNumber'],
        country: _onboardingData['country'],
        streetAddress: _onboardingData['streetAddress'],
        apartment: _onboardingData['apartment'],
        city: _onboardingData['city'],
        state: _onboardingData['state'],
        zipCode: _onboardingData['zipCode'],
        emergencyContactName: _onboardingData['emergencyContactName'],
        emergencyContactPhone: _onboardingData['emergencyContactPhone'],
        notificationPreferences: _onboardingData['notificationPreferences'],
      );

      // Update avatar if provided
      if (_onboardingData['avatarUrl'] != null) {
        await userProfileProvider.updateProfile(
          avatarUrl: _onboardingData['avatarUrl'],
        );
      }

      if (mounted) {
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/pet_selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                )
                : null,
        title: Text('Step ${_currentPage + 1} of 4'),
        centerTitle: true,
        actions: [
          if (_currentPage < 3)
            TextButton(onPressed: _skipToEnd, child: const Text('Skip')),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(ThemeData()),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                ProfileBasicsStep(
                  initialData: _onboardingData,
                  onNext: (data) {
                    setState(() {
                      _onboardingData.addAll(data);
                    });
                    _nextPage();
                  },
                  onSkip: () {},
                ),
                ContactInfoStep(
                  initialData: _onboardingData,
                  onNext: (data) {
                    setState(() {
                      _onboardingData.addAll(data);
                    });
                    _nextPage();
                  },
                  onSkip: _nextPage,
                ),
                LocationDetailsStep(
                  initialData: _onboardingData,
                  onNext: (data) {
                    setState(() {
                      _onboardingData.addAll(data);
                    });
                    _nextPage();
                  },
                  onSkip: _nextPage,
                ),
                PreferencesStep(
                  initialData: _onboardingData,
                  onComplete: (data) {
                    setState(() {
                      _onboardingData.addAll(data);
                    });
                    _completeOnboarding();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color:
                    index <= _currentPage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Import these in separate files:
// - profile_basics_step.dart
// - contact_info_step.dart
// - location_details_step.dart
// - preferences_step.dart
