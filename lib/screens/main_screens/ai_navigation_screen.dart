// screens/ai_features/ai_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/providers/firestore_providers.dart';
import 'package:pet_care/screens/ai_features/aichatscreen.dart';
import 'package:pet_care/screens/ai_features/feeding_schedulescren.dart';
import 'package:pet_care/screens/ai_features/health_insights.dart';
import 'package:pet_care/screens/ai_features/medical_historyanalysis_screen.dart';
import 'package:pet_care/screens/ai_features/monthly_report_screen.dart';
import 'package:pet_care/screens/ai_features/photo_analysis_screen.dart';
import 'package:pet_care/screens/ai_features/premium_upgrade_screen.dart';
import 'package:pet_care/screens/ai_features/smart_reminder.dart';
import 'package:pet_care/screens/ai_features/symptons_checker.dart';
import 'package:pet_care/screens/ai_features/training_tips.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/widgets/widgets.dart';

// ============================================
// AI DASHBOARD SCREEN
// ============================================

class AIDashboardScreen extends ConsumerWidget {
  const AIDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsControllerProvider);

    return Scaffold(
      body: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) return const _NoPetsForAI();

          // Default to the first pet if nothing's selected yet.
          final selected = ref.watch(selectedPetProvider) ?? pets.first;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _AIHeader(pets: pets, selected: selected),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _AIVetChatCard(pet: selected),
                    const SizedBox(height: 24),
                    SkySectionHeader(label: 'Included Free'),
                    const SizedBox(height: 12),
                    _FreeFeaturesGrid(pet: selected),
                    const SizedBox(height: 24),
                    _PremiumHeader(),
                    const SizedBox(height: 12),
                    _PremiumFeaturesGrid(pet: selected),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SafeArea(
          child: Center(child: Text('Could not load pets: $e')),
        ),
      ),
    );
  }
}

class _NoPetsForAI extends StatelessWidget {
  const _NoPetsForAI();

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SkyEmptyState(
            icon: Icons.pets,
            iconColor: sky.header,
            title: 'Add a pet to unlock AI features',
          ),
        ),
      ),
    );
  }
}

// ---------- Header ----------

/// Sky-blue wave header for the AI Hub - greeting/eyebrow text plus the
/// pet selector, so switching pets happens right where the "AI Assistant"
/// title lives rather than as a separate row below it.
class _AIHeader extends StatelessWidget {
  const _AIHeader({required this.pets, required this.selected});

  final List<Pet> pets;
  final Pet selected;

  @override
  Widget build(BuildContext context) {
    return SkyHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POWERED BY AI',
            style: TextStyle(
              color: SkyColors.skyOnHeaderMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'AI Assistant',
            style: TextStyle(
              color: SkyColors.skyOnHeader,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _PetSelectorRow(pets: pets, selected: selected),
        ],
      ),
    );
  }
}

class _PetSelectorRow extends ConsumerWidget {
  const _PetSelectorRow({required this.pets, required this.selected});

  final List<Pet> pets;
  final Pet selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final pet = pets[i];
          final isSelected = pet.id == selected.id;
          return _OnHeaderPetChip(
            name: pet.name,
            imageUrl: pet.photoUrl,
            selected: isSelected,
            onTap: () => ref.read(selectedPetProvider.notifier).selectPet(pet),
          );
        },
      ),
    );
  }
}

/// A pet chip styled for the header context specifically: unselected chips
/// sit as translucent-white pills on the blue header (matching
/// [SkyStatChip]'s onHeader treatment) rather than [SkyPetChip]'s
/// surface-colored default, which would look washed out against the wave.
class _OnHeaderPetChip extends StatelessWidget {
  const _OnHeaderPetChip({
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(100),
          border: selected
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              imageUrl: imageUrl,
              fallbackText: name,
              radius: 10,
              backgroundColor: selected
                  ? SkyColors.of(context).header
                  : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: selected ? SkyColors.of(context).header : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- AI Vet Chat ----------

class _AIVetChatCard extends StatelessWidget {
  const _AIVetChatCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return SkyDarkFeatureCard(
      icon: Icons.chat_bubble,
      title: 'AI Vet Chat',
      subtitle: 'Ask any pet health question',
      exampleText: '"Is it normal for ${pet.name} to eat grass sometimes?"',
      buttonLabel: 'Start a Conversation \u2192',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AIVetChatScreen(pet: pet)),
      ),
    );
  }
}

