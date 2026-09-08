import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class SearchTrips {
  final TripRepository repository;

  SearchTrips(this.repository);

  Future<List<Trip>> call({
    required String departureLabel,
    required String universityId,
    required DateTime date,
  }) {
    return repository.searchTrips(
      departureLabel: departureLabel,
      universityId: universityId,
      date: date,
    );
  }
}
