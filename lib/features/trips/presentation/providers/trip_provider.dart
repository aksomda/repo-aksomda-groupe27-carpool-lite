import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/get_trip_history_usecase.dart';
import '../../domain/usecases/publish_trip_usecase.dart';
import '../../domain/usecases/search_trips_usecase.dart';
import '../../domain/usecases/update_available_seats_usecase.dart';

class TripProvider extends ChangeNotifier {
  final PublishTripUseCase publishTripUseCase;
  final SearchTripsUseCase searchTripsUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;
  final UpdateAvailableSeatsUseCase updateAvailableSeatsUseCase;

  TripProvider({
    required this.publishTripUseCase,
    required this.searchTripsUseCase,
    required this.getTripHistoryUseCase,
    required this.updateAvailableSeatsUseCase,
  });

  bool _isPublishing = false;
  String? _errorMessage;
  String? _successMessage;

  List<TripEntity> _searchResults = [];
  List<TripEntity> _tripHistory = [];

  StreamSubscription<List<TripEntity>>? _searchSubscription;
  StreamSubscription<List<TripEntity>>? _historySubscription;

  bool get isPublishing => _isPublishing;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  List<TripEntity> get searchResults => _searchResults;

  List<TripEntity> get tripHistory => _tripHistory;

  // ============================================================
  // PUBLICATION D'UN TRAJET
  // ============================================================

  Future<TripEntity?> publishTrip({
    required String driverId,
    required String departure,
    required String arrival,
    required double departureLatitude,
    required double departureLongitude,
    required double arrivalLatitude,
    required double arrivalLongitude,
    required DateTime departureDateTime,
    required double pricePerSeat,
    required int totalSeats,
  }) async {
    _isPublishing = true;
    _clearMessages();
    notifyListeners();

    try {
      final trip = await publishTripUseCase(
        driverId: driverId,
        departure: departure,
        arrival: arrival,
        departureLatitude: departureLatitude,
        departureLongitude: departureLongitude,
        arrivalLatitude: arrivalLatitude,
        arrivalLongitude: arrivalLongitude,
        departureDateTime: departureDateTime,
        pricePerSeat: pricePerSeat,
        totalSeats: totalSeats,
      );

      _successMessage = 'Trajet publié avec succès.';

      return trip;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  // ============================================================
  // RECHERCHE DE TRAJETS
  // ============================================================

  void searchTrips({
    String? departure,
    String? arrival,
    DateTime? date,
  }) {
    _searchSubscription?.cancel();

    _searchSubscription = searchTripsUseCase(
      departure: departure,
      arrival: arrival,
      date: date,
    ).listen(
      (trips) {
        _searchResults = trips;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _cleanError(error);
        notifyListeners();
      },
    );
  }

  // ============================================================
  // HISTORIQUE DES TRAJETS D'UN CONDUCTEUR
  // ============================================================

  void listenToTripHistory({
    required String driverId,
  }) {
    _historySubscription?.cancel();

    _historySubscription = getTripHistoryUseCase(
      driverId: driverId,
    ).listen(
      (trips) {
        _tripHistory = trips;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _cleanError(error);
        notifyListeners();
      },
    );
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }
}
