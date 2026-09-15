// RideRequestModel : mapping Firestore <-> RideRequestEntity.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ride_request_entity.dart';

class RideRequestModel extends RideRequestEntity {
  const RideRequestModel({
    required super.id,
    required super.tripId,
    required super.driverId,
    required super.passengerId,
    required super.lieuDepart,
    required super.lieuArrivee,
    required super.nombrePlaces,
    required super.statut,
    required super.dateDemande,
  });

  factory RideRequestModel.fromEntity(RideRequestEntity request) {
    return RideRequestModel(
      id: request.id,
      tripId: request.tripId,
      driverId: request.driverId,
      passengerId: request.passengerId,
      lieuDepart: request.lieuDepart,
      lieuArrivee: request.lieuArrivee,
      nombrePlaces: request.nombrePlaces,
      statut: request.statut,
      dateDemande: request.dateDemande,
    );
  }

  factory RideRequestModel.fromFirestore(String id, Map<String, dynamic> data) {
    return RideRequestModel(
      id: id,
      tripId: data['tripId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      lieuDepart: data['lieuDepart'] ?? '',
      lieuArrivee: data['lieuArrivee'] ?? '',
      nombrePlaces: (data['nombrePlaces'] is int)
          ? data['nombrePlaces'] as int
          : int.tryParse('${data['nombrePlaces'] ?? 0}') ?? 0,
      statut: RideRequestStatusX.fromValue(data['statut'] ?? 'en_attente'),
      dateDemande: _parseDate(data['dateDemande']),
    );
  }

  /// Accepte soit un [Timestamp] Firestore, soit une chaîne ISO 8601, pour
  /// ne pas planter sur d'éventuels documents écrits différemment.
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'driverId': driverId,
      'passengerId': passengerId,
      'lieuDepart': lieuDepart,
      'lieuArrivee': lieuArrivee,
      'nombrePlaces': nombrePlaces,
      'statut': statut.value,
      'dateDemande': Timestamp.fromDate(dateDemande),
    };
  }
}
