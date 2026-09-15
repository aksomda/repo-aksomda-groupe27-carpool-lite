// VehicleModel : mapping Firestore <-> VehicleEntity.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.ownerId,
    required super.immatriculation,
    required super.numeroChassis,
    required super.marque,
    required super.modele,
    required super.categorie,
    required super.nombrePlaces,
  });

  factory VehicleModel.fromEntity(VehicleEntity vehicle) {
    return VehicleModel(
      id: vehicle.id,
      ownerId: vehicle.ownerId,
      immatriculation: vehicle.immatriculation,
      numeroChassis: vehicle.numeroChassis,
      marque: vehicle.marque,
      modele: vehicle.modele,
      categorie: vehicle.categorie,
      nombrePlaces: vehicle.nombrePlaces,
    );
  }

  factory VehicleModel.fromFirestore(String id, Map<String, dynamic> data) {
    return VehicleModel(
      id: id,
      ownerId: data['ownerId'] ?? '',
      immatriculation: data['immatriculation'] ?? '',
      numeroChassis: data['numeroChassis'] ?? '',
      marque: data['marque'] ?? '',
      modele: data['modele'] ?? '',
      categorie: data['categorie'] ?? '',
      nombrePlaces: (data['nombrePlaces'] is int)
          ? data['nombrePlaces'] as int
          : int.tryParse('${data['nombrePlaces'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'immatriculation': immatriculation,
      'numeroChassis': numeroChassis,
      'marque': marque,
      'modele': modele,
      'categorie': categorie,
      'nombrePlaces': nombrePlaces,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
