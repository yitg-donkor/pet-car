import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Activity Log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddLogDialog(context),
            icon: const Icon(Icons.add, color: Colors.black),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDateHeader('Today - Sept 28'),
        _buildLogEntry(
          title: 'Morning Walk',
          subtitle: 'Buddy • 30 minutes',
          time: '8:15 AM',
          icon: Icons.directions_walk,
          color: const Color(0xFF4CAF50),
          details: 'Great energy, played at the park',
        ),
        _buildLogEntry(
          title: 'Breakfast',
          subtitle: 'Whiskers • 1 cup dry food',
          time: '8:30 AM',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
          details: 'Ate everything, seemed happy',
        ),
        _buildLogEntry(
          title: 'Bathroom Break',
          subtitle: 'Charlie • Outside',
          time: '10:20 AM',
          icon: Icons.grass,
          color: const Color(0xFF8BC34A),
          details: 'Normal, no issues',
        ),
        _buildLogEntry(
          title: 'Medication',
          subtitle: 'Buddy • Heart medication',
          time: '2:00 PM',
          icon: Icons.medication,
          color: const Color(0xFFE53E3E),
          details: 'Took with treat, no resistance',
        ),

        const SizedBox(height: 20),
        _buildDateHeader('Yesterday - Sept 27'),
        _buildLogEntry(
          title: 'Evening Walk',
          subtitle: 'Buddy • 25 minutes',
          time: '6:00 PM',
          icon: Icons.directions_walk,
          color: const Color(0xFF4CAF50),
          details: 'Tired earlier than usual',
        ),
        _buildLogEntry(
          title: 'Playtime',
          subtitle: 'Whiskers • 15 minutes',
          time: '7:30 PM',
          icon: Icons.toys,
          color: const Color(0xFF9C27B0),
          details: 'Laser pointer, very active',
        ),
      ],
    );
  }

  Widget _buildHealthTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDateHeader('This Week'),
        _buildLogEntry(
          title: 'Weight Check',
          subtitle: 'Buddy • 32.5 kg',
          time: 'Sept 25',
          icon: Icons.monitor_weight,
          color: const Color(0xFF3F51B5),
          details: 'Gained 0.5kg since last month',
          isHealth: true,
        ),
        _buildLogEntry(
          title: 'Behavioral Change',
          subtitle: 'Charlie • Less active',
          time: 'Sept 24',
          icon: Icons.psychology,
          color: const Color(0xFFFF5722),
          details: 'Sleeping more, eating normally',
          isHealth: true,
        ),
        _buildLogEntry(
          title: 'Skin Irritation',
          subtitle: 'Whiskers • Back area',
          time: 'Sept 22',
          icon: Icons.healing,
          color: const Color(0xFFE91E63),
          details: 'Small red patch, applied ointment',
          isHealth: true,
        ),

        const SizedBox(height: 20),
        _buildDateHeader('Last Week'),
        _buildLogEntry(
          title: 'Vaccination',
          subtitle: 'Buddy • Annual shots',
          time: 'Sept 18',
          icon: Icons.medical_services,
          color: const Color(0xFF009688),
          details: 'All vaccines up to date',
          isHealth: true,
        ),
        _buildLogEntry(
          title: 'Dental Cleaning',
          subtitle: 'Charlie • Professional cleaning',
          time: 'Sept 16',
          icon: Icons.clean_hands,
          color: const Color(0xFF795548),
          details: 'Minor plaque buildup removed',
          isHealth: true,
        ),
      ],
    );
  }

  Widget _buildAllTab() {
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
                  color: Colors.white,
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
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
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

        // All entries combined
        _buildDateHeader('Today - Sept 28'),
        _buildLogEntry(
          title: 'Morning Walk',
          subtitle: 'Buddy • 30 minutes',
          time: '8:15 AM',
          icon: Icons.directions_walk,
          color: const Color(0xFF4CAF50),
          details: 'Great energy, played at the park',
        ),
        _buildLogEntry(
          title: 'Breakfast',
          subtitle: 'Whiskers • 1 cup dry food',
          time: '8:30 AM',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
          details: 'Ate everything, seemed happy',
        ),

        const SizedBox(height: 20),
        _buildDateHeader('Yesterday - Sept 27'),
        _buildLogEntry(
          title: 'Weight Check',
          subtitle: 'Buddy • 32.5 kg',
          time: '2:00 PM',
          icon: Icons.monitor_weight,
          color: const Color(0xFF3F51B5),
          details: 'Gained 0.5kg since last month',
          isHealth: true,
        ),
        _buildLogEntry(
          title: 'Evening Walk',
          subtitle: 'Charlie • 25 minutes',
          time: '6:00 PM',
          icon: Icons.directions_walk,
          color: const Color(0xFF4CAF50),
          details: 'Tired earlier than usual',
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLogEntry({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required String details,
    bool isHealth = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border:
            isHealth ? Border.all(color: Colors.red.shade200, width: 1) : null,
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (isHealth) ...[
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
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  details,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Log Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'walk', child: Text('Walk')),
                  DropdownMenuItem(value: 'meal', child: Text('Meal')),
                  DropdownMenuItem(value: 'bathroom', child: Text('Bathroom')),
                  DropdownMenuItem(
                    value: 'medication',
                    child: Text('Medication'),
                  ),
                  DropdownMenuItem(value: 'playtime', child: Text('Playtime')),
                  DropdownMenuItem(
                    value: 'health',
                    child: Text('Health Incident'),
                  ),
                  DropdownMenuItem(value: 'grooming', child: Text('Grooming')),
                  DropdownMenuItem(value: 'vet', child: Text('Vet Visit')),
                ],
                onChanged: (value) {},
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
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Add any notes or observations...',
                ),
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
                // Add log entry logic here
                Navigator.of(context).pop();
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
  }
}
