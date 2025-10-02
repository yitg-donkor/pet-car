import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Resources',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
                hintText: 'Search resources...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          // Emergency Section
          _buildSectionHeader('Emergency', Icons.emergency, Colors.red),
          const SizedBox(height: 10),
          _buildEmergencyCard(
            title: '24/7 Emergency Vet',
            subtitle: 'City Animal Hospital',
            phone: '+233 24 123 4567',
            address: '123 Ring Road, Accra',
            icon: Icons.local_hospital,
          ),
          _buildEmergencyCard(
            title: 'Pet Poison Control',
            subtitle: 'Animal Poison Helpline',
            phone: '+233 30 987 6543',
            address: '24/7 Hotline Available',
            icon: Icons.warning,
          ),

          const SizedBox(height: 25),

          // Care Guides Section
          _buildSectionHeader(
            'Care Guides',
            Icons.book,
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildResourceCard(
                  title: 'Dog Care',
                  subtitle: '15 Guides',
                  icon: Icons.pets,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResourceCard(
                  title: 'Cat Care',
                  subtitle: '12 Guides',
                  icon: Icons.pets,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildResourceCard(
                  title: 'Fish Care',
                  subtitle: '8 Guides',
                  icon: Icons.water,
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResourceCard(
                  title: 'First Aid',
                  subtitle: '10 Guides',
                  icon: Icons.healing,
                  color: const Color(0xFFE53E3E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Local Services Section
          _buildSectionHeader(
            'Local Services',
            Icons.location_on,
            const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 10),
          _buildServiceCard(
            title: 'Pawsome Grooming',
            subtitle: 'Pet Grooming',
            rating: 4.8,
            distance: '2.3 km away',
            phone: '+233 24 555 0123',
            icon: Icons.content_cut,
            color: const Color(0xFF9C27B0),
          ),
          _buildServiceCard(
            title: 'Happy Tails Pet Store',
            subtitle: 'Pet Supplies',
            rating: 4.6,
            distance: '1.8 km away',
            phone: '+233 30 555 0456',
            icon: Icons.store,
            color: const Color(0xFF4CAF50),
          ),
          _buildServiceCard(
            title: 'Central Park Dog Run',
            subtitle: 'Dog Park',
            rating: 4.5,
            distance: '3.2 km away',
            phone: 'Open 6 AM - 8 PM',
            icon: Icons.park,
            color: const Color(0xFF8BC34A),
          ),

          const SizedBox(height: 25),

          // Training & Tips Section
          _buildSectionHeader(
            'Training & Tips',
            Icons.psychology,
            const Color(0xFF607D8B),
          ),
          const SizedBox(height: 10),
          _buildTipCard(
            title: 'House Training Basics',
            subtitle: 'Essential tips for new pet owners',
            readTime: '5 min read',
            difficulty: 'Beginner',
          ),
          _buildTipCard(
            title: 'Separation Anxiety Solutions',
            subtitle: 'Help your pet feel comfortable alone',
            readTime: '8 min read',
            difficulty: 'Intermediate',
          ),
          _buildTipCard(
            title: 'Advanced Obedience Training',
            subtitle: 'Take your pet\'s training to the next level',
            readTime: '12 min read',
            difficulty: 'Advanced',
          ),

          const SizedBox(height: 25),

          // Nutrition Section
          _buildSectionHeader(
            'Nutrition',
            Icons.restaurant,
            const Color(0xFFFF5722),
          ),
          const SizedBox(height: 10),
          _buildNutritionCard(
            title: 'Age-Appropriate Feeding',
            subtitle: 'Puppy to senior nutrition guide',
            calories: 'Calorie calculator included',
          ),
          _buildNutritionCard(
            title: 'Special Dietary Needs',
            subtitle: 'Food allergies and restrictions',
            calories: 'Ingredient checker',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String subtitle,
    required String phone,
    required String address,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
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
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.blue.shade600),
                    const SizedBox(width: 5),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // Call functionality
            icon: const Icon(Icons.call, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Column(
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
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required double rating,
    required String distance,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required String title,
    required String subtitle,
    required String readTime,
    required String difficulty,
  }) {
    Color difficultyColor =
        difficulty == 'Beginner'
            ? Colors.green
            : difficulty == 'Intermediate'
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                readTime,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard({
    required String title,
    required String subtitle,
    required String calories,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.orange.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  calories,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
