import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripHistory {
  final TripRepository repository;

  GetTripHistory(this.repository);

  Future<List<Trip>> call(String userId) {
    return repository.getTripHistory(userId);
  }
}
