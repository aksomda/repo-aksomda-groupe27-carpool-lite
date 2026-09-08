import '../entities/trip.dart';

abstract class TripRepository {
  Future<Trip> publishTrip(Trip trip);

  Future<List<Trip>> searchTrips({
    required String departureLabel,
    required String universityId,
    required DateTime date,
  });

  Future<List<Trip>> getTripHistory(String userId);

  Future<void> cancelTrip(String tripId);
}
