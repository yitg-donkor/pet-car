import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/firebase_options.dart';
import 'package:pet_care/local_db/sqflite_db.dart';
import 'package:pet_care/providers/app_state_provider.dart';
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

// Global theme mode - will be set before app runs
AppThemeMode _initialThemeMode = AppThemeMode.system;
bool _isOfflineMode = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  rive.RiveFile.initialize();

  tz.initializeTimeZones();

  // Preload theme from SharedPreferences BEFORE app starts
  try {
    final themeService = ThemePreferencesService();
    _initialThemeMode = await themeService.getThemeMode();
    print('✅ Theme preloaded: ${_initialThemeMode.name}');
  } catch (e) {
    print('⚠️ Could not preload theme: $e, using system default');
    _initialThemeMode = AppThemeMode.system;
  }

  // Initialize Supabase with offline handling
  try {
    await Supabase.initialize(
      url: 'https://moaiifmgrbbcmnubgxpm.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYWlpZm1ncmJiY21udWJneHBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMzA0MjMsImV4cCI6MjA3MzgwNjQyM30.WLfpehs4MY8wTzBepr5qhTeV-DiZwIT2Imy_WuQxueU',
    );
    print('✅ Supabase initialized successfully');
    _isOfflineMode = false;
  } catch (e) {
    print('⚠️ Supabase initialization failed (likely offline): $e');
    print('📱 Running in OFFLINE MODE');
    _isOfflineMode = true;
    // Continue without Supabase - app will work with local database only
  }

  // Initialize Firebase (also handle offline gracefully)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
  }

  // Initialize notifications
  try {
    await NotificationService().initialize();
    print('✅ Notification service initialized');
  } catch (e) {
    print('⚠️ Notification service failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override the initial theme mode with preloaded value
        themeProvider.overrideWith((ref) {
          return ThemeNotifier(
            ref.watch(themePreferencesServiceProvider),
            _initialThemeMode,
          );
        }),
        // Provide offline mode state
        isOfflineModeProvider.overrideWith((ref) => _isOfflineMode),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current theme (will be preloaded, no hesitation)
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

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineModeProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    // OFFLINE MODE: Skip auth, go straight to app
    if (isOffline) {
      return OfflineModeWrapper(hasSeenOnboarding: hasSeenOnboarding);
    }

    // ONLINE MODE: Normal auth flow
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        final hasSession = authState.session != null;

        if (hasSession) {
          return const MainNavigation(initialIndex: 0);
        } else {
          return hasSeenOnboarding
              ? const LoginScreen()
              : const IntroductionScreen();
        }
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) {
        // Check if it's a network error
        final isNetworkError =
            error.toString().contains('SocketException') ||
            error.toString().contains('Failed host lookup') ||
            error.toString().contains('ClientException');

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
                    onPressed: () {
                      ref.invalidate(authStateProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  if (isNetworkError) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Switch to offline mode
                        ref.read(isOfflineModeProvider.notifier).state = true;
                      },
                      icon: const Icon(Icons.offline_bolt),
                      label: const Text('Continue Offline'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Offline Mode Wrapper
class OfflineModeWrapper extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const OfflineModeWrapper({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In offline mode, check local database for existing data
    return FutureBuilder<bool>(
      future: _hasLocalData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasLocalData = snapshot.data ?? false;

        if (hasLocalData) {
          // User has local data, go to main app
          return const MainNavigation(initialIndex: 0);
        } else {
          // No local data, show onboarding
          return hasSeenOnboarding
              ? const OfflineNoticeScreen()
              : const IntroductionScreen();
        }
      },
    );
  }

  Future<bool> _hasLocalData() async {
    try {
      final db = await LocalDatabaseService.instance.database;
      final result = await db.query('pets', limit: 1);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

// Offline Notice Screen
class OfflineNoticeScreen extends StatelessWidget {
  const OfflineNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.offline_bolt, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Offline Mode',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'You\'re currently offline. Some features may be limited.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Continue to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
