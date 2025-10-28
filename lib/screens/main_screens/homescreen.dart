import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
            label: 'Smart Buddies',
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.clock),
            label: 'My schedule',
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.book),
            label: 'Daily Dairy',
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.lightbulb),
            label: 'Pet Playbook',
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
    final isDark = theme.brightness == Brightness.dark;

    return ClipPath(
      clipper: CloudPuffsClipper(),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [Color(0xFF3D4145), Color.fromARGB(97, 250, 240, 220)]
                    : [
                      Color(0xFFE8B89A), // Richer peach
                      Color(0xFFD09970), // Deeper peach-orange
                      Color(0xFFC88A60), // Even deeper
                    ],
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;

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
                                color:
                                    theme.brightness == Brightness.dark
                                        ? Color(0xFFFFD89C)
                                        : Color(
                                          0xFF7A5843,
                                        ), // Dark brown for light mode
                                fontFamily: GoogleFonts.comicNeue().fontFamily,
                              ),
                              strokeColor:
                                  theme.brightness == Brightness.dark
                                      ? Color(0xFF1C1E21)
                                      : Color(
                                        0xFFFFF8F0,
                                      ), // Light cream outline for light mode
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
                          _buildSectionHeader(
                            theme,
                            'Your Buddies',
                            Icons.pets,
                          ),
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
    final isDark = theme.brightness == Brightness.dark;

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
              return _buildPetAvatar(pets[0].photoUrl, theme);
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.25),
              borderRadius: BorderRadius.circular(12),
              border:
                  isDark
                      ? Border.all(
                        color: Color(0xFF9D7B8A).withOpacity(0.3),
                        width: 1,
                      )
                      : null,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: Icon(
                Icons.auto_awesome,
                color: isDark ? Color(0xFFFFD89C) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatar(String? photoUrl, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(47),
        child:
            photoUrl != null && photoUrl.isNotEmpty
                ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => _buildDefaultAvatarContent(theme),
                )
                : _buildDefaultAvatarContent(theme),
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _buildDefaultAvatarContent(theme),
    );
  }

  Widget _buildDefaultAvatarContent(ThemeData theme) {
    return Icon(Icons.pets, color: Colors.white.withOpacity(0.9), size: 40);
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
      style: theme.textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStyledFontAwesomeIcon({
    required IconData icon,
    required Color fillColor,
    required Color strokeColor,
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stroke layer
        FaIcon(icon, size: size + (strokeWidth * 4), color: strokeColor),
        // Fill layer
        FaIcon(icon, size: size, color: fillColor),
      ],
    );
  }

  Widget _buildQuickStats(
    ThemeData theme,
    List<Pet> pets,
    AsyncValue<List<Reminder>> remindersAsync,
  ) {
    final isDark = theme.brightness == Brightness.dark;
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
            icon: Icons.pets,
            strokecolor:
                isDark
                    ? Color(0xFF1C1E21)
                    : Color(0xFF7A5843), // Dark brown outline
            textcolor:
                isDark ? Color(0xFFFAFAE6) : Color(0xFF2D2520), // Dark text
            label: '${pets.length} Happy Paw',
            color: isDark ? Color(0xFFFFD89C) : Color(0xFFE8B89A), // Warm peach
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            svgPath: 'assets/svgs/blue cloud.svg',
            icon: Icons.check_circle,
            strokecolor: isDark ? Color(0xFF1C1E21) : Color(0xFF2D2520),
            textcolor: isDark ? Color(0xFFFFFBF5) : Colors.white,
            label: '$completedCount Joyful Jumps',
            color: isDark ? Color(0xFF7FA390) : Color(0xFF7FB3C4), // Soft blue
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            svgPath: 'assets/svgs/green cloud.svg',
            icon: FontAwesomeIcons.bell,
            textcolor: isDark ? Color(0xFFFFFBF5) : Colors.white,
            strokecolor: isDark ? Color(0xFF1C1E21) : Color(0xFF2D2520),
            label: '${totalCount - completedCount} Paws-pitive Reminders',
            color: isDark ? Color(0xFFFFD89C) : Color(0xFF8A9B7E), // Sage green
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String svgPath,
    required String label,
    required Color color,
    required Color textcolor,
    required IconData icon,
    required Color strokecolor,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isDark)
            Container(
              width: 150,
              height: 110,
              decoration: BoxDecoration(
                color: Color(0xFF2D3033),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          SvgPicture.asset(
            svgPath,
            width: 160,
            height: 120,
            fit: BoxFit.contain,
            colorFilter:
                isDark
                    ? ColorFilter.mode(
                      Colors.white.withOpacity(0.15),
                      BlendMode.modulate,
                    )
                    : null,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledFontAwesomeIcon(
                icon: icon,
                fillColor: color,
                strokeColor: strokecolor,
                size: 32.0,
                strokeWidth: isDark ? 2.0 : 1.5,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.comicNeue(
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: textcolor,
                    fontWeight: FontWeight.w700,
                  ),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
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
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF2D3033) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              isDark ? Border.all(color: Color(0xFF404448), width: 1) : null,
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 60,
              color: isDark ? Color(0xFF7FA390) : Color(0xFF4CAF50),
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              isDark ? null : Border.all(color: Color(0xFFD0BCAA), width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
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
                color:
                    isDark
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : Color(0xFFFFF8F0),
                border: Border.all(
                  color:
                      isDark
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Color(0xFFD09970),
                  width: 2,
                ),
              ),
              child: Icon(
                _getIconForReminder(reminder.title),
                color: isDark ? Color(0xFFFFD89C) : Color(0xFFD09970),
                size: 32,
              ),
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
            Text(
              DateFormat('h:mm a').format(reminder.reminderDate),
              style: theme.textTheme.bodySmall,
            ),
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
  //         ),t
  //       ),
  //     ),
  //   );
  // }

  IconData _getIconForReminder(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('walk')) return FontAwesomeIcons.personWalking;
    if (titleLower.contains('feed') ||
        titleLower.contains('food') ||
        titleLower.contains('feeding')) {
      return FontAwesomeIcons.bowlFood;
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return FontAwesomeIcons.medkit;
    }
    if (titleLower.contains('vet')) return FontAwesomeIcons.hospital;
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(selectedPetProvider.notifier).selectPet(pet);
        Navigator.pushNamed(context, '/pet-details', arguments: pet);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              isDark ? null : Border.all(color: Color(0xFFD0BCAA), width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
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
                color:
                    isDark
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : Color(0xFFFFF8F0),
                border: Border.all(
                  color:
                      isDark
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Color(0xFFD09970),
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
                                size: 32,
                                color:
                                    isDark
                                        ? Color(0xFFFFD89C)
                                        : Color(0xFFD09970),
                              ),
                        )
                        : Icon(
                          FontAwesomeIcons.paw,
                          size: 32,
                          color: isDark ? Color(0xFFFFD89C) : Color(0xFFD09970),
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
