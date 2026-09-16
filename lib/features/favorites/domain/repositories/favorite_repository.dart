import '../entities/favorite_entity.dart';

abstract class FavoriteRepository {
  /// Flux temps réel des trajets favoris d'un utilisateur.
  Stream<List<FavoriteEntity>> getFavorites(String userId);

  /// Ajoute le trajet aux favoris s'il n'y est pas, l'en retire sinon.
  /// Retourne `true` si le trajet est favori après l'opération.
  Future<bool> toggleFavorite({
    required String userId,
    required String tripId,
    required String departure,
    required String arrival,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required String driverId,
  });

  /// Flux indiquant si un trajet donné est en favori.
  Stream<bool> isFavorite({
    required String userId,
    required String tripId,
  });

  Future<void> removeFavorite({
    required String userId,
    required String tripId,
  });
}
