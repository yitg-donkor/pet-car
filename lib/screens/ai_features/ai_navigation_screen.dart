import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/providers/offline_providers.dart';
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

// ============================================
// AI DASHBOARD SCREEN
// ============================================

class AIDashboardScreen extends ConsumerStatefulWidget {
  final String userId;
  // Optional: pre-select a pet

  const AIDashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends ConsumerState<AIDashboardScreen> {
  bool isPremium =
      true; // TODO: Set to false, check actual premium status later

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'AI Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.deepPurple.shade600,
                      Colors.indigo.shade700,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Badge (if applicable)
                  if (isPremium)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Premium Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24),

                  // Section: Quick Actions
                  _buildSectionTitle('Quick Actions'),
                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.chat_bubble_outline,
                          color: theme.iconTheme.color!,
                          title: 'Chat',

                          onTap: () => _navigateToAichat(context, ref),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Scan Photo',
                          color: theme.iconTheme.color!,
                          onTap: () => _navigateToPhotoAnalysis(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Section: Health & Care
                  _buildSectionTitle('Health & Care'),
                  SizedBox(height: 12),

                  _buildAIServiceCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Symptom Checker',
                    description: 'Analyze your pet\'s symptoms',
                    gradient: [
                      const Color.fromARGB(150, 239, 83, 80),
                      const Color.fromARGB(200, 236, 64, 121),
                    ],
                    onTap: () => _navigateToSymptomChecker(context, ref),
                    isPremium: false,
                  ),

                  _buildAIServiceCard(
                    icon: Icons.history,
                    title: 'Medical History Analysis',
                    description: 'AI summary of health records',
                    gradient: [
                      const Color.fromARGB(150, 170, 71, 188),
                      const Color.fromARGB(200, 126, 87, 194),
                    ],
                    // onTap: () => _navigateToMedicalAnalysis(context),
                    onTap: () => _navigateToMedicalAnalysis(context, ref),
                    isPremium: false,
                  ),

                  _buildAIServiceCard(
                    icon: Icons.calendar_today,
                    title: 'Smart Reminders',
                    description: 'AI-powered care scheduling',
                    gradient: [
                      const Color.fromARGB(150, 255, 168, 38),
                      const Color.fromARGB(200, 255, 111, 67),
                    ],
                    onTap: () => _navigateToSmartReminders(context, ref),
                    isPremium: true, // Premium feature
                  ),

                  SizedBox(height: 24),

                  // Section: Nutrition & Training
                  _buildSectionTitle('Nutrition & Training'),
                  SizedBox(height: 12),

                  _buildAIServiceCard(
                    icon: Icons.restaurant_outlined,
                    title: 'Feeding Schedule',
                    description: 'Personalized meal plans',
                    gradient: [
                      const Color.fromARGB(150, 38, 166, 153),
                      const Color.fromARGB(200, 38, 197, 218),
                    ],
                    onTap: () => _navigateToFeedingSchedule(context, ref),
                    isPremium: false,
                  ),

                  _buildAIServiceCard(
                    icon: Icons.school_outlined,
                    title: 'Training Tips',
                    description: 'Behavior guidance & training',
                    gradient: [
                      const Color.fromARGB(150, 92, 107, 192),
                      const Color.fromARGB(200, 66, 164, 245),
                    ],
                    onTap: () => _navigateToTrainingTips(context, ref),
                    isPremium: false,
                  ),

                  SizedBox(height: 24),

                  // Section: Insights & Reports
                  _buildSectionTitle('Insights & Reports'),
                  SizedBox(height: 12),

                  _buildAIServiceCard(
                    icon: Icons.insights_outlined,
                    title: 'Health Insights',
                    description: 'AI-powered health trends',
                    gradient: [
                      const Color.fromARGB(150, 41, 181, 246),
                      const Color.fromARGB(200, 30, 136, 229),
                    ],
                    onTap: () => _navigateToHealthInsights(context, ref),
                    isPremium: true, // Premium feature
                  ),

                  _buildAIServiceCard(
                    icon: Icons.assessment_outlined,
                    title: 'Monthly Report',
                    description: 'Comprehensive care summary',
                    gradient: [
                      const Color.fromARGB(150, 126, 87, 194),
                      const Color.fromARGB(200, 141, 36, 170),
                    ],
                    onTap: () => _navigateToMonthlyReport(context, ref),
                    isPremium: true, // Premium feature
                  ),

                  SizedBox(height: 24),

                  // Premium Upsell Card (if not premium)
                  if (!isPremium) _buildPremiumUpsellCard(context),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // UI COMPONENTS
  // ============================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    final isLocked = isPremium && !this.isPremium;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isLocked ? () => _showPremiumDialog(context) : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isLocked
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : gradient,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocked ? Icons.lock : icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isPremium) ...[
                          SizedBox(width: 8),
                          Icon(Icons.star, size: 16, color: Colors.amber),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      isLocked ? 'Premium Feature' : description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUpsellCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Unlock Premium AI Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Get smart reminders, health insights, and monthly reports',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToPremium(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Upgrade Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // NAVIGATION METHODS
  // ============================================

  void _navigateToPhotoAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoAnalysisScreen()),
    );
  }

  void _navigateToSymptomChecker(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SymptomCheckerScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  // void _navigateToMedicalAnalysis(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) =>
  //               MedicalHistoryAnalysisScreen(petId: widget.currentPetId ?? ''),
  //     ),
  //   );
  // }

  void _navigateToSmartReminders(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SmartRemindersScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToFeedingSchedule(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        FeedingScheduleScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToTrainingTips(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TrainingTipsScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToAichat(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AIVetChatScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToHealthInsights(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HealthInsightsScreen(petId: pet.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToMonthlyReport(BuildContext context, WidgetRef ref) async {
    // ✅ Load data FIRST
    final pets = await ref.read(petsOfflineProvider.future);

    if (!context.mounted) return;

    // Show bottom sheet with already-loaded data
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select a Pet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                if (pets.isEmpty)
                  Text('No pets available')
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pet.photoUrl != null
                                    ? NetworkImage(pet.photoUrl!)
                                    : AssetImage(
                                          'assets/images/pet_placeholder.png',
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(
                            '${pet.species} - ${pet.breed ?? 'Unknown'}',
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MonthlyReportScreen(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PremiumUpgradeScreen()),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber),
                SizedBox(width: 8),
                Text('Premium Feature'),
              ],
            ),
            content: Text(
              'This feature is available for premium users. Upgrade now to unlock all AI features!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToPremium(context);
                },
                child: Text('Upgrade Now'),
              ),
            ],
          ),
    );
  }
}

void _navigateToMedicalAnalysis(BuildContext context, WidgetRef ref) async {
  // ✅ Load data FIRST
  final pets = await ref.read(petsOfflineProvider.future);

  if (!context.mounted) return;

  // Show bottom sheet with already-loaded data
  showModalBottomSheet(
    context: context,
    builder:
        (context) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select a Pet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              if (pets.isEmpty)
                Text('No pets available')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              pet.photoUrl != null
                                  ? NetworkImage(pet.photoUrl!)
                                  : AssetImage(
                                        'assets/images/pet_placeholder.png',
                                      )
                                      as ImageProvider,
                        ),
                        title: Text(pet.name),
                        subtitle: Text(
                          '${pet.species} - ${pet.breed ?? 'Unknown'}',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MedicalHistoryAnalysisScreen(pet: pet),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
  );
}

// ============================================
// PLACEHOLDER SCREENS (Create these next)
// ============================================

// Already created in previous artifact
