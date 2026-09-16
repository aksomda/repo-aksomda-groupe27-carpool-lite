enum TripStatus {
  active,
  completed,
  cancelled,
}

class TripEntity {
  final String id;
  final String driverId;

  final String departure;
  final String arrival;

  // Coordonnées Google Maps
  final double departureLatitude;
  final double departureLongitude;
  final double arrivalLatitude;
  final double arrivalLongitude;

  final DateTime departureDateTime;
  final double pricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final TripStatus status;
  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.driverId,
    required this.departure,
    required this.arrival,
    required this.departureLatitude,
    required this.departureLongitude,
    required this.arrivalLatitude,
    required this.arrivalLongitude,
    required this.departureDateTime,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    required this.createdAt,
  });

  TripEntity copyWith({
    String? id,
    String? driverId,
    String? departure,
    String? arrival,
    double? departureLatitude,
    double? departureLongitude,
    double? arrivalLatitude,
    double? arrivalLongitude,
    DateTime? departureDateTime,
    double? pricePerSeat,
    int? totalSeats,
    int? availableSeats,
    TripStatus? status,
    DateTime? createdAt,
  }) {
    return TripEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      departureLatitude:
          departureLatitude ?? this.departureLatitude,
      departureLongitude:
          departureLongitude ?? this.departureLongitude,
      arrivalLatitude:
          arrivalLatitude ?? this.arrivalLatitude,
      arrivalLongitude:
          arrivalLongitude ?? this.arrivalLongitude,
      departureDateTime:
          departureDateTime ?? this.departureDateTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats:
          availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}