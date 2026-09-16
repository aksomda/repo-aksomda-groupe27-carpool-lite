import '../repositories/favorite_repository.dart';

class RemoveFavoriteUseCase {
  final FavoriteRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String tripId,
  }) {
    return repository.removeFavorite(userId: userId, tripId: tripId);
  }
}
