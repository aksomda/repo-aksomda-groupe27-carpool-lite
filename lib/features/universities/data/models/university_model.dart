import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/university_entity.dart';

class UniversityModel extends UniversityEntity {
  UniversityModel({
    required super.id,
    required super.name,
    required super.city,
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory UniversityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UniversityModel(
      id: doc.id,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}