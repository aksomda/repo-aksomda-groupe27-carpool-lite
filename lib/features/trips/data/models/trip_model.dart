import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.driverId,
    required super.departureLocation,
    required super.departureLabel,
    required super.universityId,
    required super.departureDateTime,
    required super.availableSeats,
    required super.pricePerSeat,
    required super.status,
    super.passengerIds,
  });

  factory TripModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    if (data == null) {
      throw Exception('Les données du trajet sont introuvables.');
    }

    return TripModel(
      id: document.id,
      driverId: data['driverId'] as String,
      departureLocation: data['departureLocation'] as GeoPoint,
      departureLabel: data['departureLabel'] as String,
      universityId: data['universityId'] as String,
      departureDateTime: (data['departureDateTime'] as Timestamp).toDate(),
      availableSeats: data['availableSeats'] as int,
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
