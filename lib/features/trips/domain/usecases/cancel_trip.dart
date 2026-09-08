import '../repositories/trip_repository.dart';

class CancelTrip {
  final TripRepository repository;

  CancelTrip(this.repository);

  Future<void> call(String tripId) {
    return repository.cancelTrip(tripId);
  }
}
