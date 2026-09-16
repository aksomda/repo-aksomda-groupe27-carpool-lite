import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/ride_request_entity.dart';

class RideRequestModel extends RideRequestEntity {
  const RideRequestModel({
    required super.id,
    required super.tripId,
    required super.passengerId,
    required super.driverId,
    required super.numberOfSeats,
    required super.totalPrice,
    required super.status,
    required super.createdAt,
  });

  factory RideRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return RideRequestModel(
      id: document.id,
      tripId: data['tripId']?.toString() ?? '',
      passengerId: data['passengerId']?.toString() ?? '',
      driverId: data['driverId']?.toString() ?? '',
      numberOfSeats: (data['numberOfSeats'] as num?)?.toInt() ?? 1,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(data['status']),
      createdAt: _dateFromFirestore(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'passengerId': passengerId,
      'driverId': driverId,
      'numberOfSeats': numberOfSeats,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static BookingStatus _statusFromString(dynamic value) {
    switch (value?.toString()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}
