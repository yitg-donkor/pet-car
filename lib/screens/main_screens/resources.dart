import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Models for dynamic data
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String description;
  final String countryCode;
  final bool isCustom;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.countryCode,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'description': description,
    'country_code': countryCode,
    'is_custom': isCustom ? 1 : 0,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'],
        name: json['name'],
        phoneNumber: json['phone_number'],
        description: json['description'],
        countryCode: json['country_code'],
        isCustom: (json['is_custom'] ?? 0) == 1,
      );
}

class ResourceArticle {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String content;
  final List<String> tags;
  final DateTime createdAt;

  ResourceArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'subcategory': subcategory,
    'content': content,
    'tags': tags.join(','),
    'created_at': createdAt.toIso8601String(),
  };

  factory ResourceArticle.fromJson(Map<String, dynamic> json) =>
      ResourceArticle(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        subcategory: json['subcategory'],
        content: json['content'],
        tags: (json['tags'] as String).split(','),
        createdAt: DateTime.parse(json['created_at']),
      );
}

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _userCountry = 'US'; // Default
  bool _isLoadingLocation = true;
  List<EmergencyContact> _emergencyContacts = [];
  List<EmergencyContact> _customContacts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _detectUserLocation();
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectUserLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _userCountry = 'US';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _userCountry = 'US';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          _userCountry = placemarks.first.isoCountryCode ?? 'US';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _userCountry = 'US';
        _isLoadingLocation = false;
      });
    }

    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    // Load default contacts based on country
    final defaultContacts = _getDefaultEmergencyContacts(_userCountry);

    // TODO: Load custom contacts from local database
    // final customContacts = await _loadCustomContactsFromDB();

    setState(() {
      _emergencyContacts = defaultContacts;
      // _customContacts = customContacts;
    });
  }

  List<EmergencyContact> _getDefaultEmergencyContacts(String countryCode) {
    final contactsMap = {
      'US': [
        EmergencyContact(
          id: 'us_poison',
          name: 'Pet Poison Helpline',
          phoneNumber: '+1-855-764-7661',
          description: 'Available 24/7 - Fee may apply',
          countryCode: 'US',
        ),
        EmergencyContact(
          id: 'us_aspca',
          name: 'ASPCA Poison Control',
          phoneNumber: '+1-888-426-4435',
          description: 'Available 24/7 - Fee may apply',
          countryCode: 'US',
        ),
      ],
      'GB': [
        EmergencyContact(
          id: 'gb_vets_now',
          name: 'Vets Now Emergency',
          phoneNumber: '+44-330-223-7777',
          description: 'Available 24/7',
          countryCode: 'GB',
        ),
        EmergencyContact(
          id: 'gb_pdsa',
          name: 'PDSA Pet Aid',
          phoneNumber: '+44-800-731-2502',
          description: 'Charity veterinary service',
          countryCode: 'GB',
        ),
      ],
      'CA': [
        EmergencyContact(
          id: 'ca_poison',
          name: 'Pet Poison Helpline',
          phoneNumber: '+1-855-764-7661',
          description: 'Available 24/7',
          countryCode: 'CA',
        ),
      ],
      'AU': [
        EmergencyContact(
          id: 'au_poison',
          name: 'Animal Poisons Helpline',
          phoneNumber: '+61-1300-869-738',
          description: 'Available 24/7',
          countryCode: 'AU',
        ),
      ],
      'GH': [
        EmergencyContact(
          id: 'gh_vet',
          name: 'Ghana Veterinary Services',
          phoneNumber: '+233-302-665-421',
          description: 'Veterinary Services Directorate',
          countryCode: 'GH',
        ),
        EmergencyContact(
          id: 'gh_emergency',
          name: 'Emergency Services',
          phoneNumber: '193',
          description: 'National emergency number',
          countryCode: 'GH',
        ),
      ],
    };

    return contactsMap[countryCode] ?? contactsMap['US']!;
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.black),
            onPressed: _showLocationSettings,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF4CAF50),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4CAF50),
                tabs: const [
                  Tab(text: 'Emergency'),
                  Tab(text: 'Care Guides'),
                  Tab(text: 'Health'),
                  Tab(text: 'Training'),
                  Tab(text: 'Nutrition'),
                  Tab(text: 'Nearby'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmergencyTab(),
          _buildCareGuidesTab(),
          _buildHealthTab(),
          _buildTrainingTab(),
          _buildNutritionTab(),
          _buildNearbyTab(),
        ],
      ),
    );
  }

  // ============================================
  // EMERGENCY TAB
  // ============================================
  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoadingLocation
                        ? 'Detecting your location...'
                        : 'Showing contacts for: ${_getCountryName(_userCountry)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showLocationSettings,
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Warning Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Case of Emergency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Call emergency services immediately for life-threatening situations',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency Contacts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  const Text(
                    'Emergency Contacts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                onPressed: _addCustomContact,
                tooltip: 'Add custom contact',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Contacts First
          if (_customContacts.isNotEmpty) ...[
            ..._customContacts.map(
              (contact) => _buildEmergencyContactCard(
                contact.name,
                contact.phoneNumber,
                contact.description,
                Colors.purple,
                Icons.person,
                isCustom: true,
                onDelete: () => _deleteCustomContact(contact.id),
              ),
            ),
            const Divider(height: 32),
          ],

          // Default Contacts
          if (_emergencyContacts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No emergency contacts available for your region',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addCustomContact,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your Own'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._emergencyContacts.map(
              (contact) => _buildEmergencyContactCard(
                contact.name,
                contact.phoneNumber,
                contact.description,
                Colors.red,
                Icons.local_hospital,
              ),
            ),

          const SizedBox(height: 16),

          // Find Emergency Vet Button
          ElevatedButton.icon(
            onPressed: () => _findNearbyVets(emergency: true),
            icon: const Icon(Icons.location_searching),
            label: const Text('Find Emergency Vet Near Me'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // First Aid Guide
          Row(
            children: [
              const Icon(Icons.healing, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              const Text(
                'Quick First Aid Guide',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFirstAidCard(
            'Choking',
            'Remove visible object, Heimlich if needed',
            Icons.warning,
            Colors.red,
          ),
          _buildFirstAidCard(
            'Bleeding',
            'Apply pressure, elevate, seek vet',
            Icons.bloodtype,
            Colors.red,
          ),
          _buildFirstAidCard(
            'Poisoning',
            'Call poison control, do NOT induce vomiting',
            Icons.dangerous,
            Colors.orange,
          ),
          _buildFirstAidCard(
            'Seizures',
            'Clear area, time it, stay calm',
            Icons.flash_on,
            Colors.deepOrange,
          ),
          _buildFirstAidCard(
            'Heatstroke',
            'Cool water, shade, vet immediately',
            Icons.thermostat,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  // ============================================
  // OTHER TABS (Simplified for brevity)
  // ============================================

  Widget _buildCareGuidesTab() {
    return _buildComingSoonTab(
      'Care Guides',
      'Comprehensive guides for different species, life stages, and seasonal care will be available here.',
    );
  }

  Widget _buildHealthTab() {
    return _buildComingSoonTab(
      'Health Information',
      'Vaccination schedules, parasite prevention, and common health issues by region.',
    );
  }

  Widget _buildTrainingTab() {
    return _buildComingSoonTab(
      'Training Resources',
      'Training videos, behavior guides, and socialization tips.',
    );
  }

  Widget _buildNutritionTab() {
    return _buildComingSoonTab(
      'Nutrition Guides',
      'Feeding guidelines, safe/unsafe foods, and diet plans tailored to your pet.',
    );
  }

  Widget _buildNearbyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Pet Services Near You',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All services open in Google Maps',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildNearbyServiceCard(
            'Veterinarians',
            'Find general practice vets',
            Icons.medical_services,
            Colors.blue,
            () => _findNearbyVets(),
          ),
          _buildNearbyServiceCard(
            'Emergency Vets',
            '24/7 emergency care',
            Icons.emergency,
            Colors.red,
            () => _findNearbyVets(emergency: true),
          ),
          _buildNearbyServiceCard(
            'Pet Groomers',
            'Grooming services',
            Icons.content_cut,
            Colors.pink,
            () => _findNearbyService('pet groomer'),
          ),
          _buildNearbyServiceCard(
            'Pet Stores',
            'Supplies and food',
            Icons.store,
            Colors.orange,
            () => _findNearbyService('pet store'),
          ),
          _buildNearbyServiceCard(
            'Dog Parks',
            'Off-leash play areas',
            Icons.park,
            Colors.green,
            () => _findNearbyService('dog park'),
          ),
          _buildNearbyServiceCard(
            'Pet Boarding',
            'Overnight care',
            Icons.hotel,
            Colors.indigo,
            () => _findNearbyService('pet boarding'),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================

  Widget _buildEmergencyContactCard(
    String name,
    String phone,
    String description,
    Color color,
    IconData icon, {
    bool isCustom = false,
    VoidCallback? onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isCustom)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CUSTOM',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              phone,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(description, style: const TextStyle(fontSize: 13)),
          ],
        ),
        trailing:
            isCustom
                ? PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.phone, size: 20),
                              SizedBox(width: 12),
                              Text('Call'),
                            ],
                          ),
                          onTap: () => _makePhoneCall(phone),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: onDelete,
                        ),
                      ],
                )
                : IconButton(
                  icon: Icon(Icons.phone, color: color),
                  onPressed: () => _makePhoneCall(phone),
                ),
      ),
    );
  }

  Widget _buildFirstAidCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyServiceCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.location_on, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  // ============================================
  // ACTION METHODS
  // ============================================

  String _getCountryName(String code) {
    final countries = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'GH': 'Ghana',
    };
    return countries[code] ?? code;
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Change Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Detect Automatically'),
                  leading: const Icon(Icons.my_location),
                  onTap: () {
                    Navigator.pop(context);
                    _detectUserLocation();
                  },
                ),
                const Divider(),
                const Text(
                  'Or select manually:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._getAvailableCountries().map(
                  (country) => ListTile(
                    title: Text(country['name']!),
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    selected: _userCountry == country['code'],
                    onTap: () {
                      setState(() {
                        _userCountry = country['code']!;
                      });
                      _loadEmergencyContacts();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  List<Map<String, String>> _getAvailableCountries() {
    return [
      {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
      {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
      {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
      {'code': 'GH', 'name': 'Ghana', 'flag': '🇬🇭'},
    ];
  }

  void _addCustomContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Add Custom Contact'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixText: '+',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty) {
                    final newContact = EmergencyContact(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      phoneNumber: phoneController.text,
                      description: descController.text,
                      countryCode: _userCountry,
                      isCustom: true,
                    );

                    setState(() {
                      _customContacts.add(newContact);
                    });

                    // TODO: Save to local database
                    // _saveCustomContactToDB(newContact);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom contact added!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _deleteCustomContact(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Contact?'),
            content: const Text(
              'Are you sure you want to delete this custom contact?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _customContacts.removeWhere((c) => c.id == id);
                  });

                  // TODO: Delete from local database
                  // _deleteCustomContactFromDB(id);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact deleted')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot make phone call')));
      }
    }
  }

  void _findNearbyVets({bool emergency = false}) async {
    final query = emergency ? 'emergency veterinary clinic' : 'veterinarian';
    final uri = Uri.parse('https://www.google.com/maps/search/$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot open maps')));
      }
    }
  }

  void _findNearbyService(String query) async {
    final uri = Uri.parse('https://www.google.com/maps/search/$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot open maps')));
      }
    }
  }
}
