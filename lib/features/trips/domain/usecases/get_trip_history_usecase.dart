// Cas d'usage : historique des trajets passés d'un utilisateur (fonctionnalité 11).
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripHistoryUseCase {
  final TripRepository repository;

  GetTripHistoryUseCase(this.repository);

  Stream<List<TripEntity>> call(String driverId) {
    return repository.getTripHistory(driverId);
  }
}
