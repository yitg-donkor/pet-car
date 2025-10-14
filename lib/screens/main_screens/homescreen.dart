import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';

import 'package:pet_care/screens/ai_features/ai_navigation_screen.dart';
import 'package:pet_care/screens/main_screens/log.dart';
import 'package:pet_care/screens/main_screens/reminders.dart';
import 'package:pet_care/screens/main_screens/resources.dart';

import 'package:pet_care/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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

            _buildNavItem(Icons.auto_awesome, "AI", 1),
            _buildNavItem(Icons.notifications, 'Reminders', 2),
            _buildNavItem(Icons.edit_note, 'Log', 3),
            _buildNavItem(Icons.library_books, 'Resources', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected ? theme.colorScheme.primaryContainer : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? theme.colorScheme.primaryContainer : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    final userProfile = await ref.read(userProfileProviderProvider.future);
    if (userProfile != null) {
      notificationService.setPreferences(userProfile.notificationPreferences);
    }
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Force a refresh of pets from local DB
      ref.invalidate(petsOfflineProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final petsAsync = ref.watch(petsOfflineProvider);
    final todayRemindersAsync = ref.watch(todayRemindersProvider);
    final currentUser = ref.watch(currentUserProvider);

    ref.listen<AsyncValue<List<Pet>>>(petsOfflineProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          print('Error loading pets: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading pets: $error'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, petsAsync, currentUser),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(petsOfflineProvider);
                  ref.invalidate(todayRemindersProvider);

                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    final syncService = ref.read(unifiedSyncServiceProvider);
                    await syncService.fullSync(user.id);
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(theme, currentUser, petsAsync),
                      const SizedBox(height: 25),
                      petsAsync.when(
                        data:
                            (pets) => _buildQuickStats(
                              theme,
                              pets,
                              todayRemindersAsync,
                            ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 25),
                      _buildSectionHeader(
                        theme,
                        'Today\'s Reminders',
                        Icons.alarm,
                      ),
                      const SizedBox(height: 15),
                      todayRemindersAsync.when(
                        data:
                            (reminders) =>
                                _buildRemindersSection(theme, reminders),
                        loading: () => _buildLoadingShimmer(theme),
                        error:
                            (error, _) => _buildErrorState(
                              theme,
                              'Failed to load reminders',
                            ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader(theme, 'Your Pets', Icons.pets),
                      const SizedBox(height: 15),
                      petsAsync.when(
                        data: (pets) => _buildPetsSection(theme, pets),
                        loading: () => _buildLoadingShimmer(theme),
                        error:
                            (error, _) =>
                                _buildErrorState(theme, 'Failed to load pets'),
                      ),
                      const SizedBox(height: 30),
                      _buildQuickActions(theme),
                      const SizedBox(height: 20),
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

  Widget _buildHeader(
    ThemeData theme,
    AsyncValue<List<Pet>> petsAsync,
    User? currentUser,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) {
                return _buildDefaultAvatar(theme);
              }
              return _buildPetAvatar(pets[0].photoUrl);
            },
            loading: () => _buildDefaultAvatar(theme),
            error: (_, __) => _buildDefaultAvatar(theme),
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
                  style: theme.textTheme.headlineLarge?.copyWith(
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
                Navigator.pushNamed(context, '/settings');
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
            offset: const Offset(0, 2),
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

  Widget _buildDefaultAvatar(ThemeData theme) {
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
    ThemeData theme,
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
        Text(
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) {
              return Text(
                'Start by adding your first pet!',
                style: theme.textTheme.headlineMedium,
              );
            }
            return Text(
              'You have ${pets.length} ${pets.length == 1 ? 'pet' : 'pets'} to care for today',
              style: theme.textTheme.headlineSmall,
            );
          },
          loading:
              () => Text(
                'Loading your pets...',
                style: theme.textTheme.headlineSmall,
              ),
          error:
              (_, __) =>
                  Text('Welcome back!', style: theme.textTheme.headlineSmall),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    ThemeData theme,
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
            theme: theme,
            icon: Icons.pets,
            count: pets.length.toString(),
            label: 'Pets',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            icon: Icons.check_circle,
            count: completedCount.toString(),
            label: 'Completed',
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            icon: Icons.pending_actions,
            count: (totalCount - completedCount).toString(),
            label: 'Pending',
            color: Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count,
            style: theme.textTheme.headlineMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.headlineLarge),
      ],
    );
  }

  Widget _buildRemindersSection(ThemeData theme, List<Reminder> reminders) {
    final activeReminders = reminders.where((r) => !r.isCompleted).toList();
    if (activeReminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 60,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            Text('No reminders for today!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Enjoy your free time', style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    final displayReminders = activeReminders.take(3).toList();
    final remainingCount = activeReminders.length - 3;

    return Column(
      children: [
        ...displayReminders.map(
          (reminder) => _buildReminderCard(theme, reminder),
        ),
        if (remainingCount > 0) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/reminders'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(25),
                color: theme.colorScheme.surface,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View $remainingCount More',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderCard(ThemeData theme, Reminder reminder) {
    final gradientColors = _getGradientForReminder(reminder);
    final icon = _getIconForReminder(reminder.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.outline,
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        // style: TextStyle(
                        //   color: Colors.white,
                        //   fontSize: 16,
                        //   fontWeight: FontWeight.w600,
                        //   decoration:
                        //       reminder.isCompleted
                        //           ? TextDecoration.lineThrough
                        //           : null,
                        // ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration:
                              reminder.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('h:mm a').format(reminder.reminderDate),
                        // style: TextStyle(
                        //   color: Colors.white.withOpacity(0.9),
                        //   fontSize: 14,
                        // ),
                        style: theme.textTheme.bodyMedium,
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
                        const SnackBar(
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
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Complete',
                        // style: TextStyle(
                        //   color: Colors.white,
                        //   fontSize: 12,
                        //   fontWeight: FontWeight.w600,
                        // ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                if (reminder.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.white, size: 32),
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
      return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
    } else if (title.contains('feed') || title.contains('food')) {
      return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
    } else if (title.contains('medication') || title.contains('medicine')) {
      return [const Color(0xFFE53E3E), const Color(0xFF9C27B0)];
    } else if (title.contains('vet')) {
      return [const Color(0xFFFF5722), const Color(0xFFFF7043)];
    } else if (title.contains('groom')) {
      return [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
    }
    return [const Color(0xFF3F51B5), const Color(0xFF5C6BC0)];
  }

  IconData _getIconForReminder(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('walk')) return Icons.pets;
    if (titleLower.contains('feed') ||
        titleLower.contains('food') ||
        titleLower.contains('feeding')) {
      return Icons.restaurant_outlined;
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return Icons.medication;
    }
    if (titleLower.contains('vet')) return Icons.local_hospital_outlined;
    if (titleLower.contains('groom')) return Icons.content_cut_outlined;
    if (titleLower.contains('clean')) return Icons.cleaning_services;
    return Icons.notifications_outlined;
  }

  Widget _buildPetsSection(ThemeData theme, List<Pet> pets) {
    if (pets.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/add-pet'),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 60,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Add Your First Pet', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Tap to get started', style: theme.textTheme.bodySmall),
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
          return _buildPetCard(theme, pet);
        },
      ),
    );
  }

  Widget _buildPetCard(ThemeData theme, Pet pet) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedPetProvider.notifier).selectPet(pet);
        Navigator.pushNamed(context, '/pet-details', arguments: pet);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 2,
                ),
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
                                color: theme.colorScheme.primary,
                              ),
                        )
                        : Icon(
                          Icons.pets,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                pet.name,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Text(pet.species, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Quick Actions', Icons.flash_on),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                theme: theme,
                icon: Icons.add,
                label: 'Add Reminder',
                color: theme.colorScheme.secondary,
                onTap: () => Navigator.pushNamed(context, '/reminders'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                theme: theme,
                icon: Icons.pets,
                label: 'Add Pet',
                color: theme.colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, '/add-pet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
