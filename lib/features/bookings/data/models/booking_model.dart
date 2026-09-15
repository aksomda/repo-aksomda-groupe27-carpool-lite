import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.tripId,
    required super.passengerId,
    required super.driverId,
    required super.numberOfSeats,
    required super.totalPrice,
    required super.status,
    required super.reservationDate,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return BookingModel(
      id: document.id,
      tripId: data['tripId']?.toString() ?? '',
      passengerId: data['passengerId']?.toString() ?? '',
      driverId: data['driverId']?.toString() ?? '',
      numberOfSeats: (data['numberOfSeats'] as num?)?.toInt() ?? 1,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(data['status']),
      reservationDate: _dateFromFirestore(data['reservationDate']),
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
      'reservationDate': Timestamp.fromDate(reservationDate),
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