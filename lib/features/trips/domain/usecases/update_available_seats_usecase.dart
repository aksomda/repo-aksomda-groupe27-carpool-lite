import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class UpdateAvailableSeatsUseCase {
  final TripRepository repository;

  UpdateAvailableSeatsUseCase(this.repository);

  Future<TripEntity> call({
    required String tripId,
    required int delta,
  }) {
    return repository.updateAvailableSeats(
      tripId: tripId,
      delta: delta,
    );
  }
}