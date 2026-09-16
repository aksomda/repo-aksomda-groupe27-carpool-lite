import '../entities/trip_entity.dart';

abstract class TripRepository {
  Future<TripEntity> publishTrip({
    required String driverId,
    required String departure,
    required String arrival,

    required double departureLatitude,
    required double departureLongitude,

    required double arrivalLatitude,
    required double arrivalLongitude,

    required DateTime departureDateTime,
    required double pricePerSeat,
    required int totalSeats,
  });

  Stream<List<TripEntity>> searchTrips({
    String? departure,
    String? arrival,
    DateTime? date,
  });

  Future<TripEntity?> getTripById(String tripId);

  Future<TripEntity> updateAvailableSeats({
    required String tripId,
    required int delta,
  });

  Stream<List<TripEntity>> getTripHistory({
    required String driverId,
  });
}