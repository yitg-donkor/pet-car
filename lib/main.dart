import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/firebase_options.dart';
import 'package:pet_care/screens/ai_features/aichatscreen.dart';
import 'package:pet_care/screens/main_screens/pet_info.dart';
import 'package:pet_care/screens/onboarding_screens/introduction.dart';
import 'package:pet_care/screens/onboarding_screens/onboarding_flow_screen.dart';
import 'package:pet_care/screens/onboarding_screens/profile_onboarding.dart';
import 'package:pet_care/screens/pet_selection_screens/add_pet.dart';
import 'package:pet_care/screens/pet_selection_screens/editpetscreen.dart';
import 'package:pet_care/screens/pet_selection_screens/pet_selection.dart';
import 'package:pet_care/screens/onboarding_screens/signupscreen.dart';
import 'package:pet_care/widgets/onboarding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_providers.dart';
import 'package:rive/rive.dart' as rive;
import 'screens/main_screens/homescreen.dart';
import 'screens/onboarding_screens/loginscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  rive.RiveFile.initialize();

  await Supabase.initialize(
    url: 'https://moaiifmgrbbcmnubgxpm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vYWlpZm1ncmJiY21udWJneHBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMzA0MjMsImV4cCI6MjA3MzgwNjQyM30.WLfpehs4MY8wTzBepr5qhTeV-DiZwIT2Imy_WuQxueU',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Care App',
      initialRoute: '/', // Start with AuthWrapper
      routes: {
        '/': (context) => const AuthWrapper(), // Move AuthWrapper to routes
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
        '/aichat':
            (context) => const AIVetChatScreen(
              petName: 'Buddy',
              species: 'dog',
            ), // Example route for AI chat screen
      },
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Remove the home parameter completely
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
          // Show onboarding if not seen, otherwise go to login
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
