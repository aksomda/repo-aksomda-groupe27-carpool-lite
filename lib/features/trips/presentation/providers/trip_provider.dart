import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/get_trip_history_usecase.dart';
import '../../domain/usecases/publish_trip_usecase.dart';
import '../../domain/usecases/search_trips_usecase.dart';

class TripProvider extends ChangeNotifier {
  final PublishTripUseCase publishTripUseCase;
  final SearchTripsUseCase searchTripsUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;

  TripProvider({
    required this.publishTripUseCase,
    required this.searchTripsUseCase,
    required this.getTripHistoryUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<TripEntity> _trips = [];
  List<TripEntity> _tripHistory = [];

  StreamSubscription<List<TripEntity>>? _searchSubscription;
  StreamSubscription<List<TripEntity>>? _historySubscription;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<TripEntity> get trips => _trips;
  List<TripEntity> get tripHistory => _tripHistory;

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
    _setLoading(true);
    _clearMessages();

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
      _trips = [trip, ..._trips];
      notifyListeners();
      return trip;
    } catch (e) {
      _errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void searchTrips({
    String? departure,
    String? arrival,
    DateTime? date,
  }) {
    _searchSubscription?.cancel();
    _setLoading(true);
    _clearMessages();

    _searchSubscription = searchTripsUseCase(
      departure: departure,
      arrival: arrival,
      date: date,
    ).listen(
      (results) {
        _trips = results;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _cleanError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadTripHistory({
    required String driverId,
  }) {
    _historySubscription?.cancel();
    _setLoading(true);
    _clearMessages();

    _historySubscription = getTripHistoryUseCase(
      driverId: driverId,
    ).listen(
      (results) {
        _tripHistory = results;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _cleanError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
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
