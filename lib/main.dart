import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/firebase_options.dart';
import 'package:pet_care/providers/app_state_provider.dart';
import 'package:pet_care/screens/pet_selection_screens/pet_info.dart';
import 'package:pet_care/screens/main_screens/setting_screen.dart';
import 'package:pet_care/screens/onboarding_screens/introduction.dart';
import 'package:pet_care/screens/onboarding_screens/onboarding_flow_screen.dart';
import 'package:pet_care/screens/onboarding_screens/profile_onboarding.dart';
import 'package:pet_care/screens/pet_selection_screens/add_pet.dart';
import 'package:pet_care/screens/pet_selection_screens/editpetscreen.dart';
import 'package:pet_care/screens/pet_selection_screens/pet_selection.dart';
import 'package:pet_care/screens/onboarding_screens/signupscreen.dart';
import 'package:pet_care/services/notification_service.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/theme/theme_manager.dart';
import 'package:pet_care/widgets/onboarding.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'providers/auth_providers.dart';
import 'package:rive/rive.dart' as rive;
import 'screens/main_screens/homescreen.dart';
import 'screens/onboarding_screens/loginscreen.dart';

// Global theme mode - will be set before app runs
AppThemeMode _initialThemeMode = AppThemeMode.system;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  rive.RiveFile.initialize();
  tz.initializeTimeZones();

  // Preload theme from SharedPreferences BEFORE app starts
  try {
    final themeService = ThemePreferencesService();
    _initialThemeMode = await themeService.getThemeMode();
  } catch (e) {
    debugPrint('Could not preload theme: $e, using system default');
    _initialThemeMode = AppThemeMode.system;
  }

  // Initialize Firebase. Unlike the old Supabase.initialize() call, this
  // does NOT need special offline-fallback handling: Firestore keeps working
  // offline once initialized, and Firebase Auth persists the signed-in
  // session locally, so there's no "offline mode" branch needed here.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore's on-device persistence explicitly (on by default for
  // mobile, but being explicit avoids surprises and lets you tune cache size).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) {
          return ThemeNotifier(
            ref.watch(themePreferencesServiceProvider),
            _initialThemeMode,
          );
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeData = ref.watch(currentThemeProvider);

    return MaterialApp(
      theme: themeData,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Pet Care App',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const Signupscreen(),
        '/nada': (context) => const Homescreen(),
        '/introduction': (context) => const IntroductionScreen(),
        '/profile': (context) => const ProfileCreationScreen(),
        '/pet_selection': (context) => const PetSpeciesSelectionScreen(),
        '/onboarding': (context) => const OnboardingFlowScreen(),
        '/home': (context) => const MainNavigation(initialIndex: 0),
        '/reminders': (context) => const MainNavigation(initialIndex: 1),
        '/pet-details': (context) => const PetDetailsScreen(),
        '/add-pet': (context) => const AddPet(species: 'dog'),
        '/edit-pet': (context) => const Editpetscreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

/// Routes based on Firebase Auth state. Firestore reads/writes work offline
/// regardless of this state - this only decides which *screen* to show.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          return const MainNavigation(initialIndex: 0);
        }
        return hasSeenOnboarding
            ? const LoginScreen()
            : const IntroductionScreen();
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        final isNetworkError =
            error.toString().contains('SocketException') ||
            error.toString().contains('network');

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isNetworkError
                        ? 'No Internet Connection'
                        : 'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isNetworkError
                        ? 'Please check your internet connection and try again'
                        : error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(authStateProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
