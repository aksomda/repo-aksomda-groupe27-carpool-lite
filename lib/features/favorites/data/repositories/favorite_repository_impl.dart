import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<FavoriteEntity>> getFavorites(String userId) {
    return remoteDataSource.getFavorites(userId);
  }

  @override
  Stream<bool> isFavorite({
    required String userId,
    required String tripId,
  }) {
    return remoteDataSource.isFavorite(userId: userId, tripId: tripId);
  }

  @override
  Future<bool> toggleFavorite({
    required String userId,
    required String tripId,
    required String departure,
    required String arrival,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required String driverId,
  }) {
    return remoteDataSource.toggleFavorite(
      userId: userId,
      tripId: tripId,
      departure: departure,
      arrival: arrival,
      departureDateTime: departureDateTime,
      pricePerSeat: pricePerSeat,
      driverId: driverId,
    );
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String tripId,
  }) {
    return remoteDataSource.removeFavorite(userId: userId, tripId: tripId);
  }
}
