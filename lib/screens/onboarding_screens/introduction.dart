import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/widgets/onboarding.dart';

class IntroductionScreen extends ConsumerStatefulWidget {
  const IntroductionScreen({super.key});

  @override
  ConsumerState<IntroductionScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OnboardingWidget(
          pages: petCareOnboardingPages,
          onComplete: () {
            debugPrint('Onboarding completed');
            ref.read(hasSeenOnboardingProvider.notifier).state = true;

            // Check if the route exists before navigating
            if (Navigator.canPop(context)) {
              Navigator.of(context).pushReplacementNamed('/signup');
            } else {
              // Fallback navigation - replace with your home screen import
              debugPrint('Route /home not found, implement direct navigation');
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => HomeScreen()),
              // );
            }
          },
        ),
      ),
    );
  }
}
