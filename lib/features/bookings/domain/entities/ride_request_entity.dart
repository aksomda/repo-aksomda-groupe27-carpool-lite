import 'booking_entity.dart';

class RideRequestEntity {
  final String id;
  final String tripId;
  final String passengerId;
  final String driverId;
  final int numberOfSeats;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  const RideRequestEntity({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    required this.numberOfSeats,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  RideRequestEntity copyWith({
    String? id,
    String? tripId,
    String? passengerId,
    String? driverId,
    int? numberOfSeats,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return RideRequestEntity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}