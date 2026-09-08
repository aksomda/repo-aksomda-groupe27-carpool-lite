import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String driverId;
  final GeoPoint departureLocation; // lat/lng, vient de la géoloc
  final String departureLabel; // ex: "Zogona", "Patte d'Oie" — quartier/zone lisible
  final String universityId; // référence vers features/universities
  final DateTime departureDateTime;
  final int availableSeats;
  final double pricePerSeat;
  final TripStatus status;
  final List<String> passengerIds;

  const Trip({
    required this.id,
    required this.driverId,
    required this.departureLocation,
    required this.departureLabel,
    required this.universityId,
    required this.departureDateTime,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.status,
    this.passengerIds = const [],
  });
}

enum TripStatus { available, full, completed, cancelled }
