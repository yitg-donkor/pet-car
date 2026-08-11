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
import 'package:pet_care/theme/redesign_tokens.dart';

// ============================================
// AI DASHBOARD SCREEN
// ============================================

class AIDashboardScreen extends ConsumerWidget {
  const AIDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsControllerProvider);

    return Scaffold(
      backgroundColor: RedesignColors.background,
      body: SafeArea(
        child: petsAsync.when(
          data: (pets) {
            if (pets.isEmpty) return const _NoPetsForAI();

            // Default to the first pet if nothing's selected yet.
            final selected = ref.watch(selectedPetProvider) ?? pets.first;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                RedesignSpacing.md,
                RedesignSpacing.md,
                RedesignSpacing.md,
                RedesignSpacing.xl,
              ),
              children: [
                const _AIHeader(),
                const SizedBox(height: RedesignSpacing.md),
                _PetSelectorRow(pets: pets, selected: selected),
                const SizedBox(height: RedesignSpacing.md),
                _AIVetChatCard(pet: selected),
                const SizedBox(height: RedesignSpacing.lg),
                const _SectionLabel('INCLUDED FREE'),
                const SizedBox(height: RedesignSpacing.sm),
                _FreeFeaturesGrid(pet: selected),
                const SizedBox(height: RedesignSpacing.lg),
                const _PremiumHeader(),
                const SizedBox(height: RedesignSpacing.sm),
                _PremiumFeaturesGrid(pet: selected),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load pets: $e')),
        ),
      ),
    );
  }
}

class _NoPetsForAI extends StatelessWidget {
  const _NoPetsForAI();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(RedesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 48, color: RedesignColors.accent),
            SizedBox(height: RedesignSpacing.sm),
            Text(
              'Add a pet to unlock AI features',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: RedesignColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIHeader extends StatelessWidget {
  const _AIHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POWERED BY AI',
          style: TextStyle(
            color: RedesignColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'AI Assistant',
          style: TextStyle(
            color: RedesignColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: RedesignSpacing.sm),
        itemBuilder: (context, i) {
          final pet = pets[i];
          final isSelected = pet.id == selected.id;
          return InkWell(
            borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
            onTap: () =>
                ref.read(selectedPetProvider.notifier).selectPet(pet),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? RedesignColors.accent : RedesignColors.surface,
                borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : RedesignColors.accentSoft,
                    backgroundImage:
                        pet.photoUrl != null ? NetworkImage(pet.photoUrl!) : null,
                    child: pet.photoUrl == null
                        ? Icon(
                            Icons.pets,
                            size: 12,
                            color: isSelected
                                ? Colors.white
                                : RedesignColors.accent,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pet.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : RedesignColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AIVetChatCard extends StatelessWidget {
  const _AIVetChatCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RedesignSpacing.md),
      decoration: BoxDecoration(
        color: RedesignColors.chatCardDark,
        borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RedesignColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
              ),
              const SizedBox(width: RedesignSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Vet Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Ask any pet health question',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RedesignSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(RedesignSpacing.sm + 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '"Is it normal for ${pet.name} to eat grass sometimes?"',
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: RedesignSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AIVetChatScreen(pet: pet)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: RedesignColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start a Conversation \u2192',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RedesignColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _FreeFeaturesGrid extends StatelessWidget {
  const _FreeFeaturesGrid({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: RedesignSpacing.sm,
      crossAxisSpacing: RedesignSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        _FeatureCard(
          icon: Icons.camera_alt,
          iconColor: RedesignColors.accent,
          title: 'Scan Photo',
          subtitle: 'Skin & eye analysis',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PhotoAnalysisScreen()),
          ),
        ),
        _FeatureCard(
          icon: Icons.medical_information,
          iconColor: RedesignColors.success,
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

class _PremiumHeader extends ConsumerWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.diamond, size: 14, color: RedesignColors.premium),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: RedesignColors.premium,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PremiumUpgradeScreen()),
          ),
          style: TextButton.styleFrom(
            backgroundColor: RedesignColors.premium,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RedesignSpacing.pillRadius),
            ),
          ),
          child: const Text(
            'Upgrade',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ],
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
  static const bool _isPremiumUser = false;

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
        padding: const EdgeInsets.all(RedesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond, color: RedesignColors.premium, size: 32),
            const SizedBox(height: RedesignSpacing.sm),
            const Text(
              'This is a Premium feature',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upgrade to unlock this and 5 more AI tools.',
              textAlign: TextAlign.center,
              style: TextStyle(color: RedesignColors.textSecondary),
            ),
            const SizedBox(height: RedesignSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PremiumUpgradeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedesignColors.premium,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(RedesignSpacing.pillRadius),
                  ),
                ),
                child: const Text('Upgrade Now'),
              ),
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
      mainAxisSpacing: RedesignSpacing.sm,
      crossAxisSpacing: RedesignSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        _FeatureCard(
          icon: Icons.bar_chart,
          iconColor: RedesignColors.premium,
          title: 'Medical AI',
          subtitle: 'History analysis',
          isPro: true,
          onTap: () =>
              _handleTap(context, MedicalHistoryAnalysisScreen(pet: pet)),
        ),
        _FeatureCard(
          icon: Icons.bolt,
          iconColor: RedesignColors.due,
          title: 'Smart Schedule',
          subtitle: 'Auto-reminders',
          isPro: true,
          onTap: () => _handleTap(context, SmartRemindersScreen(pet: pet)),
        ),
        _FeatureCard(
          icon: Icons.restaurant_menu,
          iconColor: RedesignColors.success,
          title: 'Feeding Plan',
          subtitle: 'Custom schedule',
          isPro: true,
          onTap: () => _handleTap(context, FeedingScheduleScreen(pet: pet)),
        ),
        _FeatureCard(
          icon: Icons.school,
          iconColor: RedesignColors.accent,
          title: 'Training Tips',
          subtitle: 'Personalized advice',
          isPro: true,
          onTap: () => _handleTap(context, TrainingTipsScreen(pet: pet)),
        ),
        _FeatureCard(
          icon: Icons.favorite,
          iconColor: RedesignColors.due,
          title: 'Health Insights',
          subtitle: 'Trend analysis',
          isPro: true,
          onTap: () =>
              _handleTap(context, HealthInsightsScreen(petId: pet.id)),
        ),
        _FeatureCard(
          icon: Icons.summarize,
          iconColor: RedesignColors.premium,
          title: 'Monthly Report',
          subtitle: 'Full summary',
          isPro: true,
          onTap: () => _handleTap(context, MonthlyReportScreen(pet: pet)),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPro = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(RedesignSpacing.sm + 4),
        decoration: BoxDecoration(
          color: isPro ? RedesignColors.premiumSoft : RedesignColors.surface,
          borderRadius: BorderRadius.circular(RedesignSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 22),
                if (isPro)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: RedesignColors.premium,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: RedesignSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: RedesignColors.textPrimary,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: RedesignColors.textSecondary,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