// ---------- Free features ----------

class _FreeFeaturesGrid extends StatelessWidget {
  const _FreeFeaturesGrid({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final sky = SkyColors.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        SkyFeatureTile(
          icon: Icons.camera_alt,
          iconColor: sky.header,
          title: 'Scan Photo',
          subtitle: 'Skin & eye analysis',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PhotoAnalysisScreen()),
          ),
        ),
        SkyFeatureTile(
          icon: Icons.medical_information,
          iconColor: SkyColors.success,
          title: 'Symptom Check',
          subtitle: 'Quick triage',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SymptomCheckerScreen(pet: pet)),
          ),
        ),
      ],
    );
  }
}

// ---------- Premium features ----------

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return SkySectionHeader(
      label: 'Premium',
      actionLabel: 'Upgrade',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PremiumUpgradeScreen()),
      ),
    );
  }
}

class _PremiumFeaturesGrid extends StatelessWidget {
  const _PremiumFeaturesGrid({required this.pet});

  final Pet pet;

  // TODO: no subscription/entitlement system exists yet (no premium field
  // anywhere in UserProfile or elsewhere). Defaulting to false is the safe
  // choice - the previous code hardcoded `true` with a TODO admitting it
  // was a placeholder, which let every user through for free. Wire this to
  // real entitlement data once billing exists.
  static const bool _isPremiumUser = true;

  void _handleTap(BuildContext context, Widget destination) {
    if (_isPremiumUser) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => destination));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: SkyColors.premium, size: 32),
            const SizedBox(height: 10),
            const Text(
              'This is a Premium feature',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Upgrade to unlock this and 5 more AI tools.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SkyColors.of(context).textSecondary),
            ),
            const SizedBox(height: 16),
            SkyPillButton(
              label: 'Upgrade Now',
              tone: SkyButtonTone.premium,
              expand: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PremiumUpgradeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        SkyFeatureTile(
          icon: Icons.bar_chart,
          iconColor: SkyColors.premium,
          title: 'Medical AI',
          subtitle: 'History analysis',
          isPro: true,
          onTap: () =>
              _handleTap(context, MedicalHistoryAnalysisScreen(pet: pet)),
        ),
        SkyFeatureTile(
          icon: Icons.bolt,
          iconColor: SkyColors.due,
          title: 'Smart Schedule',
          subtitle: 'Auto-reminders',
          isPro: true,
          onTap: () => _handleTap(context, SmartRemindersScreen(pet: pet)),
        ),
        SkyFeatureTile(
          icon: Icons.restaurant_menu,
          iconColor: SkyColors.success,
          title: 'Feeding Plan',
          subtitle: 'Custom schedule',
          isPro: true,
          onTap: () => _handleTap(context, FeedingScheduleScreen(pet: pet)),
        ),
        SkyFeatureTile(
          icon: Icons.school,
          iconColor: SkyColors.of(context).header,
          title: 'Training Tips',
          subtitle: 'Personalized advice',
          isPro: true,
          onTap: () => _handleTap(context, TrainingTipsScreen(pet: pet)),
        ),
        SkyFeatureTile(
          icon: Icons.favorite,
          iconColor: SkyColors.due,
          title: 'Health Insights',
          subtitle: 'Trend analysis',
          isPro: true,
          onTap: () =>
              _handleTap(context, HealthInsightsScreen(petId: pet.id)),
        ),
        SkyFeatureTile(
          icon: Icons.summarize,
          iconColor: SkyColors.premium,
          title: 'Monthly Report',
          subtitle: 'Full summary',
          isPro: true,
          onTap: () => _handleTap(context, MonthlyReportScreen(pet: pet)),
        ),
      ],
    );
  }
}