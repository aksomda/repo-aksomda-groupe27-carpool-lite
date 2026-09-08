import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class PublishTrip {
  final TripRepository repository;

  PublishTrip(this.repository);

  Future<Trip> call(Trip trip) {
    return repository.publishTrip(trip);
  }
}
