import '../repositories/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required String tripId,
    required String departure,
    required String arrival,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required String driverId,
  }) {
    return repository.toggleFavorite(
      userId: userId,
      tripId: tripId,
      departure: departure,
      arrival: arrival,
      departureDateTime: departureDateTime,
      pricePerSeat: pricePerSeat,
      driverId: driverId,
    );
  }
}
