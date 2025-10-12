import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/reminder.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';
import 'package:pet_care/providers/pet_providers.dart';
import 'package:pet_care/services/notification_service.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialSyncDone = false;
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialSyncDone) {
      _isInitialSyncDone = true;
      _performInitialSync();
    }
  }

  Future<void> _performInitialSync() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.fullSync(user.id);

      if (mounted) {
        _invalidateAllProviders();

        // Reschedule all notifications after sync
        final allReminders =
            await ref.read(reminderDatabaseProvider).getAllReminders();
        await _notificationService.rescheduleAllReminders(
          allReminders.where((r) => !r.isCompleted).toList(),
        );
      }
    }
  }

  void _invalidateAllProviders() {
    ref.invalidate(todayRemindersProvider);
    ref.invalidate(weeklyRemindersProvider);
    ref.invalidate(monthlyRemindersProvider);
    ref.invalidate(allRemindersProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Reminders',
          // style: TextStyle(
          //   color: Colors.black,
          //   fontSize: 22,
          //   fontWeight: FontWeight.bold,
          // ),
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _manualSync,
            icon: Icon(Icons.sync, color: theme.colorScheme.onSurface),
          ),
          IconButton(
            onPressed: () => _showAddReminderDialog(context),
            icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildWeeklyTab(),
          _buildMonthlyTab(),
          _buildAllTab(),
        ],
      ),
    );
  }

  Future<void> _manualSync() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.fullSync(user.id);

      _invalidateAllProviders();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    }
  }

  Widget _buildTodayTab() {
    final remindersAsync = ref.watch(todayRemindersProvider);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildEmptyState('No reminders for today');
        }
        return RefreshIndicator(
          onRefresh: _manualSync,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(
                reminder: reminder,
                onToggle: () => _toggleCompletion(reminder),
                onDelete: () async => await _deleteReminder(reminder.id!),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildWeeklyTab() {
    final remindersAsync = ref.watch(weeklyRemindersProvider);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildEmptyState('No weekly reminders');
        }
        return RefreshIndicator(
          onRefresh: _manualSync,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(
                reminder: reminder,
                onToggle: () => _toggleCompletion(reminder),
                onDelete: () async => await _deleteReminder(reminder.id!),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildMonthlyTab() {
    final remindersAsync = ref.watch(monthlyRemindersProvider);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildEmptyState('No monthly reminders');
        }
        return RefreshIndicator(
          onRefresh: _manualSync,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(
                reminder: reminder,
                onToggle: () => _toggleCompletion(reminder),
                onDelete: () async => await _deleteReminder(reminder.id!),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildAllTab() {
    final remindersAsync = ref.watch(allRemindersProvider);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildEmptyState('No reminders yet');
        }

        final today = <Reminder>[];
        final thisWeek = <Reminder>[];
        final thisMonth = <Reminder>[];
        final later = <Reminder>[];

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final weekEnd = todayStart.add(const Duration(days: 7));
        final monthEnd = DateTime(now.year, now.month + 1, 0);

        for (var reminder in reminders) {
          if (reminder.reminderDate.isBefore(
            todayStart.add(const Duration(days: 1)),
          )) {
            today.add(reminder);
          } else if (reminder.reminderDate.isBefore(weekEnd)) {
            thisWeek.add(reminder);
          } else if (reminder.reminderDate.isBefore(monthEnd)) {
            thisMonth.add(reminder);
          } else {
            later.add(reminder);
          }
        }

        return RefreshIndicator(
          onRefresh: _manualSync,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (today.isNotEmpty) ...[
                _buildSectionHeader('Today'),
                ...today.map(
                  (r) => _buildReminderCard(
                    key: ValueKey('today_${r.id}'),
                    reminder: r,
                    onToggle: () => _toggleCompletion(r),
                    onDelete: () async => await _deleteReminder(r.id!),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (thisWeek.isNotEmpty) ...[
                _buildSectionHeader('This Week'),
                ...thisWeek.map(
                  (r) => _buildReminderCard(
                    key: ValueKey('week_${r.id}'),
                    reminder: r,
                    onToggle: () => _toggleCompletion(r),
                    onDelete: () async => await _deleteReminder(r.id!),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (thisMonth.isNotEmpty) ...[
                _buildSectionHeader('This Month'),
                ...thisMonth.map(
                  (r) => _buildReminderCard(
                    key: ValueKey('month_${r.id}'),
                    reminder: r,
                    onToggle: () => _toggleCompletion(r),
                    onDelete: () async => await _deleteReminder(r.id!),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (later.isNotEmpty) ...[
                _buildSectionHeader('Later'),
                ...later.map(
                  (r) => _buildReminderCard(
                    key: ValueKey('later_${r.id}'),
                    reminder: r,
                    onToggle: () => _toggleCompletion(r),
                    onDelete: () async => await _deleteReminder(r.id!),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        // style: const TextStyle(
        //   fontSize: 18,
        //   fontWeight: FontWeight.bold,
        //   color: Colors.black,
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    Key? key,
    required Reminder reminder,
    required VoidCallback onToggle,
    required Future<void> Function() onDelete,
  }) {
    final icon = _getIconForReminder(reminder.title);
    final color = _getColorForImportance(reminder.importanceLevel);
    final theme = Theme.of(context);

    return Dismissible(
      key: key ?? Key(reminder.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.title,
                          // style: TextStyle(
                          //   fontSize: 16,
                          //   fontWeight: FontWeight.w600,
                          //   color: Colors.black,
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
                      ),
                      if (!reminder.isSynced)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (reminder.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      reminder.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    _formatReminderTime(reminder),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      reminder.isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        reminder.isCompleted
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    reminder.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForReminder(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('walk')) return Icons.pets;
    if (titleLower.contains('feed') || titleLower.contains('food')) {
      return Icons.restaurant;
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return Icons.medication;
    }
    if (titleLower.contains('vet') || titleLower.contains('checkup')) {
      return Icons.local_hospital;
    }
    if (titleLower.contains('groom')) return Icons.content_cut;
    if (titleLower.contains('clean')) return Icons.cleaning_services;
    return Icons.notifications;
  }

  Color _getColorForImportance(String? importance) {
    switch (importance) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _formatReminderTime(Reminder reminder) {
    final time = reminder.reminderDate;

    // Format based on reminder type
    if (reminder.reminderType == 'daily') {
      return 'Daily at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (reminder.reminderType == 'weekly') {
      final dayName = _getDayName(time.weekday);
      return '$dayName at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (reminder.reminderType == 'monthly') {
      return 'Monthly on day ${time.day} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    // One-time reminder
    final now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  Future<void> _toggleCompletion(Reminder reminder) async {
    final db = ref.read(reminderDatabaseProvider);

    if (!reminder.isCompleted) {
      final shouldCreateRecord = await _showCreateMedicalRecordDialog(reminder);

      if (shouldCreateRecord == true) {
        await _createMedicalRecordFromReminder(reminder);
      }
      await _notificationService.cancelNotification(reminder.id!);
    } else {
      final updatedReminder = reminder.copyWith(isCompleted: false);

      await _notificationService.scheduleReminderNotification(updatedReminder);
    }

    await db.toggleCompletion(reminder.id!, !reminder.isCompleted);

    final syncService = ref.read(unifiedSyncServiceProvider);
    await syncService.syncRemindersToSupabase();

    _invalidateAllProviders();
  }

  Future<bool?> _showCreateMedicalRecordDialog(Reminder reminder) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Create Medical Record?'),
            content: Text(
              'Would you like to create a medical record for "${reminder.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Create Record'),
              ),
            ],
          ),
    );
  }

  Future<void> _createMedicalRecordFromReminder(Reminder reminder) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => _MedicalRecordFormDialog(reminder: reminder),
    );

    if (result != null) {
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);

      final record = MedicalRecord(
        id: '',
        petId: reminder.petId,
        recordType: result['recordType'] ?? _inferRecordType(reminder.title),
        title: result['title'] ?? reminder.title,
        description: result['description'],
        date: DateTime.now(),
        veterinarian: result['veterinarian'],
        cost: result['cost'],
        nextDueDate: result['nextDueDate'],
      );

      await medicalRecordDB.createMedicalRecord(record);

      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.syncMedicalRecordsToSupabase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record created!')),
        );
      }
    }
  }

  String _inferRecordType(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('vaccination') || titleLower.contains('vaccine')) {
      return 'vaccination';
    }
    if (titleLower.contains('checkup') || titleLower.contains('vet visit')) {
      return 'checkup';
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return 'medication';
    }
    if (titleLower.contains('surgery')) {
      return 'surgery';
    }
    if (titleLower.contains('groom')) {
      return 'grooming';
    }
    return 'other';
  }

  Future<void> _deleteReminder(String id) async {
    try {
      final db = ref.read(reminderDatabaseProvider);
      await db.deleteReminder(id);

      // Cancel notification
      await _notificationService.cancelNotification(id);

      // Delete from Supabase if online
      final syncService = ref.read(unifiedSyncServiceProvider);
      if (await syncService.hasInternetConnection()) {
        try {
          await syncService.supabase.from('reminders').delete().eq('id', id);
        } catch (e) {
          print('Error deleting from Supabase: $e');
        }
      }

      _invalidateAllProviders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _AddReminderDialog(parentRef: ref);
      },
    );
  }
}

class _AddReminderDialog extends ConsumerStatefulWidget {
  final WidgetRef parentRef;

  const _AddReminderDialog({required this.parentRef});

  @override
  ConsumerState<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<_AddReminderDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedPetId = '';
  String selectedFrequency = 'once';
  String selectedImportance = 'medium';
  DateTime selectedDateTime = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int selectedDayOfWeek = DateTime.now().weekday;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsOfflineProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add New Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Reminder Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            petsAsync.when(
              data: (pets) {
                if (pets.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'No pets available. Please add a pet first.',
                    ),
                  );
                }

                if (selectedPetId.isEmpty && pets.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        selectedPetId = pets.first.id;
                      });
                    }
                  });
                }

                return DropdownButtonFormField<String>(
                  value: selectedPetId.isEmpty ? null : selectedPetId,
                  decoration: InputDecoration(
                    labelText: 'Pet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items:
                      pets.map((pet) {
                        return DropdownMenuItem(
                          value: pet.id,
                          child: Text(pet.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPetId = value ?? '';
                    });
                  },
                );
              },
              loading:
                  () => Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (e, s) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Error loading pets: $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedFrequency,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'once', child: Text('One-time')),
              ],
              onChanged:
                  (value) =>
                      setState(() => selectedFrequency = value ?? 'once'),
            ),
            const SizedBox(height: 15),

            // Dynamic date/time picker based on frequency
            _buildDateTimePicker(),

            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedImportance,
              decoration: InputDecoration(
                labelText: 'Importance',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged:
                  (value) =>
                      setState(() => selectedImportance = value ?? 'medium'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _saveReminder(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Add Reminder'),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    switch (selectedFrequency) {
      case 'daily':
        // Only show time picker for daily reminders
        return TextField(
          decoration: InputDecoration(
            labelText: 'Time',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: const Icon(Icons.access_time),
          ),
          readOnly: true,
          controller: TextEditingController(text: selectedTime.format(context)),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              setState(() {
                selectedTime = time;
              });
            }
          },
        );

      case 'weekly':
        // Show day of week picker + time picker
        return Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedDayOfWeek,
              decoration: InputDecoration(
                labelText: 'Day of Week',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Monday')),
                DropdownMenuItem(value: 2, child: Text('Tuesday')),
                DropdownMenuItem(value: 3, child: Text('Wednesday')),
                DropdownMenuItem(value: 4, child: Text('Thursday')),
                DropdownMenuItem(value: 5, child: Text('Friday')),
                DropdownMenuItem(value: 6, child: Text('Saturday')),
                DropdownMenuItem(value: 7, child: Text('Sunday')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDayOfWeek = value ?? 1;
                });
              },
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.access_time),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: selectedTime.format(context),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
          ],
        );

      case 'monthly':
        // Show day of month picker + time picker
        return Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Day of Month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: 'Day ${selectedDateTime.day}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    selectedDateTime = date;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.access_time),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: selectedTime.format(context),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
          ],
        );

      default:
        // One-time reminder: full date + time picker
        return TextField(
          decoration: InputDecoration(
            labelText: 'Date & Time',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          controller: TextEditingController(
            text:
                '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${selectedTime.format(context)}',
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (time != null) {
                setState(() {
                  selectedDateTime = date;
                  selectedTime = time;
                });
              }
            }
          },
        );
    }
  }

  Future<void> _saveReminder(BuildContext context) async {
    if (titleController.text.isEmpty || selectedPetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    DateTime reminderDateTime;

    // Create reminder date based on frequency type
    switch (selectedFrequency) {
      case 'daily':
        // For daily, store with today's date but the selected time
        final now = DateTime.now();
        reminderDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        break;

      case 'weekly':
        // For weekly, find the next occurrence of the selected day
        final now = DateTime.now();
        int daysUntilTarget = (selectedDayOfWeek - now.weekday) % 7;
        if (daysUntilTarget == 0) {
          // If it's today, check if time has passed
          final todayAtTime = DateTime(
            now.year,
            now.month,
            now.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          if (todayAtTime.isBefore(now)) {
            daysUntilTarget = 7; // Schedule for next week
          }
        }

        reminderDateTime = DateTime(
          now.year,
          now.month,
          now.day + daysUntilTarget,
          selectedTime.hour,
          selectedTime.minute,
        );
        break;

      case 'monthly':
        // For monthly, use the selected day of month with current/next month
        final now = DateTime.now();
        int targetMonth = now.month;
        int targetYear = now.year;

        // If the day has passed this month, schedule for next month
        if (selectedDateTime.day < now.day) {
          targetMonth++;
          if (targetMonth > 12) {
            targetMonth = 1;
            targetYear++;
          }
        } else if (selectedDateTime.day == now.day) {
          // If it's today, check if time has passed
          final todayAtTime = DateTime(
            now.year,
            now.month,
            now.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          if (todayAtTime.isBefore(now)) {
            targetMonth++;
            if (targetMonth > 12) {
              targetMonth = 1;
              targetYear++;
            }
          }
        }

        reminderDateTime = DateTime(
          targetYear,
          targetMonth,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        break;

      default:
        // One-time reminder
        reminderDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
    }

    final reminder = Reminder(
      petId: selectedPetId,
      title: titleController.text,
      description:
          descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
      reminderDate: reminderDateTime,
      reminderType: selectedFrequency,
      importanceLevel: selectedImportance,
    );

    final db = widget.parentRef.read(reminderDatabaseProvider);
    final userProfile = await ref.read(userProfileProviderProvider.future);
    final reminderId = await db.createReminder(reminder);
    final reminderWithId = reminder.copyWith(id: reminderId);
    await NotificationService().scheduleReminderNotification(reminderWithId);

    if (userProfile != null) {
      // Mark as not synced if user is logged in
      NotificationService().setPreferences(userProfile.notificationPreferences);
    }

    // Optional: Schedule early notification (15 mins before)
    await NotificationService().scheduleEarlyNotification(reminderWithId);

    final syncService = widget.parentRef.read(unifiedSyncServiceProvider);
    await syncService.syncRemindersToSupabase();

    widget.parentRef.invalidate(todayRemindersProvider);
    widget.parentRef.invalidate(weeklyRemindersProvider);
    widget.parentRef.invalidate(monthlyRemindersProvider);
    widget.parentRef.invalidate(allRemindersProvider);

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder added!')));
    }
  }
}

class _MedicalRecordFormDialog extends StatefulWidget {
  final Reminder reminder;

  const _MedicalRecordFormDialog({required this.reminder});

  @override
  State<_MedicalRecordFormDialog> createState() =>
      _MedicalRecordFormDialogState();
}

class _MedicalRecordFormDialogState extends State<_MedicalRecordFormDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController veterinarianController;
  late TextEditingController costController;
  String selectedRecordType = 'other';
  DateTime? nextDueDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.reminder.title);
    descriptionController = TextEditingController(
      text: widget.reminder.description ?? '',
    );
    veterinarianController = TextEditingController();
    costController = TextEditingController();
    selectedRecordType = _inferRecordType(widget.reminder.title);
  }

  String _inferRecordType(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('vaccination') || titleLower.contains('vaccine')) {
      return 'vaccination';
    }
    if (titleLower.contains('checkup') || titleLower.contains('vet visit')) {
      return 'checkup';
    }
    if (titleLower.contains('medication') || titleLower.contains('medicine')) {
      return 'medication';
    }
    if (titleLower.contains('surgery')) {
      return 'surgery';
    }
    if (titleLower.contains('groom')) {
      return 'grooming';
    }
    return 'other';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    veterinarianController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Medical Record Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedRecordType,
              decoration: InputDecoration(
                labelText: 'Record Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vaccination',
                  child: Text('Vaccination'),
                ),
                DropdownMenuItem(value: 'checkup', child: Text('Checkup')),
                DropdownMenuItem(
                  value: 'medication',
                  child: Text('Medication'),
                ),
                DropdownMenuItem(value: 'surgery', child: Text('Surgery')),
                DropdownMenuItem(value: 'grooming', child: Text('Grooming')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() => selectedRecordType = value ?? 'other');
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: veterinarianController,
              decoration: InputDecoration(
                labelText: 'Veterinarian (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: costController,
              decoration: InputDecoration(
                labelText: 'Cost (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Next Due Date (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                    nextDueDate != null
                        ? '${nextDueDate!.day}/${nextDueDate!.month}/${nextDueDate!.year}'
                        : '',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) {
                  setState(() => nextDueDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': titleController.text,
              'recordType': selectedRecordType,
              'description':
                  descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
              'veterinarian':
                  veterinarianController.text.isEmpty
                      ? null
                      : veterinarianController.text,
              'cost':
                  costController.text.isEmpty
                      ? null
                      : double.tryParse(costController.text),
              'nextDueDate': nextDueDate,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Save Record'),
        ),
      ],
    );
  }
}
