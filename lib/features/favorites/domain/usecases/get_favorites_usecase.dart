import '../entities/favorite_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository repository;

  GetFavoritesUseCase(this.repository);

  Stream<List<FavoriteEntity>> call(String userId) {
    return repository.getFavorites(userId);
  }
}
