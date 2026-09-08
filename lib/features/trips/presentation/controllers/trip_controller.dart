import 'package:flutter/foundation.dart';

import '../../domain/entities/trip.dart';
import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../domain/usecases/search_trips.dart';

class TripController extends ChangeNotifier {
  final PublishTrip publishTrip;
  final SearchTrips searchTrips;
  final GetTripHistory getTripHistory;
  final CancelTrip cancelTrip;

  TripController({
    required this.publishTrip,
    required this.searchTrips,
    required this.getTripHistory,
    required this.cancelTrip,
  });

  bool isLoading = false;
  String? errorMessage;

  List<Trip> trips = [];
  List<Trip> history = [];

  Future<void> publish(Trip trip) async {
    _startLoading();

    try {
      final createdTrip = await publishTrip(trip);

      trips = [...trips, createdTrip];
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossible de publier le trajet.';
    } finally {
      _stopLoading();
    }
  }

  Future<void> search({
    required String departureLabel,
    required String universityId,
    required DateTime date,
  }) async {
    _startLoading();

    try {
      trips = await searchTrips(
        departureLabel: departureLabel,
        universityId: universityId,
        date: date,
      );

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossible de rechercher les trajets.';
    } finally {
      _stopLoading();
    }
  }

  Future<void> loadHistory(String userId) async {
    _startLoading();

    try {
      history = await getTripHistory(userId);

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossible de charger l’historique.';
    } finally {
      _stopLoading();
    }
  }

  Future<void> cancel(String tripId) async {
    _startLoading();

    try {
      await cancelTrip(tripId);

      trips = trips.map((trip) {
        if (trip.id == tripId) {
          return Trip(
            id: trip.id,
            driverId: trip.driverId,
            departureLocation: trip.departureLocation,
            departureLabel: trip.departureLabel,
            universityId: trip.universityId,
            departureDateTime: trip.departureDateTime,
            availableSeats: trip.availableSeats,
            pricePerSeat: trip.pricePerSeat,
            status: TripStatus.cancelled,
            passengerIds: trip.passengerIds,
          );
        }

        return trip;
      }).toList();

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossible d’annuler le trajet.';
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
