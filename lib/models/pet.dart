// models/pet.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_helpers.dart';

class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final DateTime? birthDate;
  final double? weight;
  final String? photoUrl;
  final String? microchipId;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.age,
    this.breed,
    this.birthDate,
    this.weight,
    this.photoUrl,
    this.microchipId,
  });

  factory Pet.fromFirestore(Map<String, dynamic> data, String id) {
    return Pet(
      id: id,
      ownerId: data['ownerId'] as String,
      name: data['name'] as String,
      species: data['species'] as String,
      breed: data['breed'] as String?,
      age: data['age'] as int?,
      birthDate: timestampToDate(data['birthDate']),
      weight: (data['weight'] as num?)?.toDouble(),
      photoUrl: data['photoUrl'] as String?,
      microchipId: data['microchipId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'birthDate': dateToTimestamp(birthDate),
      'weight': weight,
      'photoUrl': photoUrl,
      'microchipId': microchipId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    int? age,
    DateTime? birthDate,
    double? weight,
    String? photoUrl,
    String? microchipId,
  }) {
    return Pet(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      microchipId: microchipId ?? this.microchipId,
    );
  }
}
