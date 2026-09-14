import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.driverId,
    required super.vehicleId,
    required super.departureLocation,
    required super.departureLabel,
    required super.universityId,
    required super.departureDateTime,
    required super.availableSeats,
    required super.pricePerSeat,
    required super.status,
    super.passengerIds,
  });

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      driverId: trip.driverId,
      vehicleId: trip.vehicleId,
      departureLocation: trip.departureLocation,
      departureLabel: trip.departureLabel,
      universityId: trip.universityId,
      departureDateTime: trip.departureDateTime,
      availableSeats: trip.availableSeats,
      pricePerSeat: trip.pricePerSeat,
      status: trip.status,
      passengerIds: trip.passengerIds,
    );
  }

  factory TripModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return TripModel(
      id: doc.id,

      driverId: data['driverId'] ?? '',

      vehicleId: data['vehicleId'] ?? '',

      departureLocation: data['departureLocation'],

      departureLabel: data['departureLabel'] ?? '',

      universityId: data['universityId'] ?? '',

      departureDateTime: (data['departureDateTime'] as Timestamp).toDate(),

      availableSeats: data['availableSeats'] ?? 0,

      pricePerSeat: (data['pricePerSeat'] as num).toDouble(),

      status: TripStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => TripStatus.available,
      ),

      passengerIds: List<String>.from(data['passengerIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,

      'vehicleId': vehicleId,

      'departureLocation': departureLocation,

      'departureLabel': departureLabel,

      'universityId': universityId,

      'departureDateTime': Timestamp.fromDate(departureDateTime),

      'availableSeats': availableSeats,

      'pricePerSeat': pricePerSeat,

      'status': status.name,

      'passengerIds': passengerIds,
    };
  }
}
