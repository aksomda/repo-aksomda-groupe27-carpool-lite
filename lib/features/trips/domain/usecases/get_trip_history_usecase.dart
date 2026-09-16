import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripHistoryUseCase {
  final TripRepository repository;

  GetTripHistoryUseCase(this.repository);

  Stream<List<TripEntity>> call({
    required String driverId,
  }) {
    return repository.getTripHistory(
      driverId: driverId,
    );
  }
}