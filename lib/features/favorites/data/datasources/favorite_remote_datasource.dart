import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/favorite_model.dart';

class FavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      firestore.collection(FirestorePaths.favorites);

  /// L'identifiant du document est déterministe (`userId_tripId`), ce qui
  /// garantit qu'un même trajet ne peut pas être mis deux fois en favori
  /// par le même utilisateur, sans requête de vérification préalable.
  String _documentId({
    required String userId,
    required String tripId,
  }) =>
      '${userId}_$tripId';

  Stream<List<FavoriteModel>> getFavorites(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const []);
    }

    return _favoritesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final favorites =
          snapshot.docs.map(FavoriteModel.fromFirestore).toList();

      // Tri côté client pour éviter d'exiger un index composite
      // Firestore sur (userId, createdAt).
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return favorites;
    });
  }

  Stream<bool> isFavorite({
    required String userId,
    required String tripId,
  }) {
    if (userId.isEmpty || tripId.isEmpty) {
      return Stream.value(false);
    }

    return _favoritesCollection
        .doc(_documentId(userId: userId, tripId: tripId))
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<bool> toggleFavorite({
    required String userId,
    required String tripId,
    required String departure,
    required String arrival,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required String driverId,
  }) async {
    if (userId.isEmpty) {
      throw Exception('Vous devez être connecté pour gérer vos favoris.');
    }

    if (tripId.isEmpty) {
      throw Exception('Trajet introuvable.');
    }

    final reference = _favoritesCollection.doc(
      _documentId(userId: userId, tripId: tripId),
    );

    final snapshot = await reference.get();

    if (snapshot.exists) {
      await reference.delete();
      return false;
    }

    final favorite = FavoriteModel(
      id: reference.id,
      userId: userId,
      tripId: tripId,
      departure: departure,
      arrival: arrival,
      departureDateTime: departureDateTime,
      pricePerSeat: pricePerSeat,
      driverId: driverId,
      createdAt: DateTime.now(),
    );

    await reference.set(favorite.toFirestore());

    return true;
  }

  Future<void> removeFavorite({
    required String userId,
    required String tripId,
  }) async {
    if (userId.isEmpty || tripId.isEmpty) {
      throw Exception('Favori introuvable.');
    }

    await _favoritesCollection
        .doc(_documentId(userId: userId, tripId: tripId))
        .delete();
  }
}
