// screens/pet_selection_screens/pet_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/firestore_providers.dart';
import 'package:pet_care/screens/pet_selection_screens/medical_records.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/widgets/widgets.dart';

class PetDetailsScreen extends ConsumerWidget {
  const PetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Pet? routePet = ModalRoute.of(context)?.settings.arguments as Pet?;
    final Pet? selectedPet = ref.watch(selectedPetProvider);
    final Pet? displayPet = routePet ?? selectedPet;

    if (displayPet == null) {
      return const Scaffold(body: Center(child: Text('No pet selected')));
    }

    final sky = SkyColors.of(context);

    return Scaffold(
      backgroundColor: sky.pageBackground,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(pet: displayPet, ref: ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BasicInfoRow(pet: displayPet),
                  const SizedBox(height: 20),
                  _RemindersSection(pet: displayPet),
                  const SizedBox(height: 20),
                  _MedicalRecordsGateway(pet: displayPet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// HERO APP BAR
// ============================================

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.pet, required this.ref});

  final Pet pet;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: sky.header,
      leading: _CircleIconButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _CircleIconButton(
          icon: Icons.edit,
          onPressed:
              () => Navigator.pushNamed(context, '/edit-pet', arguments: pet),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.delete_outline,
          onPressed: () => _showDeleteConfirmation(context, ref, pet),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background:
            pet.photoUrl != null
                ? Image.network(pet.photoUrl!, fit: BoxFit.cover)
                : Container(
                  color: sky.header,
                  child: const Center(
                    child: Icon(Icons.pets, size: 72, color: Colors.white70),
                  ),
                ),
        title: Text(
          pet.name,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Pet displayPet,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Delete Pet'),
            content: Text(
              'Are you sure you want to delete ${displayPet.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(petsControllerProvider.notifier)
                        .deletePet(displayPet.id);
                    ref.read(selectedPetProvider.notifier).clearSelection();
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${displayPet.name} has been deleted'),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete pet: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ============================================
// BASIC INFO
// ============================================

class _BasicInfoRow extends StatelessWidget {
  const _BasicInfoRow({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final birthDate =
        pet.birthDate != null
            ? DateFormat('MMM dd, yyyy').format(pet.birthDate!)
            : 'Unknown';

    return Row(
      children: [
        Expanded(
          child: SkyStatChip(
            icon: Icons.cake,
            value: birthDate,
            label: 'Birth Date',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SkyStatChip(
            icon: Icons.monitor_weight,
            value: pet.weight != null ? '${pet.weight} kg' : 'Not set',
            label: 'Weight',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SkyStatChip(
            icon: Icons.qr_code,
            value: pet.microchipId ?? 'Not set',
            label: 'Microchip',
          ),
        ),
      ],
    );
  }
}

// ============================================
// REMINDERS
// ============================================

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sky = SkyColors.of(context);
    final remindersAsync = ref.watch(allRemindersProvider);

    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkySectionHeader(
            label: 'Upcoming Reminders',
            actionLabel: 'View All',
            onAction: () => _goToCareTab(context, ref),
          ),
          const SizedBox(height: 12),
          remindersAsync.when(
            data: (reminders) {
              final now = DateTime.now();
              final petReminders =
                  reminders
                      .where(
                        (r) =>
                            r.petId == pet.id && !r.reminderDate.isBefore(now),
                      )
                      .toList()
                    ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
              final upcoming = petReminders.take(3).toList();

              if (upcoming.isEmpty) {
                return const SkyEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'No upcoming reminders',
                  iconColor: SkyColors.success,
                );
              }

              return Column(
                children:
                    upcoming.map((r) => _ReminderRow(reminder: r)).toList(),
              );
            },
            loading:
                () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => Text(
                  'Error loading reminders: $e',
                  style: TextStyle(color: sky.textSecondary),
                ),
          ),
        ],
      ),
    );
  }
}

/// Pops back to the root MainNavigation shell and switches to the Care
/// (Reminders) tab, rather than pushing a second nested MainNavigation on
/// top of this screen.
void _goToCareTab(BuildContext context, WidgetRef ref) {
  ref.read(currentTabIndexProvider.notifier).state = 2;
  Navigator.of(context).popUntil((route) => route.isFirst);
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    final isDue =
        !reminder.isCompleted && reminder.reminderDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDue ? sky.dueSoft : sky.pageBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alarm,
            color: isDue ? SkyColors.due : sky.textSecondary,
            size: 20,
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
                  ),
                ),
                Text(
                  DateFormat('MMM dd, h:mm a').format(reminder.reminderDate),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: sky.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isDue)
            const StatusPill(label: 'DUE', tone: SkyPillTone.due, filled: true),
        ],
      ),
    );
  }
}

// ============================================
// MEDICAL RECORDS GATEWAY
// ============================================

/// Entry point into this pet's full medical history, pre-scoped so the
/// destination screen opens already showing this pet's records.
class _MedicalRecordsGateway extends ConsumerWidget {
  const _MedicalRecordsGateway({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sky = SkyColors.of(context);
    final recordsAsync = ref.watch(petMedicalRecordsProvider(pet.id));
    final count = recordsAsync.valueOrNull?.length ?? 0;

    return SkyCard(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedicalRecordsScreen(initialPetId: pet.id),
            ),
          ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sky.header,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.folder_shared, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Records',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: sky.textPrimary,
                  ),
                ),
                Text(
                  count == 0
                      ? 'No records yet - tap to add one'
                      : '$count record${count == 1 ? '' : 's'} on file',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: sky.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: sky.textSecondary),
        ],
      ),
    );
  }
}
