import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.tripId,
    required super.departure,
    required super.arrival,
    required super.departureDateTime,
    required super.pricePerSeat,
    required super.driverId,
    required super.createdAt,
  });

  factory FavoriteModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return FavoriteModel(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      tripId: data['tripId']?.toString() ?? '',
      departure: data['departure']?.toString() ?? '',
      arrival: data['arrival']?.toString() ?? '',
      departureDateTime: _toDate(data['departureDateTime']),
      pricePerSeat: (data['pricePerSeat'] as num?)?.toDouble() ?? 0,
      driverId: data['driverId']?.toString() ?? '',
      createdAt: _toDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tripId': tripId,
      'departure': departure,
      'arrival': arrival,
      'departureDateTime': Timestamp.fromDate(departureDateTime),
      'pricePerSeat': pricePerSeat,
      'driverId': driverId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
