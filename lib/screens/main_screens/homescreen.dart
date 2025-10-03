import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/reminder_providers.dart';
import 'package:pet_care/screens/ai_features/ai_navigation_screen.dart';
import 'package:pet_care/screens/main_screens/log.dart';
import 'package:pet_care/screens/main_screens/petscreen.dart';
import 'package:pet_care/screens/main_screens/reminders.dart';
import 'package:pet_care/screens/main_screens/resources.dart';
import 'package:pet_care/providers/pet_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
// Import your screen files here
// import 'homescreen.dart';
// import 'pets_screen.dart';
// import 'reminders_screen.dart';
// import 'log_screen.dart';
// import 'resources_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key, required int initialIndex});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  // Replace these with your actual screen widgets
  final List<Widget> _screens = [
    const Homescreen(), // Your home screen
    const PetsScreen(), // Your pets screen
    const AIDashboardScreen(userId: ''),
    const RemindersScreen(), // Your reminders screen
    const LogScreen(), // Your log screen
    const ResourcesScreen(), // Your resources screen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.pets, 'Pets', 1),
            _buildNavItem(Icons.auto_awesome, "AI", 2),
            _buildNavItem(Icons.notifications, 'Reminders', 3),
            _buildNavItem(Icons.edit_note, 'Log', 4),
            _buildNavItem(Icons.library_books, 'Resources', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Homescreen without bottom navigation (since it's handled by MainNavigation)
class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  Future<void> _handleLogout(WidgetRef ref, BuildContext context) async {
    final authService = ref.read(authServiceProvider.notifier);
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsProvider);
    final todayRemindersAsync = ref.watch(todayRemindersProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Dynamic Header
            _buildHeader(petsAsync, currentUser),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(petsProvider);
                  ref.invalidate(todayRemindersProvider);

                  // Sync reminders
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    final syncService = ref.read(reminderSyncServiceProvider);
                    await syncService.fullSync(user.id);
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Message
                      _buildWelcomeSection(currentUser, petsAsync),

                      const SizedBox(height: 25),

                      // Quick Stats
                      petsAsync.when(
                        data:
                            (pets) =>
                                _buildQuickStats(pets, todayRemindersAsync),
                        loading: () => SizedBox.shrink(),
                        error: (_, __) => SizedBox.shrink(),
                      ),

                      const SizedBox(height: 25),

                      // Today's Reminders Section
                      _buildSectionHeader('Today\'s Reminders', Icons.alarm),
                      const SizedBox(height: 15),

                      todayRemindersAsync.when(
                        data: (reminders) => _buildRemindersSection(reminders),
                        loading: () => _buildLoadingShimmer(),
                        error:
                            (error, _) =>
                                _buildErrorState('Failed to load reminders'),
                      ),

                      const SizedBox(height: 30),

                      // Your Pets Section
                      _buildSectionHeader('Your Pets', Icons.pets),
                      const SizedBox(height: 15),

                      petsAsync.when(
                        data: (pets) => _buildPetsSection(pets),
                        loading: () => _buildLoadingShimmer(),
                        error:
                            (error, _) =>
                                _buildErrorState('Failed to load pets'),
                      ),

                      const SizedBox(height: 30),

                      // Quick Actions
                      _buildQuickActions(),

                      const SizedBox(height: 20),

                      // Debug buttons
                      ElevatedButton(
                        onPressed: () => _handleLogout(ref, context),
                        child: const Text("log out"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/aichat');
                        },
                        child: Text("Go to AI Chat"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<List<Pet>> petsAsync, User? currentUser) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Profile Picture
          petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) {
                return _buildDefaultAvatar();
              }
              return _buildPetAvatar(pets[0].photoUrl);
            },
            loading: () => _buildDefaultAvatar(),
            error: (_, __) => _buildDefaultAvatar(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petsAsync.when(
                    data:
                        (pets) => pets.isNotEmpty ? pets[0].name : 'Add a Pet',
                    loading: () => 'Loading...',
                    error: (_, __) => 'My Pets',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Home Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ai-dashboard');
              },
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatar(String? photoUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child:
            photoUrl != null && photoUrl.isNotEmpty
                ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatarContent(),
                )
                : _buildDefaultAvatarContent(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: _buildDefaultAvatarContent(),
    );
  }

  Widget _buildDefaultAvatarContent() {
    return Icon(Icons.pets, color: Colors.blue.shade400, size: 28);
  }

  Widget _buildWelcomeSection(
    User? currentUser,
    AsyncValue<List<Pet>> petsAsync,
  ) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 4),
        petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) {
              return Text(
                'Start by adding your first pet!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            }
            return Text(
              'You have ${pets.length} ${pets.length == 1 ? 'pet' : 'pets'} to care for today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          },
          loading:
              () => Text(
                'Loading your pets...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          error:
              (_, __) => Text(
                'Welcome back!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    List<Pet> pets,
    AsyncValue<List<Reminder>> remindersAsync,
  ) {
    final completedCount = remindersAsync.when(
      data: (reminders) => reminders.where((r) => r.isCompleted).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final totalCount = remindersAsync.when(
      data: (reminders) => reminders.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.pets,
            count: pets.length.toString(),
            label: 'Pets',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            count: completedCount.toString(),
            label: 'Completed',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions,
            count: (totalCount - completedCount).toString(),
            label: 'Pending',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection(List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders for today!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free time',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Show max 3 reminders on home screen
    final displayReminders = reminders.take(3).toList();
    final remainingCount = reminders.length - 3;

    return Column(
      children: [
        ...displayReminders.map((reminder) => _buildReminderCard(reminder)),
        if (remainingCount > 0) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/reminders'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View $remainingCount More',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final gradientColors = _getGradientForReminder(reminder);
    final icon = _getIconForReminder(reminder.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/reminders'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(reminder.reminderDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!reminder.isCompleted)
                  GestureDetector(
                    onTap: () async {
                      final db = ref.read(reminderDatabaseProvider);
                      await db.toggleCompletion(reminder.id!, true);
                      ref.invalidate(todayRemindersProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marked as complete!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (reminder.isCompleted)
                  Icon(Icons.check_circle, color: Colors.white, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientForReminder(Reminder reminder) {
    final title = reminder.title.toLowerCase();
    if (title.contains('walk')) {
      return [Color(0xFF4CAF50), Color(0xFF81C784)];
    } else if (title.contains('feed') || title.contains('food')) {
      return [Color(0xFF2196F3), Color(0xFF64B5F6)];
    } else if (title.contains('medication') || title.contains('medicine')) {
      return [Color(0xFFE53E3E), Color(0xFF9C27B0)];
    } else if (title.contains('vet')) {
      return [Color(0xFFFF5722), Color(0xFFFF7043)];
    } else if (title.contains('groom')) {
      return [Color(0xFF9C27B0), Color(0xFFBA68C8)];
    }
    return [Color(0xFF3F51B5), Color(0xFF5C6BC0)];
  }

  IconData _getIconForReminder(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('walk')) return Icons.pets;
    if (titleLower.contains('feed') || titleLower.contains('food')) {
      return Icons.restaurant;
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return Icons.medication;
    }
    if (titleLower.contains('vet')) return Icons.local_hospital;
    if (titleLower.contains('groom')) return Icons.content_cut;
    if (titleLower.contains('clean')) return Icons.cleaning_services;
    return Icons.notifications;
  }

  Widget _buildPetsSection(List<Pet> pets) {
    if (pets.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/add-pet'),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline, size: 60, color: Colors.blue[400]),
              const SizedBox(height: 16),
              Text(
                'Add Your First Pet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return _buildPetCard(pet);
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedPetProvider.notifier).selectPet(pet);
        print('Selected pet: ${pet.name}'); // Debug print
        Navigator.pushNamed(context, '/pet-details', arguments: pet);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: ClipOval(
                child:
                    pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                        ? Image.network(
                          pet.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.pets,
                                size: 40,
                                color: Colors.blue[300],
                              ),
                        )
                        : Icon(Icons.pets, size: 40, color: Colors.blue[300]),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                pet.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pet.species,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions', Icons.flash_on),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Reminder',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/reminders'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.pets,
                label: 'Add Pet',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/add-pet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }
}
