import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/firebase_options.dart';
import 'package:pet_care/screens/main_screens/pet_info.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'providers/auth_providers.dart';
import 'package:rive/rive.dart' as rive;
import 'screens/main_screens/homescreen.dart';
import 'screens/onboarding_screens/loginscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  rive.RiveFile.initialize();

  tz.initializeTimeZones();

  await Supabase.initialize(
    url: 'https://moaiifmgrbbcmnubgxpm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYWlpZm1ncmJiY21udWJneHBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMzA0MjMsImV4cCI6MjA3MzgwNjQyM30.WLfpehs4MY8wTzBepr5qhTeV-DiZwIT2Imy_WuQxueU',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize theme from user profile
    ref.watch(initializeThemeProvider);

    // Watch current theme
    final themeMode = ref.watch(themeProvider);
    final themeData = ref.watch(currentThemeProvider);

    return MaterialApp(
      // Theme Configuration
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
        '/nada': (context) => Homescreen(),
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

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    return authStateAsync.when(
      data: (authState) {
        final hasSession = authState.session != null;

        if (hasSession) {
          return MainNavigation(initialIndex: 0);
        } else {
          return hasSeenOnboarding
              ? const LoginScreen()
              : const IntroductionScreen();
        }
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(authStateProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
