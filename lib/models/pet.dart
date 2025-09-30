// models/pet.dart
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? photoUrl;
  final String? microchipId;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weight,
    this.photoUrl,
    this.microchipId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      birthDate:
          json['birth_date'] != null
              ? DateTime.parse(json['birth_date'])
              : null,
      weight: json['weight']?.toDouble(),
      photoUrl: json['photo_url'],
      microchipId: json['microchip_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'photo_url': photoUrl,
      'microchip_id': microchipId,
    };
  }
}
