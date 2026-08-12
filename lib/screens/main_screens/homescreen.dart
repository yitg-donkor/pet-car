// screens/main_screens/homescreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/firestore_providers.dart';
import 'package:pet_care/screens/ai_features/ai_navigation_screen.dart';
import 'package:pet_care/screens/main_screens/log.dart';
import 'package:pet_care/screens/main_screens/reminders.dart';
import 'package:pet_care/screens/main_screens/resources.dart';
import 'package:pet_care/screens/pet_selection_screens/add_pet.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/widgets/widgets.dart';

// ============================================
// MAIN NAVIGATION SHELL
// ============================================

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  static const _screens = [
    Homescreen(),
    AIDashboardScreen(),
    RemindersScreen(),
    LogScreen(),
    ResourcesScreen(),
  ];

  static const _navItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.auto_awesome_rounded, label: 'AI'),
    (icon: Icons.favorite_rounded, label: 'Care'),
    (icon: Icons.edit_note_rounded, label: 'Log'),
    (icon: Icons.info_rounded, label: 'Info'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentTabIndexProvider.notifier).state = widget.initialIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(context, currentIndex),
    );
  }

  Widget _buildNavBar(BuildContext context, int currentIndex) {
    final sky = SkyColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: sky.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final selected = index == currentIndex;
              final color = selected ? sky.header : sky.textSecondary;

              return Expanded(
                child: InkWell(
                  onTap:
                      () =>
                          ref.read(currentTabIndexProvider.notifier).state =
                              index,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected ? sky.header : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================
// HOME SCREEN
// ============================================

class Homescreen extends ConsumerWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sky = SkyColors.of(context);
    return Scaffold(
      body: RefreshIndicator(
        color: sky.header,
        onRefresh: () async {
          ref.invalidate(petsControllerProvider);
          ref.invalidate(todayRemindersProvider);
          ref.invalidate(weeklyStatsProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            _HomeHeader(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MyPetsSection(),
                  SizedBox(height: 24),
                  _AiAssistantPromo(),
                  SizedBox(height: 24),
                  _TodaysCareSection(),
                  SizedBox(height: 24),
                  _ThisWeekSection(),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Header ----------

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final petsAsync = ref.watch(petsControllerProvider);
    final remindersAsync = ref.watch(todayRemindersProvider);
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    final firstName = profileAsync.maybeWhen(
      data: (profile) {
        final name = profile?.fullName.trim() ?? '';
        return name.isEmpty ? 'there' : name.split(' ').first;
      },
      orElse: () => '',
    );

    final pets = petsAsync.valueOrNull ?? [];
    final reminders = remindersAsync.valueOrNull ?? [];
    final total = reminders.length;
    final completed = reminders.where((r) => r.isCompleted).length;
    final due =
        reminders
            .where(
              (r) =>
                  !r.isCompleted && r.reminderDate.isBefore(DateTime.now()),
            )
            .length;
    final progress = total == 0 ? 0.0 : completed / total;

    return SkyHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${_greeting()}, $firstName '),
                          const TextSpan(text: '\u{1F44B}'),
                        ],
                      ),
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.of(context).pushNamed('/settings'),
                child: AppAvatar(fallbackText: firstName, radius: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SkyStatChip(
                  icon: Icons.pets,
                  value: '${pets.length}',
                  label: 'Pets',
                  variant: SkyStatChipVariant.onHeader,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkyStatChip(
                  icon: Icons.notifications_active,
                  value: '$due',
                  label: 'Due today',
                  variant: SkyStatChipVariant.onHeader,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkyStatChip(
                  icon: Icons.check_circle,
                  value: '$completed/$total',
                  label: 'Completed',
                  variant: SkyStatChipVariant.onHeader,
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's care",
                  style: GoogleFonts.dmSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SkyProgressBar(progress: progress, onHeader: true),
          ],
        ],
      ),
    );
  }
}

// ---------- My Pets ----------

class _MyPetsSection extends ConsumerWidget {
  const _MyPetsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsControllerProvider);
    final todayRemindersAsync = ref.watch(todayRemindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkySectionHeader(
          label: 'My Pets',
          actionLabel: 'Add',
          actionIcon: Icons.add,
          onAction:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddPet(species: 'dog'),
                ),
              ),
        ),
        const SizedBox(height: 12),
        petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) return const _NoPetsCard();
            final reminders = todayRemindersAsync.valueOrNull ?? [];
            return SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder:
                    (context, i) =>
                        _PetCard(pet: pets[i], todaysReminders: reminders),
              ),
            );
          },
          loading:
              () => const SizedBox(
                height: 176,
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) => SizedBox(
                height: 60,
                child: Center(child: Text('Could not load pets: $e')),
              ),
        ),
      ],
    );
  }
}

