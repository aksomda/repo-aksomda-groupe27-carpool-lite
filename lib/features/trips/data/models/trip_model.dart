import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.driverId,
    required super.departure,
    required super.arrival,
    required super.departureLatitude,
    required super.departureLongitude,
    required super.arrivalLatitude,
    required super.arrivalLongitude,
    required super.departureDateTime,
    required super.pricePerSeat,
    required super.totalSeats,
    required super.availableSeats,
    required super.status,
    required super.createdAt,
  });

  factory TripModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return TripModel(
      id: document.id,
      driverId: data['driverId']?.toString() ?? '',
      departure: data['departure']?.toString() ?? '',
      arrival: data['arrival']?.toString() ?? '',

      departureLatitude:
          (data['departureLatitude'] as num?)?.toDouble() ?? 0,

      departureLongitude:
          (data['departureLongitude'] as num?)?.toDouble() ?? 0,

      arrivalLatitude:
          (data['arrivalLatitude'] as num?)?.toDouble() ?? 0,

      arrivalLongitude:
          (data['arrivalLongitude'] as num?)?.toDouble() ?? 0,

      departureDateTime:
          _toDate(data['departureDateTime']),

      pricePerSeat:
          (data['pricePerSeat'] as num?)?.toDouble() ?? 0,

      totalSeats:
          (data['totalSeats'] as num?)?.toInt() ?? 1,

      availableSeats:
          (data['availableSeats'] as num?)?.toInt() ?? 1,

      status:
          _statusFromString(data['status']),

      createdAt:
          _toDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,

      'departure': departure,
      'arrival': arrival,

      'departureLatitude': departureLatitude,
      'departureLongitude': departureLongitude,

      'arrivalLatitude': arrivalLatitude,
      'arrivalLongitude': arrivalLongitude,

      'departureDateTime':
          Timestamp.fromDate(departureDateTime),

      'pricePerSeat': pricePerSeat,

      'totalSeats': totalSeats,
      'availableSeats': availableSeats,

      'status': status.name,

      'createdAt':
          Timestamp.fromDate(createdAt),
    };
  }

  static TripStatus _statusFromString(dynamic value) {
    switch (value?.toString()) {
      case 'completed':
        return TripStatus.completed;

      case 'cancelled':
        return TripStatus.cancelled;

      case 'active':
      default:
        return TripStatus.active;
    }
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}