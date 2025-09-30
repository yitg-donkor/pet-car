import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddReminderDialog(context),
            icon: const Icon(Icons.add, color: Colors.black),
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

  Widget _buildTodayTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildReminderCard(
          title: 'Morning Walk',
          subtitle: 'Buddy',
          time: '8:00 AM',
          icon: Icons.pets,
          color: const Color(0xFF4CAF50),
          isCompleted: true,
        ),
        _buildReminderCard(
          title: 'Feed Fish',
          subtitle: 'Nemo',
          time: '9:00 AM',
          icon: Icons.water,
          color: const Color(0xFF2196F3),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Give Medication',
          subtitle: 'Buddy',
          time: '10:00 AM',
          icon: Icons.medication,
          color: const Color(0xFFE53E3E),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Evening Walk',
          subtitle: 'Charlie',
          time: '6:00 PM',
          icon: Icons.pets,
          color: const Color(0xFF4CAF50),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Dinner Time',
          subtitle: 'Whiskers',
          time: '7:00 PM',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildWeeklyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildReminderCard(
          title: 'Grooming Session',
          subtitle: 'Whiskers',
          time: 'Every Sunday, 10:00 AM',
          icon: Icons.content_cut,
          color: const Color(0xFF9C27B0),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Nail Trimming',
          subtitle: 'Buddy',
          time: 'Every 2 weeks, 2:00 PM',
          icon: Icons.cut,
          color: const Color(0xFF607D8B),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Tank Cleaning',
          subtitle: 'Nemo',
          time: 'Every Friday, 5:00 PM',
          icon: Icons.cleaning_services,
          color: const Color(0xFF00BCD4),
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildMonthlyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildReminderCard(
          title: 'Vet Checkup',
          subtitle: 'Buddy',
          time: '26th of every month',
          icon: Icons.local_hospital,
          color: const Color(0xFFE53E3E),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Flea Treatment',
          subtitle: 'Charlie',
          time: '1st of every month',
          icon: Icons.bug_report,
          color: const Color(0xFF795548),
          isCompleted: false,
        ),
        _buildReminderCard(
          title: 'Weight Check',
          subtitle: 'All Pets',
          time: '15th of every month',
          icon: Icons.monitor_weight,
          color: const Color(0xFF3F51B5),
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildAllTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Today's reminders
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          title: 'Morning Walk',
          subtitle: 'Buddy',
          time: '8:00 AM',
          icon: Icons.pets,
          color: const Color(0xFF4CAF50),
          isCompleted: true,
        ),
        _buildReminderCard(
          title: 'Feed Fish',
          subtitle: 'Nemo',
          time: '9:00 AM',
          icon: Icons.water,
          color: const Color(0xFF2196F3),
          isCompleted: false,
        ),

        const SizedBox(height: 20),

        // This week
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          title: 'Grooming Session',
          subtitle: 'Whiskers',
          time: 'Sunday, 10:00 AM',
          icon: Icons.content_cut,
          color: const Color(0xFF9C27B0),
          isCompleted: false,
        ),

        const SizedBox(height: 20),

        // This month
        const Text(
          'This Month',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildReminderCard(
          title: 'Vet Checkup',
          subtitle: 'Buddy',
          time: 'Oct 26, 2:00 PM',
          icon: Icons.local_hospital,
          color: const Color(0xFFE53E3E),
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Complete/Uncomplete button
          GestureDetector(
            onTap: () {
              // Toggle completion logic here
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color:
                      isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add New Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Buddy', child: Text('Buddy')),
                  DropdownMenuItem(value: 'Whiskers', child: Text('Whiskers')),
                  DropdownMenuItem(value: 'Nemo', child: Text('Nemo')),
                  DropdownMenuItem(value: 'Charlie', child: Text('Charlie')),
                ],
                onChanged: (value) {},
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
                onTap: () {
                  // Show time picker
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
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
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add reminder logic here
                Navigator.of(context).pop();
              },
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
      },
    );
  }
}
