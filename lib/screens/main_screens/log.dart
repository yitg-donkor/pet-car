import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/models/activity_log.dart';
import 'package:pet_care/theme/app_theme.dart';
import 'package:pet_care/widgets/widgets.dart';

import 'package:pet_care/providers/firestore_providers.dart';

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
    final sky = SkyColors.of(context);
    final dailyLogsAsync = ref.watch(dailyActivityLogsProvider);
    final todayLogs = dailyLogsAsync.valueOrNull?['today'] ?? [];

    int countOf(String type) =>
        todayLogs.where((l) => l.activityType == type).length;
    final walkMinutes = todayLogs
        .where((l) => l.activityType == 'walk')
        .fold<int>(0, (sum, l) => sum + (l.duration ?? 0));

    return Scaffold(
      backgroundColor: sky.pageBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: SkyHeader(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today',
                        style: GoogleFonts.dmSans(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showAddLogDialog(context),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Log',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Activity Log',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SkyStatChip(
                          icon: Icons.directions_walk,
                          value: '${countOf('walk')}',
                          label: 'today \u00b7 Walks',
                          variant: SkyStatChipVariant.onHeader,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SkyStatChip(
                          icon: Icons.restaurant,
                          value: '${countOf('meal')}',
                          label: 'fed \u00b7 Meals',
                          variant: SkyStatChipVariant.onHeader,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SkyStatChip(
                          icon: Icons.toys,
                          value: '$walkMinutes',
                          label: 'min \u00b7 Play',
                          variant: SkyStatChipVariant.onHeader,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SkyStatChip(
                          icon: Icons.medication,
                          value: '${countOf('medication')}',
                          label: 'given \u00b7 Meds',
                          variant: SkyStatChipVariant.onHeader,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: sky.header,
                unselectedLabelColor: sky.textSecondary,
                indicatorColor: sky.header,
                labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.dmSans(),
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Health'),
                  Tab(text: 'All'),
                ],
              ),
              backgroundColor: sky.pageBackground,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildDailyTab(), _buildHealthTab(), _buildAllTab()],
        ),
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
    final allLogsAsync = ref.watch(activityLogsControllerProvider);

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
                  child: Builder(
                    builder: (context) {
                      final sky = SkyColors.of(context);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: sky.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: sky.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.dmSans(),
                          decoration: InputDecoration(
                            hintText: 'Search logs...',
                            hintStyle: GoogleFonts.dmSans(color: sky.textSecondary),
                            prefixIcon:
                                Icon(Icons.search, color: sky.textSecondary),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Builder(
                  builder: (context) {
                    final sky = SkyColors.of(context);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sky.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sky.border),
                      ),
                      child: Icon(Icons.filter_list, color: sky.textSecondary),
                    );
                  },
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
      child: SkyEmptyState(
        icon: Icons.pets,
        title: message,
        subtitle: 'Tap + to add your first entry',
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkySectionHeader(label: date),
    );
  }

  Widget _buildLogEntryFromData(ActivityLog log) {
    final activityType = ActivityType.fromString(log.activityType);
    final petsAsync = ref.watch(petsControllerProvider);
    final petName =
        petsAsync.whenOrNull(
          data: (pets) {
            final pet = pets.where((p) => p.id == log.petId).firstOrNull;
            return pet?.name ?? 'Unknown Pet';
          },
        ) ??
        'Loading...';

    final subtitleParts = [
      petName,
      if (log.duration != null) '${log.duration} min',
      if (log.amount != null) log.amount!,
      if (log.details != null && log.details!.isNotEmpty) log.details!,
    ];

    return SkyTimelineItem(
      icon: activityType.icon,
      title: log.title,
      subtitle: subtitleParts.join(' \u00b7 '),
      time: _formatTime(log.timestamp),
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

  void _showAddLogDialog(BuildContext context) async {
    // Use .future to wait for pets to load
    try {
      final pets = await ref.read(petsControllerProvider.future);

      if (!mounted) return;

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
                                    Icon(
                                      type.icon,
                                      color: type.color,
                                      size: 20,
                                    ),
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
                      if (selectedActivityType == null ||
                          selectedPetId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select activity type and pet',
                            ),
                          ),
                        );
                        return;
                      }

                      final activityType = ActivityType.fromString(
                        selectedActivityType!,
                      );

                      final user = ref.read(currentUserProvider);
                      if (user == null) return;

                      final log = ActivityLog(
                        id: '',
                        petId: selectedPetId!,
                        ownerId: user.uid,
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
                        createdAt: DateTime.now(),
                      );

                      await ref
                          .read(activityLogsControllerProvider.notifier)
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading pets: $e')));
    }
  }
}

/// Wraps a TabBar so it can pin below the SkyHeader in a NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, {required this.backgroundColor});

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar || oldDelegate.backgroundColor != backgroundColor;
}