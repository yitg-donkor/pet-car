import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/activity_log.dart';
import 'package:pet_care/providers/activity_log_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Activity Log',
          // style: TextStyle(
          //   color: Colors.black,
          //   fontSize: 22,
          //   fontWeight: FontWeight.bold,
          // ),
          style: theme.textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddLogDialog(context),
            icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Health'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDailyTab(), _buildHealthTab(), _buildAllTab()],
      ),
    );
  }

  Widget _buildDailyTab() {
    final dailyLogsAsync = ref.watch(dailyActivityLogsProvider);

    return dailyLogsAsync.when(
      data: (logsMap) {
        final todayLogs = logsMap['today'] ?? [];
        final yesterdayLogs = logsMap['yesterday'] ?? [];

        if (todayLogs.isEmpty && yesterdayLogs.isEmpty) {
          return _buildEmptyState('No activity logged yet');
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (todayLogs.isNotEmpty) ...[
              _buildDateHeader(_formatDate(DateTime.now())),
              ...todayLogs.map((log) => _buildLogEntryFromData(log)),
            ],
            if (yesterdayLogs.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildDateHeader(
                _formatDate(DateTime.now().subtract(const Duration(days: 1))),
              ),
              ...yesterdayLogs.map((log) => _buildLogEntryFromData(log)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildHealthTab() {
    final healthLogsAsync = ref.watch(healthActivityLogsProvider);

    return healthLogsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return _buildEmptyState('No health records yet');
        }

        // Group by week
        final now = DateTime.now();
        final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

        final thisWeekLogs =
            logs.where((log) {
              return log.timestamp.isAfter(thisWeekStart);
            }).toList();

        final lastWeekLogs =
            logs.where((log) {
              return log.timestamp.isAfter(lastWeekStart) &&
                  log.timestamp.isBefore(thisWeekStart);
            }).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (thisWeekLogs.isNotEmpty) ...[
              _buildDateHeader('This Week'),
              ...thisWeekLogs.map((log) => _buildLogEntryFromData(log)),
            ],
            if (lastWeekLogs.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildDateHeader('Last Week'),
              ...lastWeekLogs.map((log) => _buildLogEntryFromData(log)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildAllTab() {
    final theme = Theme.of(context);
    final allLogsAsync = ref.watch(activityLogsOfflineProvider);

    return allLogsAsync.when(
      data: (allLogs) {
        // Filter by search query
        final filteredLogs =
            _searchQuery.isEmpty
                ? allLogs
                : allLogs.where((log) {
                  return log.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      log.details?.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ==
                          true;
                }).toList();

        if (filteredLogs.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isEmpty ? 'No logs yet' : 'No matching logs',
          );
        }

        // Group by date
        final groupedLogs = <String, List<ActivityLog>>{};
        for (var log in filteredLogs) {
          final dateKey = _formatDate(log.timestamp);
          groupedLogs.putIfAbsent(dateKey, () => []).add(log);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Search and filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search logs...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grouped logs by date
            ...groupedLogs.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(entry.key),
                  ...entry.value.map((log) => _buildLogEntryFromData(log)),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLogDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Log Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Text(date, style: theme.textTheme.titleLarge),
    );
  }

  Widget _buildLogEntryFromData(ActivityLog log) {
    final theme = Theme.of(context);
    final activityType = ActivityType.fromString(log.activityType);

    // Get pet name from pet ID
    final petsAsync = ref.watch(petsOfflineProvider);
    final petName =
        petsAsync.whenOrNull(
          data: (pets) {
            final pet = pets.where((p) => p.id == log.petId).firstOrNull;
            return pet?.name ?? 'Unknown Pet';
          },
        ) ??
        'Loading...';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border:
            log.isHealthRelated
                ? Border.all(color: Colors.red.shade200, width: 1)
                : null,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activityType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activityType.icon, color: activityType.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log.title, style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      _formatTime(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (log.isHealthRelated) ...[
                      const SizedBox(width: 5),
                      Icon(
                        Icons.health_and_safety,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$petName${log.duration != null ? ' • ${log.duration} min' : ''}${log.amount != null ? ' • ${log.amount}' : ''}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (log.details != null && log.details!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(log.details!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today - ${DateFormat('MMM d').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday - ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _showAddLogDialog(BuildContext context) {
    final petsAsync = ref.watch(petsOfflineProvider);

    if (petsAsync is AsyncLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading pets... please wait')),
      );
      return;
    }

    if (petsAsync.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pets: ${petsAsync.error}')),
      );
      return;
    }

    final pets = petsAsync.value ?? [];

    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a pet first before logging activities'),
        ),
      );
      return;
    }

    String? selectedActivityType;
    String? selectedPetId = pets.first.id;
    final detailsController = TextEditingController();
    final durationController = TextEditingController();
    final amountController = TextEditingController();
    bool isHealthRelated = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Add Log Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Activity Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedActivityType,
                      items:
                          ActivityType.values.map((type) {
                            return DropdownMenuItem(
                              value: type.value,
                              child: Row(
                                children: [
                                  Icon(type.icon, color: type.color, size: 20),
                                  const SizedBox(width: 8),
                                  Text(type.label),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedActivityType = value;
                          // Auto-check health for certain types
                          if (value == 'health' ||
                              value == 'vet' ||
                              value == 'medication' ||
                              value == 'weight') {
                            isHealthRelated = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Pet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedPetId,
                      items:
                          pets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.id,
                              child: Text(pet.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPetId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    if (selectedActivityType == 'walk' ||
                        selectedActivityType == 'playtime') ...[
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    if (selectedActivityType == 'meal' ||
                        selectedActivityType == 'medication') ...[
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: 'e.g., 1 cup, 2 pills',
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Add any notes or observations...',
                      ),
                    ),
                    const SizedBox(height: 15),
                    CheckboxListTile(
                      title: const Text('Health-related'),
                      value: isHealthRelated,
                      onChanged: (value) {
                        setDialogState(() {
                          isHealthRelated = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedActivityType == null || selectedPetId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select activity type and pet'),
                        ),
                      );
                      return;
                    }

                    final activityType = ActivityType.fromString(
                      selectedActivityType!,
                    );

                    final log = ActivityLog(
                      id: '',
                      petId: selectedPetId!,
                      activityType: selectedActivityType!,
                      title: activityType.label,
                      details:
                          detailsController.text.isNotEmpty
                              ? detailsController.text
                              : null,
                      timestamp: DateTime.now(),
                      duration:
                          durationController.text.isNotEmpty
                              ? int.tryParse(durationController.text)
                              : null,
                      amount:
                          amountController.text.isNotEmpty
                              ? amountController.text
                              : null,
                      isHealthRelated: isHealthRelated,
                      lastModified: DateTime.now(),
                      createdAt: DateTime.now(),
                    );

                    await ref
                        .read(activityLogsOfflineProvider.notifier)
                        .addLog(log);

                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Log entry added successfully'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add Entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
