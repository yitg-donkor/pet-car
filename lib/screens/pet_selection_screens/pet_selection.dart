import 'package:flutter/material.dart';
import 'package:pet_care/screens/pet_selection_screens/pet_details.dart';

class PetSpeciesSelectionScreen extends StatelessWidget {
  const PetSpeciesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petTypes = [
      PetType(name: 'Dog', icon: '🐕', color: Colors.amber),
      PetType(name: 'Cat', icon: '🐈', color: Colors.purple),
      PetType(name: 'Bird', icon: '🕊️', color: Colors.blue),
      PetType(name: 'Rabbit', icon: '🐰', color: Colors.pink),
      PetType(name: 'Fish', icon: '🐠', color: Colors.cyan),
      PetType(name: 'Hamster', icon: '🐹', color: Colors.orange),
      PetType(name: 'Guinea Pig', icon: '🐹', color: Colors.brown),
      PetType(name: 'Reptile', icon: '🦎', color: Colors.green),
      PetType(name: 'Other', icon: '🐾', color: Colors.grey),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Your Pet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              // Skip and go to home
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What type of pet do you have?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your pet species to get started',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Grid of pet types
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: petTypes.length,
                  itemBuilder: (context, index) {
                    final petType = petTypes[index];
                    return _PetTypeCard(
                      petType: petType,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PetDetailsScreen(species: petType.name),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Add multiple pets hint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can add multiple pets after completing this setup',
                        style: TextStyle(color: Colors.blue[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetTypeCard extends StatelessWidget {
  final PetType petType;
  final VoidCallback onTap;

  const _PetTypeCard({required this.petType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: petType.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: petType.color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(petType.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              petType.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: petType.color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PetType {
  final String name;
  final String icon;
  final Color color;

  PetType({required this.name, required this.icon, required this.color});
}
