import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/pet.dart';

import 'package:pet_care/providers/pet_providers.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/services/avatar_upload_service.dart';

class Editpetscreen extends ConsumerStatefulWidget {
  const Editpetscreen({super.key});

  @override
  ConsumerState<Editpetscreen> createState() => _EditpetscreenState();
}

class _EditpetscreenState extends ConsumerState<Editpetscreen> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();

  DateTime? _birthDate;
  String? _photoUrl;
  bool _isUploading = false;
  bool _isSaving = false;
  double _uploadProgress = 0.0;
  bool _isInitialized = false;
  Pet? _displayPet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize only once
    if (!_isInitialized) {
      // Get pet from route arguments
      final Pet? routePet = ModalRoute.of(context)?.settings.arguments as Pet?;
      // Get pet from provider
      final Pet? selectedPet = ref.read(selectedPetProvider);
      // Use routePet if available, otherwise fall back to selectedPet
      _displayPet = routePet ?? selectedPet;

      if (_displayPet != null) {
        _nameController.text = _displayPet!.name;
        _breedController.text = _displayPet!.breed ?? '';
        _weightController.text = _displayPet!.weight?.toString() ?? '';
        _microchipController.text = _displayPet!.microchipId ?? '';
        _birthDate = _displayPet!.birthDate;
        _photoUrl = _displayPet!.photoUrl;
      }

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    if (_isUploading) return;

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Get the avatar upload service
      final supabase = ref.read(supabaseProvider);
      final avatarService = AvatarUploadService(supabase);

      // Show picker dialog
      final imageFile = await avatarService.showImageSourceDialog(context);

      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Get user ID for upload path
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Upload to Supabase storage
      final photoUrl = await avatarService.uploadAvatar(
        userId: 'pets/${user.id}', // Store in pets subfolder
        imageFile: imageFile,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _photoUrl = photoUrl;
      });

      _showSnackBar('Photo uploaded successfully!');
    } catch (e) {
      _showSnackBar('Failed to upload photo: $e', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _updatePet() async {
    if (!_formkey.currentState!.validate()) return;

    if (_displayPet == null) {
      _showSnackBar('No pet to update', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      // Calculate age from birth date if available
      int? calculatedAge;
      if (_birthDate != null) {
        final now = DateTime.now();
        calculatedAge = now.year - _birthDate!.year;
        if (now.month < _birthDate!.month ||
            (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
          calculatedAge--;
        }
      }

      final updatedPet = Pet(
        id: _displayPet!.id,
        ownerId: user.id,
        name: _nameController.text.trim(),
        species: _displayPet!.species,
        breed:
            _breedController.text.trim().isNotEmpty
                ? _breedController.text.trim()
                : null,
        age: calculatedAge,
        birthDate: _birthDate,
        weight:
            _weightController.text.isNotEmpty
                ? double.tryParse(_weightController.text)
                : null,
        photoUrl: _photoUrl,
        microchipId:
            _microchipController.text.trim().isNotEmpty
                ? _microchipController.text.trim()
                : null,
      );

      await ref.read(petsOfflineProvider.notifier).updatePet(updatedPet);

      if (mounted) {
        _showSnackBar('${updatedPet.name} updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Failed to update pet: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _getSpeciesEmoji() {
    if (_displayPet == null) return '🐾';

    switch (_displayPet!.species.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐈';
      case 'bird':
        return '🦜';
      case 'rabbit':
        return '🐰';
      case 'fish':
        return '🐠';
      case 'hamster':
        return '🐹';
      case 'guinea pig':
        return '🐹';
      case 'reptile':
        return '🦎';
      default:
        return '🐾';
    }
  }

  int _calculateAge() {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  String _getBreedHint() {
    if (_displayPet == null) return 'Enter breed';

    switch (_displayPet!.species.toLowerCase()) {
      case 'dog':
        return 'e.g., Golden Retriever, Labrador';
      case 'cat':
        return 'e.g., Persian, Siamese';
      case 'bird':
        return 'e.g., Parrot, Canary';
      case 'rabbit':
        return 'e.g., Holland Lop, Lionhead';
      case 'fish':
        return 'e.g., Goldfish, Betta';
      case 'hamster':
        return 'e.g., Syrian, Dwarf';
      case 'guinea pig':
        return 'e.g., American, Abyssinian';
      case 'reptile':
        return 'e.g., Bearded Dragon, Ball Python';
      default:
        return 'Enter breed';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_displayPet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Pet')),
        body: const Center(child: Text('No pet selected')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit ${_displayPet!.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Species icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getSpeciesEmoji(),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Photo upload
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child:
                              _photoUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      _photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.pets,
                                          size: 50,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                        ),
                        if (_isUploading)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_uploadProgress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Tap to change photo',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),

                const SizedBox(height: 32),

                // Pet Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pets),
                    hintText: 'e.g., Max, Luna, Buddy',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your pet\'s name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Breed
                TextFormField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    labelText: 'Breed (Optional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.description_outlined),
                    hintText: _getBreedHint(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 20),

                // Birth Date
                InkWell(
                  onTap: _selectBirthDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Birth Date (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDate != null
                              ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                              : 'Select birth date',
                          style: TextStyle(
                            color:
                                _birthDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                          ),
                        ),
                        if (_birthDate != null)
                          Text(
                            '${_calculateAge()} ${_calculateAge() == 1 ? "year" : "years"} old',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Weight
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Weight (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    hintText: '0.0',
                    suffixText: 'kg',
                  ),
                ),

                const SizedBox(height: 20),

                // Microchip ID
                TextFormField(
                  controller: _microchipController,
                  decoration: const InputDecoration(
                    labelText: 'Microchip ID (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                    hintText: 'Enter microchip number',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updatePet,
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Update Pet',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes will be saved locally and synced automatically when online.',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
