import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class SearchTripsUseCase {
  final TripRepository repository;

  SearchTripsUseCase(this.repository);

  Stream<List<TripEntity>> call({
    String? departure,
    String? arrival,
    DateTime? date,
  }) {
    return repository.searchTrips(
      departure: departure,
      arrival: arrival,
      date: date,
    );
  }
}