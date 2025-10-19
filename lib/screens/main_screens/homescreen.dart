import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/widgets/widgets.dart';
import 'package:pet_care/screens/ai_features/ai_navigation_screen.dart';
import 'package:pet_care/screens/main_screens/log.dart';
import 'package:pet_care/screens/main_screens/reminders.dart';
import 'package:pet_care/screens/main_screens/resources.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<Widget> _screens = [
    const Homescreen(),
    const AIDashboardScreen(userId: ''),
    const RemindersScreen(),
    const LogScreen(),
    const ResourcesScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_note),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.library_books),
            label: 'Resources',
          ),
        ],
      ),
    );
  }
}

// 8. CLOUD PUFFS - Rounded bumpy waves

class StrokeText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color strokeColor;
  final double strokeWidth;

  const StrokeText({
    super.key,
    required this.text,
    required this.textStyle,
    this.strokeColor = Colors.white,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke (outline) layer
        Text(
          text,
          style: textStyle.copyWith(
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor,
          ),
        ),
        // Fill layer
        Text(text, style: textStyle),
      ],
    );
  }
}

class CloudPuffsClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.65);

    // Puffy cloud 1
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.55,
      size.width * 0.2,
      size.height * 0.65,
    );

    // Puffy cloud 2
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.7,
    );

    // Puffy cloud 3
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.75,
      size.width * 0.6,
      size.height * 0.68,
    );

    // Puffy cloud 4
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.62,
      size.width * 0.85,
      size.height * 0.7,
    );

    path.quadraticBezierTo(
      size.width * 0.92,
      size.height * 0.75,
      size.width,
      size.height * 0.72,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PetDashboardBackground extends StatelessWidget {
  const PetDashboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipPath(
      clipper: CloudPuffsClipper(),
      child: Container(
        height: 400,
        decoration: BoxDecoration(color: theme.colorScheme.primary),
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
      body: Stack(
        children: [
          // Background - placed first so it's behind everything
          const PetDashboardBackground(),

          // Main content - placed on top of background
          SafeArea(
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
                        final syncService = ref.read(
                          unifiedSyncServiceProvider,
                        );
                        await syncService.fullSync(user.id);
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Center(
                            child: StrokeText(
                              text: 'Paws-itively Planned!',
                              textStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFF4E6), // Brown fill
                                fontFamily:
                                    GoogleFonts.comicNeue()
                                        .fontFamily, // Rounded playful font
                              ),
                              strokeColor: Color(
                                0xFF8B6B47,
                              ), // Light cream outline
                              strokeWidth: 6.0,
                            ),
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
                                (error, _) => _buildErrorState(
                                  theme,
                                  'Failed to load pets',
                                ),
                          ),
                          const SizedBox(height: 30),
                          _buildQuickActions(theme),
                          const SizedBox(height: 20),
                          universalButton(
                            context,
                            ref,
                            label: "hit me",
                            onpressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
                _greetingCard(theme),
                const SizedBox(height: 2),
                Text(
                  'Buddy!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Color(0xFFFFFBF5),
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

  Widget _greetingCard(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    return Text(
      greeting,
      style: theme.textTheme.headlineLarge?.copyWith(color: Color(0xFFFFFBF5)),
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
            svgPath: 'assets/svgs/beige_cloud.svg',
            // icon: Icons.pets,
            icon: Icons.pets,
            label: '${pets.length} Happy Paw',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            svgPath: 'assets/svgs/blue cloud.svg',
            // icon: Icons.check_circle,
            icon: Icons.check_circle,
            label: '$completedCount Joyful Jumps',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            svgPath: 'assets/svgs/green cloud.svg',
            // icon: Icons.pending_actions,
            icon: Icons.pending_actions,

            label: '${totalCount - completedCount} Paws-pitive Reminders',
            color: Color(0xFFFAFAF0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String svgPath, // e.g. 'assets/cloud.svg'

    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(svgPath, width: 160, height: 120, fit: BoxFit.contain),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.comicNeue(
                textStyle: theme.textTheme.bodySmall,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ],
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

    final displayReminders = activeReminders.take(3);
    final remainingCount = activeReminders.length - 3;

    // return Column(
    //   children: [
    //     ...displayReminders.map(
    //       (reminder) => _buildReminderCard(theme, reminder),
    //     ),
    //   ],
    // );

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayReminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(theme, reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(ThemeData theme, Reminder reminder) {
    return GestureDetector(
      onTap: () {},
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
              child: ClipOval(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                reminder.title,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Text(DateFormat('h:mm a').format(reminder.reminderDate)),
          ],
        ),
      ),
    );
  }

  // Widget _buildReminderCard(ThemeData theme, Reminder reminder) {
  //   final icon = _getIconForReminder(reminder.title);

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: theme.colorScheme.surface,

  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: theme.colorScheme.outline,
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: () => Navigator.pushNamed(context, '/reminders'),
  //         borderRadius: BorderRadius.circular(20),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Icon(
  //                   icon,
  //                   color: theme.colorScheme.onSurface,
  //                   size: 24,
  //                 ),
  //               ),
  //               const SizedBox(width: 15),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       reminder.title,
  //                       // style: TextStyle(
  //                       //   color: Colors.white,
  //                       //   fontSize: 16,
  //                       //   fontWeight: FontWeight.w600,
  //                       //   decoration:
  //                       //       reminder.isCompleted
  //                       //           ? TextDecoration.lineThrough
  //                       //           : null,
  //                       // ),
  //                       style: theme.textTheme.titleMedium?.copyWith(
  //                         decoration:
  //                             reminder.isCompleted
  //                                 ? TextDecoration.lineThrough
  //                                 : null,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 2),
  //                     Text(
  //                       DateFormat('h:mm a').format(reminder.reminderDate),
  //
  //                       style: theme.textTheme.bodyMedium,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (!reminder.isCompleted)
  //                 GestureDetector(
  //                   onTap: () async {
  //                     final db = ref.read(reminderDatabaseProvider);
  //                     await db.toggleCompletion(reminder.id!, true);
  //                     ref.invalidate(todayRemindersProvider);

  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text('Marked as complete!'),
  //                         duration: Duration(seconds: 2),
  //                       ),
  //                     );
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 16,
  //                       vertical: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: theme.colorScheme.outline,
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     child: Text(
  //                       'Complete',
  //                       // style: TextStyle(
  //                       //   color: Colors.white,
  //                       //   fontSize: 12,
  //                       //   fontWeight: FontWeight.w600,
  //                       // ),
  //                       style: theme.textTheme.bodySmall,
  //                     ),
  //                   ),
  //                 ),
  //               if (reminder.isCompleted)
  //                 const Icon(Icons.check_circle, color: Colors.white, size: 32),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
