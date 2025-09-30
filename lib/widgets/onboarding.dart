import 'dart:async';

import 'package:flutter/material.dart' hide Image;
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

// Simplified and working Rive animation widget

import 'package:flutter/material.dart';

class AnimatedTextCycle extends StatefulWidget {
  final List<String> texts;
  final Duration switchDuration;
  final Duration fadeDuration;
  final TextStyle? textStyle;

  const AnimatedTextCycle({
    super.key,
    required this.texts,
    this.switchDuration = const Duration(seconds: 3),
    this.fadeDuration = const Duration(milliseconds: 500),
    this.textStyle,
  });

  @override
  State<AnimatedTextCycle> createState() => _AnimatedTextCycleState();
}

class _AnimatedTextCycleState extends State<AnimatedTextCycle> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.switchDuration, (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      child: Text(
        widget.texts[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: widget.textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class RiveAnimationWidget extends StatefulWidget {
  final String assetPath;
  final String? animationName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  const RiveAnimationWidget({
    super.key,
    required this.assetPath,
    this.animationName,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  State<RiveAnimationWidget> createState() => _RiveAnimationWidgetState();
}

class _RiveAnimationWidgetState extends State<RiveAnimationWidget> {
  RiveAnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animationName != null) {
      _controller = SimpleAnimation(widget.animationName!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 300,
      height: widget.height ?? 300,
      child: RiveAnimation.asset(
        widget.assetPath,
        controllers: _controller != null ? [_controller!] : [],
        fit: widget.fit,
        alignment: widget.alignment,
        onInit: (artboard) {
          // Animation is ready
          debugPrint('Rive animation loaded: ${widget.assetPath}');
        },
        placeHolder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// Alternative: Basic Rive widget that just plays all animations
class SimpleRiveWidget extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SimpleRiveWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 300,
      height: height ?? 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: RiveAnimation.asset(
        assetPath,
        fit: fit,
        placeHolder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class OnboardingWidget extends ConsumerWidget {
  final List<OnboardingPageData> pages;
  final VoidCallback onComplete;
  final bool showSkip;
  final String? skipText;
  final String? doneText;
  final String? nextText;

  const OnboardingWidget({
    super.key,
    required this.pages,
    required this.onComplete,
    this.showSkip = true,
    this.skipText,
    this.doneText,
    this.nextText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntroductionScreen(
      pages: pages.map((page) => _buildPage(page, context)).toList(),
      onDone: onComplete,
      onSkip: showSkip ? onComplete : null,
      showSkipButton: false,
      skip: Text(
        skipText ?? 'Skip',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      next: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
      done: Text(
        doneText ?? 'Done',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(8.0),
        activeSize: const Size(18.0, 8.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        activeColor: Theme.of(context).primaryColor,
        color: Colors.grey.shade300,
      ),
      curve: Curves.easeInOut,
      controlsPadding: const EdgeInsets.all(16),
    );
  }

  PageViewModel _buildPage(OnboardingPageData page, BuildContext context) {
    return PageViewModel(
      title: page.title,
      bodyWidget:
          page.customDescription != null
              ? page.customDescription!(context)
              : Text(
                page.description,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

      image: Container(
        padding: const EdgeInsets.all(16),
        child: SimpleRiveWidget(
          assetPath: page.riveAsset,
          width: 280,
          height: 280,
          fit: BoxFit.contain,
        ),
      ),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.grey.shade600,
          height: 1.4,
        ),
        imagePadding: const EdgeInsets.only(top: 20, bottom: 20),
        pageColor: page.backgroundColor ?? Colors.white,
        imageFlex: page.imageFlex ?? 3,
        bodyFlex: page.bodyFlex ?? 2,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        contentMargin: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String riveAsset;
  final String? riveAnimation;
  final Color? backgroundColor;
  final int? imageFlex;
  final int? bodyFlex;
  final Widget Function(BuildContext)? customDescription;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.riveAsset,
    this.riveAnimation,
    this.backgroundColor,
    this.imageFlex,
    this.bodyFlex,
    this.customDescription,
  });
}

// Provider for onboarding state management
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);

// Updated pages with working asset paths
final List<OnboardingPageData> petCareOnboardingPages = [
  OnboardingPageData(
    title: 'Welcome to Pet Pal',
    description:
        'helping you take the best care of your furry (or feathered) friend!',
    riveAsset: 'assets/animations/cat.riv', // Make sure this path exists
    riveAnimation: 'play',
  ),
  OnboardingPageData(
    title: 'Core Benefits',
    description: '', // We'll handle the description differently
    riveAsset: 'assets/animations/dog_walking.riv',
    riveAnimation: 'walk',
    // Custom builder for the description
    customDescription:
        (context) => AnimatedTextCycle(
          texts: const [
            'Track vaccinations, vet visits, and daily routines with ease. 💉',
            'Store medical records in one place 📋',
            'Schedule vet appointments easily 🏥',
            'Monitor medications and dosages 💊',
          ],
          textStyle: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
  ),
  OnboardingPageData(
    title: 'Set Reminders',
    description:
        'Never miss important pet care tasks with customizable reminders.',
    riveAsset:
        'assets/animations/walking_bird.riv', // Make sure this path exists
    riveAnimation: 'walk',
  ),
];
