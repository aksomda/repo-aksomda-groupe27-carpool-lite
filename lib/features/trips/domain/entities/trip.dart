import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus { available, cancelled }

class Trip {
  final String id;
  final String driverId;
  final String vehicleId;

  final GeoPoint departureLocation;
  final String departureLabel;
  final String universityId;

  final DateTime departureDateTime;

  final int availableSeats;
  final double pricePerSeat;

  final TripStatus status;

  final List<String> passengerIds;

  const Trip({
    required this.id,
    required this.driverId,
    required this.vehicleId,
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