class _NoPetsCard extends StatelessWidget {
  const _NoPetsCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPet(species: 'dog')),
          ),
      child: SkyEmptyState(
        icon: Icons.pets,
        title: 'Add Your First Pet',
        subtitle: 'Tap below to get started',
        iconColor: SkyColors.of(context).header,
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.todaysReminders});

  final Pet pet;
  final List<Reminder> todaysReminders;

  String _ageLabel() {
    if (pet.age != null) return '${pet.age} yrs';
    if (pet.birthDate != null) {
      final years = DateTime.now().difference(pet.birthDate!).inDays ~/ 365;
      return '$years yrs';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final petReminders =
        todaysReminders.where((r) => r.petId == pet.id).toList();
    final hasDue = petReminders.any(
      (r) => !r.isCompleted && r.reminderDate.isBefore(DateTime.now()),
    );
    final hasAny = petReminders.isNotEmpty;
    final statusLabel = hasDue ? 'Due' : (hasAny ? 'Fed' : 'All good');
    final statusTone = hasDue ? SkyPillTone.due : SkyPillTone.success;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).pushNamed('/pet-details', arguments: pet),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: sky.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 84,
              width: double.infinity,
              child:
                  pet.photoUrl != null
                      ? Image.network(pet.photoUrl!, fit: BoxFit.cover)
                      : Image.asset(
                        'assets/images/images.jpg',
                        fit: BoxFit.cover,
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: sky.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      pet.breed ?? pet.species,
                      _ageLabel(),
                    ].where((s) => s.isNotEmpty).join(' \u00b7 '),
                    style: GoogleFonts.dmSans(
                      color: sky.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  StatusPill(label: statusLabel, tone: statusTone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- AI assistant promo ----------

/// A quick-access card into the AI Hub, built with the shared dark
/// "featured" card so the home screen surfaces the AI features without
/// needing its own bespoke styling.
class _AiAssistantPromo extends ConsumerWidget {
  const _AiAssistantPromo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SkyDarkFeatureCard(
      icon: Icons.auto_awesome,
      title: 'Ask the AI Vet',
      subtitle: 'Get quick guidance on symptoms, diet, or behavior.',
      buttonLabel: 'Open AI Hub',
      onPressed: () => ref.read(currentTabIndexProvider.notifier).state = 1,
    );
  }
}

// ---------- Today's Care ----------

class _TodaysCareSection extends ConsumerWidget {
  const _TodaysCareSection();

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('walk')) return Icons.directions_walk;
    if (t.contains('feed') || t.contains('meal')) return Icons.restaurant;
    if (t.contains('tablet') || t.contains('med') || t.contains('pill')) {
      return Icons.medication;
    }
    if (t.contains('vet') || t.contains('appointment')) {
      return Icons.medical_services;
    }
    if (t.contains('groom')) return Icons.content_cut;
    return Icons.pets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(todayRemindersProvider);
    final petsAsync = ref.watch(petsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkySectionHeader(
          label: "Today's Care",
          actionLabel: 'See all',
          onAction: () => ref.read(currentTabIndexProvider.notifier).state = 2,
        ),
        const SizedBox(height: 12),
        remindersAsync.when(
          data: (reminders) {
            if (reminders.isEmpty) {
              return const SkyEmptyState(
                icon: Icons.check_circle_outline,
                title: 'No reminders for today!',
                subtitle: 'Enjoy your free time',
              );
            }
            final sorted = [...reminders]
              ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
            final pets = petsAsync.valueOrNull ?? [];

            String petNameFor(String petId) {
              for (final p in pets) {
                if (p.id == petId) return p.name;
              }
              return 'Pet';
            }

            return Column(
              children: [
                for (final reminder in sorted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CareItemCard(
                      reminder: reminder,
                      petName: petNameFor(reminder.petId),
                      icon: _iconFor(reminder.title),
                      onToggle: () {
                        if (reminder.id == null) return;
                        ref
                            .read(remindersControllerProvider.notifier)
                            .completeReminder(reminder.id!, reminder);
                      },
                    ),
                  ),
              ],
            );
          },
          loading:
              () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (e, _) => Text('Could not load reminders: $e'),
        ),
      ],
    );
  }
}

class _CareItemCard extends StatelessWidget {
  const _CareItemCard({
    required this.reminder,
    required this.petName,
    required this.icon,
    required this.onToggle,
  });

  final Reminder reminder;
  final String petName;
  final IconData icon;
  final VoidCallback onToggle;

  bool get _isDue =>
      !reminder.isCompleted && reminder.reminderDate.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final timeLabel = DateFormat('h:mm a').format(reminder.reminderDate);

    return SkyCard(
      padding: const EdgeInsets.all(12),
      borderColor: _isDue ? SkyColors.due : null,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: sky.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: sky.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: sky.textPrimary,
                    decoration:
                        reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                    decorationColor: sky.textSecondary,
                  ),
                ),
                Text(
                  '$petName \u00b7 $timeLabel',
                  style: GoogleFonts.dmSans(
                    color: sky.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_isDue) ...[
            const StatusPill(label: 'DUE', tone: SkyPillTone.due, filled: true),
            const SizedBox(width: 8),
          ],
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    reminder.isCompleted ? SkyColors.success : Colors.transparent,
                border: Border.all(
                  color:
                      reminder.isCompleted
                          ? SkyColors.success
                          : (_isDue ? SkyColors.due : sky.border),
                  width: 2,
                ),
              ),
              child:
                  reminder.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- This Week ----------

class _ThisWeekSection extends ConsumerWidget {
  const _ThisWeekSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkySectionHeader(label: 'This Week'),
        const SizedBox(height: 12),
        statsAsync.when(
          data:
              (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: [
                  SkyStatChip(
                    icon: Icons.directions_walk,
                    value: '${stats.walks}',
                    label: 'Walks',
                  ),
                  SkyStatChip(
                    icon: Icons.medication,
                    value:
                        '${stats.medsGiven}/${stats.medsScheduled == 0 ? stats.medsGiven : stats.medsScheduled}',
                    label: 'Meds given',
                  ),
                  SkyStatChip(
                    icon: Icons.medical_services,
                    value: '${stats.vetVisits}',
                    label: 'Vet visits',
                  ),
                  SkyStatChip(
                    icon: Icons.auto_awesome,
                    value: '${stats.aiChecks}',
                    label: 'AI checks',
                  ),
                ],
              ),
          loading:
              () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
          error: (e, _) => Text('Could not load stats: $e'),
        ),
      ],
    );
  }
}