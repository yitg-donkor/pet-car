// screens/main_screens/homescreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/firestore_providers.dart';
import 'package:pet_care/screens/ai_features/ai_navigation_screen.dart';
import 'package:pet_care/screens/main_screens/log.dart';
import 'package:pet_care/screens/main_screens/reminders.dart';
import 'package:pet_care/screens/main_screens/resources.dart';
import 'package:pet_care/screens/pet_selection_screens/add_pet.dart';
import 'package:pet_care/theme/redesign_tokens.dart';

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
      backgroundColor: RedesignColors.background,
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(currentIndex),
    );
  }

  Widget _buildNavBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: RedesignColors.surface,
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
              final color =
                  selected ? RedesignColors.accent : RedesignColors.textMuted;

              return Expanded(
                child: InkWell(
                  onTap: () =>
                      ref.read(currentTabIndexProvider.notifier).state = index,
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
                          color:
                              selected ? RedesignColors.accent : Colors.transparent,
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
    return Scaffold(
      backgroundColor: RedesignColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: RedesignColors.accent,
          onRefresh: () async {
            ref.invalidate(petsControllerProvider);
            ref.invalidate(todayRemindersProvider);
            ref.invalidate(weeklyStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              RedesignSpacing.md,
              RedesignSpacing.md,
              RedesignSpacing.md,
              RedesignSpacing.xl,
            ),
            children: const [
              _HomeHeader(),
              SizedBox(height: RedesignSpacing.lg),
              _MyPetsSection(),
              SizedBox(height: RedesignSpacing.lg),
              _TodaysCareSection(),
              SizedBox(height: RedesignSpacing.lg),
              _ThisWeekSection(),
            ],
          ),
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
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    final firstName = profileAsync.maybeWhen(
      data: (profile) {
        final name = profile?.fullName.trim() ?? '';
        return name.isEmpty ? 'there' : name.split(' ').first;
      },
      orElse: () => '',
    );

    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  color: RedesignColors.textSecondary,
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
                style: const TextStyle(
                  color: RedesignColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: RedesignColors.accent,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MY PETS',
              style: TextStyle(
                color: RedesignColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPet(species: 'dog')),
              ),
              icon: const Icon(Icons.add, size: 16, color: RedesignColors.accent),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: RedesignColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: RedesignSpacing.sm),
        petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) return const _NoPetsCard();
            final reminders = todayRemindersAsync.valueOrNull ?? [];
            return SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: RedesignSpacing.sm),
                itemBuilder: (context, i) =>
                    _PetCard(pet: pets[i], todaysReminders: reminders),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 168,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
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
      borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddPet(species: 'dog')),
      ),
      child: Container(
        padding: const EdgeInsets.all(RedesignSpacing.lg),
        decoration: BoxDecoration(
          color: RedesignColors.surface,
          borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
          border: Border.all(
            color: RedesignColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.pets, color: RedesignColors.accent, size: 28),
            SizedBox(width: RedesignSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Your First Pet',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: RedesignColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tap to get started',
                    style: TextStyle(
                      color: RedesignColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.todaysReminders});

  final Pet pet;
  final List<Reminder> todaysReminders;

  String get _ageLabel {
    if (pet.age != null) return '${pet.age} yrs';
    if (pet.birthDate != null) {
      final years = DateTime.now().difference(pet.birthDate!).inDays ~/ 365;
      return '$years yrs';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final petReminders =
        todaysReminders.where((r) => r.petId == pet.id).toList();
    final hasDue = petReminders.any(
      (r) => !r.isCompleted && r.reminderDate.isBefore(DateTime.now()),
    );
    final hasAny = petReminders.isNotEmpty;
    final statusLabel = hasDue ? 'Due' : (hasAny ? 'Fed' : 'All good');
    final statusColor = hasDue ? RedesignColors.due : RedesignColors.success;
    final statusBg = hasDue ? RedesignColors.dueSoft : RedesignColors.successSoft;

    return InkWell(
      borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      onTap: () => Navigator.of(context).pushNamed('/pet-details', arguments: pet),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: RedesignColors.surface,
          borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: double.infinity,
              child: pet.photoUrl != null
                  ? Image.network(pet.photoUrl!, fit: BoxFit.cover)
                  : Container(
                      color: RedesignColors.accentSoft,
                      child: const Icon(
                        Icons.pets,
                        color: RedesignColors.accent,
                        size: 32,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(RedesignSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: RedesignColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [pet.breed ?? pet.species, _ageLabel]
                        .where((s) => s.isNotEmpty)
                        .join(' \u00b7 '),
                    style: const TextStyle(
                      color: RedesignColors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius:
                          BorderRadius.circular(RedesignSpacing.pillRadius),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TODAY'S CARE",
              style: TextStyle(
                color: RedesignColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(currentTabIndexProvider.notifier).state = 2,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: RedesignColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RedesignSpacing.sm),
        remindersAsync.when(
          data: (reminders) {
            if (reminders.isEmpty) {
              return const _EmptyCareCard();
            }
            final sorted = [...reminders]
              ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
            final completed = sorted.where((r) => r.isCompleted).length;
            final total = sorted.length;
            final progress = total == 0 ? 0.0 : completed / total;
            final pets = petsAsync.valueOrNull ?? [];

            String petNameFor(String petId) {
              for (final p in pets) {
                if (p.id == petId) return p.name;
              }
              return 'Pet';
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed of $total complete',
                      style: const TextStyle(
                        color: RedesignColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: RedesignColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: RedesignColors.border,
                    valueColor: const AlwaysStoppedAnimation(
                      RedesignColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: RedesignSpacing.md),
                ...sorted.map(
                  (reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: RedesignSpacing.sm),
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
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: RedesignSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Could not load reminders: $e'),
        ),
      ],
    );
  }
}

class _EmptyCareCard extends StatelessWidget {
  const _EmptyCareCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RedesignSpacing.lg),
      decoration: BoxDecoration(
        color: RedesignColors.surface,
        borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: RedesignColors.success, size: 32),
          SizedBox(height: 8),
          Text(
            'No reminders for today!',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: RedesignColors.textPrimary,
            ),
          ),
          Text(
            'Enjoy your free time',
            style: TextStyle(color: RedesignColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
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
    final timeLabel = DateFormat('h:mm a').format(reminder.reminderDate);
    final bg = _isDue ? RedesignColors.dueSoft : RedesignColors.surface;

    return Container(
      padding: const EdgeInsets.all(RedesignSpacing.sm + 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: _isDue ? Border.all(color: RedesignColors.due, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: RedesignColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: RedesignColors.textSecondary),
          ),
          const SizedBox(width: RedesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RedesignColors.textPrimary,
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: RedesignColors.textMuted,
                  ),
                ),
                Text(
                  '$petName \u00b7 $timeLabel',
                  style: const TextStyle(
                    color: RedesignColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_isDue)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: RedesignColors.due,
                borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
              ),
              child: const Text(
                'DUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reminder.isCompleted
                    ? RedesignColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: reminder.isCompleted
                      ? RedesignColors.success
                      : (_isDue ? RedesignColors.due : RedesignColors.border),
                  width: 2,
                ),
              ),
              child: reminder.isCompleted
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
        const Text(
          'THIS WEEK',
          style: TextStyle(
            color: RedesignColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: RedesignSpacing.sm),
        statsAsync.when(
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: RedesignSpacing.sm,
            crossAxisSpacing: RedesignSpacing.sm,
            childAspectRatio: 1.7,
            children: [
              _StatCard(
                icon: Icons.directions_walk,
                value: '${stats.walks}',
                label: 'Walks',
              ),
              _StatCard(
                icon: Icons.medication,
                value: '${stats.medsGiven}/${stats.medsScheduled == 0 ? stats.medsGiven : stats.medsScheduled}',
                label: 'Meds given',
              ),
              _StatCard(
                icon: Icons.medical_services,
                value: '${stats.vetVisits}',
                label: 'Vet visits',
              ),
              _StatCard(
                icon: Icons.auto_awesome,
                value: '${stats.aiChecks}',
                label: 'AI checks',
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Could not load stats: $e'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RedesignSpacing.sm + 4),
      decoration: BoxDecoration(
        color: RedesignColors.surface,
        borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: RedesignColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: RedesignColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: RedesignColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
