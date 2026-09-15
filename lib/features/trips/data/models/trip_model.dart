// TripModel : mapping Firestore <-> TripEntity.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.driverId,
    required super.immatriculationVehicule,
    required super.lieuDepart,
    required super.lieuArrivee,
    required super.distanceKm,
    required super.prixParPlace,
    required super.createdAt,
  });

  factory TripModel.fromEntity(TripEntity trip) {
    return TripModel(
      id: trip.id,
      driverId: trip.driverId,
      immatriculationVehicule: trip.immatriculationVehicule,
      lieuDepart: trip.lieuDepart,
      lieuArrivee: trip.lieuArrivee,
      distanceKm: trip.distanceKm,
      prixParPlace: trip.prixParPlace,
      createdAt: trip.createdAt,
    );
  }

  factory TripModel.fromFirestore(String id, Map<String, dynamic> data) {
    return TripModel(
      id: id,
      driverId: data['driverId'] ?? '',
      immatriculationVehicule: data['immatriculationVehicule'] ?? '',
      lieuDepart: data['lieuDepart'] ?? '',
      lieuArrivee: data['lieuArrivee'] ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      prixParPlace: (data['prixParPlace'] as num?) ?? 0,
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  /// Accepte soit un [Timestamp] Firestore, soit une chaîne ISO 8601, pour
  /// ne pas planter sur d'éventuels documents écrits différemment.
  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'immatriculationVehicule': immatriculationVehicule,
      'lieuDepart': lieuDepart,
      'lieuArrivee': lieuArrivee,
      'distanceKm': distanceKm,
      'prixParPlace': prixParPlace,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
