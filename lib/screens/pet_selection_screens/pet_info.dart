import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/providers/offline_providers.dart';

import 'package:intl/intl.dart';

class PetDetailsScreen extends ConsumerWidget {
  const PetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Pet? routePet = ModalRoute.of(context)?.settings.arguments as Pet?;
    final Pet? selectedPet = ref.watch(selectedPetProvider);
    final Pet? displayPet = routePet ?? selectedPet;

    if (displayPet == null) {
      print('No pet selected: routePet=$routePet, selectedPet=$selectedPet');
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Details')),
        body: const Center(child: Text('No pet selected')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, displayPet, ref),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildPetInfoCard(context, displayPet),
                const SizedBox(height: 20),
                _buildHealthStatsCard(context, displayPet),
                const SizedBox(height: 20),
                _buildRemindersSection(context, ref, displayPet),
                const SizedBox(height: 20),
                _buildQuickActionsCard(context, displayPet),
                const SizedBox(height: 20),
                _buildMedicalHistoryCard(context, ref, displayPet),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Pet displayPet, WidgetRef ref) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
            ],
          ),
          child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            print('Selected pet: ${displayPet.name}');
            Navigator.pushNamed(context, '/edit-pet', arguments: displayPet);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
              ],
            ),
            child: Icon(Icons.edit, color: theme.colorScheme.onSurface),
          ),
        ),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context, ref, displayPet),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            displayPet.photoUrl != null && displayPet.photoUrl!.isNotEmpty
                ? Image.network(
                  displayPet.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultPetImage(),
                )
                : _buildDefaultPetImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayPet.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${displayPet.species} • ${displayPet.breed ?? "Mixed"}',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPetImage() {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Icon(Icons.pets, size: 100, color: Colors.blue.shade300),
      ),
    );
  }

  Widget _buildPetInfoCard(BuildContext context, Pet displayPet) {
    final theme = Theme.of(context);
    final age = displayPet.age ?? 0;
    final birthDate =
        displayPet.birthDate != null
            ? DateFormat('MMM dd, yyyy').format(displayPet.birthDate!)
            : 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.cake,
            'Age',
            '$age ${age == 1 ? "year" : "years"} old',
            theme,
          ),
          _buildInfoRow(Icons.calendar_today, 'Birth Date', birthDate, theme),
          _buildInfoRow(
            Icons.monitor_weight,
            'Weight',
            displayPet.weight != null ? '${displayPet.weight} kg' : 'Not set',
            theme,
          ),
          _buildInfoRow(
            Icons.pets,
            'Breed',
            displayPet.breed ?? 'Mixed',
            theme,
          ),
          _buildInfoRow(
            Icons.color_lens,
            'Color',
            displayPet.color ?? 'Not specified',
            theme,
          ),
          if (displayPet.microchipId != null)
            _buildInfoRow(
              Icons.qr_code,
              'Microchip',
              displayPet.microchipId!,
              theme,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatsCard(BuildContext context, Pet displayPet) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Health Status',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatBadge('Healthy', Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBadge('Active', Icons.flash_on)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBadge('Happy', Icons.mood)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Next checkup: Not scheduled',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(
    BuildContext context,
    WidgetRef ref,
    Pet displayPet,
  ) {
    final remindersAsync = ref.watch(allRemindersProvider);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Reminders',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      '/reminders',
                      arguments: displayPet,
                    ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          remindersAsync.when(
            data: (reminders) {
              final petReminders =
                  reminders
                      .where((r) => r.petId == displayPet.id)
                      .take(3)
                      .toList();

              if (petReminders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No upcoming reminders',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children:
                    petReminders
                        .map((r) => _buildReminderItem(r, theme))
                        .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error loading reminders: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(reminder, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('MMM dd, h:mm a').format(reminder.reminderDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, Pet displayPet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Theme.of(context),
                  icon: Icons.add_alert,
                  label: 'Add Reminder',
                  color: Colors.blue,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/reminders',
                        arguments: displayPet,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  Theme.of(context),
                  icon: Icons.medical_services,
                  label: 'Add Record',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/add-medical-record',
                      arguments: displayPet,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  Theme.of(context),
                  icon: Icons.edit,
                  label: 'Edit Info',
                  color: Colors.orange,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/edit-pet',
                        arguments: displayPet,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  Theme.of(context),
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.purple,
                  onTap: () {
                    // Implement share functionality
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    ThemeData theme, {

    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalHistoryCard(
    BuildContext context,
    WidgetRef ref,
    Pet displayPet,
  ) {
    final theme = Theme.of(context);
    final medicalRecordsAsync = ref.watch(
      petMedicalRecordsOfflineProvider(displayPet.id),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Medical History',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/add-medical-record',
                    arguments: displayPet,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          medicalRecordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.medical_information,
                          size: 48,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No medical records yet',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/add-medical-record',
                              arguments: displayPet,
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Record'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort records by date (newest first)
              final sortedRecords = List<MedicalRecord>.from(records)
                ..sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedRecords.length,
                itemBuilder: (context, index) {
                  return _buildMedicalRecordItem(
                    sortedRecords[index],
                    theme,
                    index == 0,
                  );
                },
              );
            },
            loading:
                () => Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            error:
                (error, stack) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Error loading records: $error',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordItem(
    MedicalRecord record,
    ThemeData theme,
    bool isLatest,
  ) {
    final recordTypeIcon = _getRecordTypeIcon(record.recordType);
    final recordTypeColor = _getRecordTypeColor(record.recordType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isLatest
                ? recordTypeColor.withOpacity(0.1)
                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isLatest ? recordTypeColor.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: recordTypeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(recordTypeIcon, color: recordTypeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatRecordType(record.recordType),
                      style: TextStyle(
                        fontSize: 12,
                        color: recordTypeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: recordTypeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Latest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (record.description != null && record.description!.isNotEmpty) ...[
            Text(
              record.description!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: recordTypeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(record.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (record.veterinarian != null &&
                  record.veterinarian!.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: recordTypeColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          record.veterinarian!,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (record.cost != null && record.cost! > 0)
                Text(
                  'GHS ${record.cost!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: recordTypeColor,
                  ),
                ),
            ],
          ),
          if (record.nextDueDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm_on, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${DateFormat('MMM dd').format(record.nextDueDate!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getRecordTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.shield_outlined;
      case 'checkup':
        return Icons.local_hospital;
      case 'surgery':
        return Icons.medical_services;
      case 'prescription':
        return Icons.medication;
      case 'dental':
        return Icons.medical_services_outlined;
      case 'lab':
        return Icons.science;
      default:
        return Icons.medical_information;
    }
  }

  Color _getRecordTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Colors.blue;
      case 'checkup':
        return Colors.green;
      case 'surgery':
        return Colors.red;
      case 'prescription':
        return Colors.orange;
      case 'dental':
        return Colors.purple;
      case 'lab':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatRecordType(String type) {
    return type.replaceFirst(type[0], type[0].toUpperCase());
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Pet displayPet,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
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
                  // Delete pet using the notifier
                  await ref
                      .read(petsOfflineProvider.notifier)
                      .deletePet(displayPet.id);

                  // Clear selection
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
        );
      },
    );
  }
}
