enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class BookingEntity {
  final String id;
  final String tripId;
  final String passengerId;
  final String driverId;
  final int numberOfSeats;
  final double totalPrice;
  final BookingStatus status;
  final DateTime reservationDate;

  const BookingEntity({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    required this.numberOfSeats,
    required this.totalPrice,
    required this.status,
    required this.reservationDate,
  });

  BookingEntity copyWith({
    String? id,
    String? tripId,
    String? passengerId,
    String? driverId,
    int? numberOfSeats,
    double? totalPrice,
    BookingStatus? status,
    DateTime? reservationDate,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      reservationDate: reservationDate ?? this.reservationDate,
    );
  }

  @override
  String toString() {
    return 'BookingEntity('
        'id: $id, '
        'tripId: $tripId, '
        'passengerId: $passengerId, '
        'driverId: $driverId, '
        'numberOfSeats: $numberOfSeats, '
        'totalPrice: $totalPrice, '
        'status: $status, '
        'reservationDate: $reservationDate'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingEntity &&
        other.id == id &&
        other.tripId == tripId &&
        other.passengerId == passengerId &&
        other.driverId == driverId &&
        other.numberOfSeats == numberOfSeats &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.reservationDate == reservationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      tripId,
      passengerId,
      driverId,
      numberOfSeats,
      totalPrice,
      status,
      reservationDate,
    );
  }
}