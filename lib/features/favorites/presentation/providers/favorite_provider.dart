import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

class FavoriteProvider extends ChangeNotifier {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  FavoriteProvider({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.removeFavoriteUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<FavoriteEntity> _favorites = const [];

  /// Identifiants des trajets favoris, pour un test en O(1) depuis
  /// les listes de trajets (bouton cœur).
  Set<String> _favoriteTripIds = const {};

  StreamSubscription<List<FavoriteEntity>>? _subscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<FavoriteEntity> get favorites => _favorites;

  /// Favoris dont la date de départ n'est pas encore passée.
  List<FavoriteEntity> get upcomingFavorites =>
      _favorites.where((favorite) => !favorite.isExpired).toList();

  bool isFavorite(String tripId) => _favoriteTripIds.contains(tripId);

  void loadFavorites(String userId) {
    _subscription?.cancel();

    if (userId.isEmpty) {
      _favorites = const [];
      _favoriteTripIds = const {};
      _isLoading = false;
      _errorMessage = 'Utilisateur non connecté.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _clearMessages();
    notifyListeners();

    _subscription = getFavoritesUseCase(userId).listen(
      (results) {
        _favorites = results;
        _favoriteTripIds =
            results.map((favorite) => favorite.tripId).toSet();
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = messageFromError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Ajoute ou retire le trajet des favoris.
  /// Retourne `true` si le trajet est favori après l'opération.
  Future<bool> toggleFavorite({
    required String userId,
    required String tripId,
    required String departure,
    required String arrival,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required String driverId,
  }) async {
    _clearMessages();

    // Mise à jour optimiste : le cœur réagit immédiatement, sans
    // attendre l'aller-retour Firestore.
    final wasFavorite = isFavorite(tripId);
    _applyLocalToggle(tripId, !wasFavorite);
    notifyListeners();

    try {
      final isNowFavorite = await toggleFavoriteUseCase(
        userId: userId,
        tripId: tripId,
        departure: departure,
        arrival: arrival,
        departureDateTime: departureDateTime,
        pricePerSeat: pricePerSeat,
        driverId: driverId,
      );

      _applyLocalToggle(tripId, isNowFavorite);

      _successMessage = isNowFavorite
          ? 'Trajet ajouté aux favoris.'
          : 'Trajet retiré des favoris.';

      notifyListeners();
      return isNowFavorite;
    } catch (error) {
      // Échec : on rétablit l'état précédent.
      _applyLocalToggle(tripId, wasFavorite);
      _errorMessage = messageFromError(error);
      notifyListeners();
      return wasFavorite;
    }
  }

  Future<bool> removeFavorite({
    required String userId,
    required String tripId,
  }) async {
    _clearMessages();

    try {
      await removeFavoriteUseCase(userId: userId, tripId: tripId);
      _successMessage = 'Trajet retiré des favoris.';
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = messageFromError(error);
      notifyListeners();
      return false;
    }
  }

  void _applyLocalToggle(String tripId, bool isFavorite) {
    final updated = Set<String>.from(_favoriteTripIds);

    if (isFavorite) {
      updated.add(tripId);
    } else {
      updated.remove(tripId);
      _favorites =
          _favorites.where((favorite) => favorite.tripId != tripId).toList();
    }

    _favoriteTripIds = updated;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
