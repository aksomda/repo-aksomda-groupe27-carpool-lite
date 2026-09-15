// Gestion d'état des trajets (publication, modification, historique).
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/maps_api_client.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/get_trip_history_usecase.dart';
import '../../domain/usecases/publish_trip_usecase.dart';
import '../../domain/usecases/search_trips_usecase.dart';
import '../../domain/usecases/update_trip_usecase.dart';

class TripProvider extends ChangeNotifier {
  final PublishTripUseCase publishTripUseCase;
  final UpdateTripUseCase updateTripUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;
  final SearchTripsUseCase searchTripsUseCase;
  final MapsApiClient mapsApiClient;

  TripProvider({
    required this.publishTripUseCase,
    required this.updateTripUseCase,
    required this.getTripHistoryUseCase,
    required this.searchTripsUseCase,
    required this.mapsApiClient,
  });

  List<TripEntity> tripHistory = [];
  bool isLoadingHistory = true;
  String? historyError;

  /// Résultats du module de recherche (tous conducteurs confondus).
  List<TripEntity> searchResults = [];
  bool isLoadingSearch = true;
  String? searchErrorMessage;

  String _filtreDepart = '';
  String _filtreArrivee = '';

  String get filtreDepart => _filtreDepart;
  String get filtreArrivee => _filtreArrivee;

  bool isSaving = false;
  String? saveError;

  /// Dernière distance calculée (affichée à l'utilisateur avant
  /// enregistrement du trajet).
  DistanceResult? lastDistance;

  StreamSubscription<List<TripEntity>>? _subscription;
  String? _driverId;

  StreamSubscription<List<TripEntity>>? _searchSubscription;

  /// (Ré)abonne le provider à l'historique des trajets du conducteur
  /// connecté. Sans effet si déjà abonné pour le même [driverId].
  void listenToTripHistory(String driverId) {
    if (_driverId == driverId && _subscription != null) return;

    _driverId = driverId;
    _subscription?.cancel();
    isLoadingHistory = true;
    notifyListeners();

    _subscription = getTripHistoryUseCase(driverId).listen(
      (data) {
        tripHistory = data;
        isLoadingHistory = false;
        historyError = null;
        notifyListeners();
      },
      onError: (e) {
        historyError = "Impossible de charger l'historique des trajets : $e";
        isLoadingHistory = false;
        notifyListeners();
      },
    );
  }

  /// (Ré)abonne le provider à l'ensemble des trajets enregistrés, filtrés
  /// sur le lieu de départ et/ou le lieu d'arrivée. Appelé au premier
  /// affichage de l'écran de recherche, puis à chaque changement de
  /// filtre.
  void searchTrips({String? lieuDepart, String? lieuArrivee}) {
    _filtreDepart = (lieuDepart ?? '').trim();
    _filtreArrivee = (lieuArrivee ?? '').trim();

    _searchSubscription?.cancel();
    isLoadingSearch = true;
    notifyListeners();

    _searchSubscription = searchTripsUseCase(
      lieuDepart: _filtreDepart,
      lieuArrivee: _filtreArrivee,
    ).listen(
      (data) {
        searchResults = data;
        isLoadingSearch = false;
        searchErrorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        searchErrorMessage = 'Impossible de charger les trajets : $e';
        isLoadingSearch = false;
        notifyListeners();
      },
    );
  }

  /// Réinitialise les filtres et réaffiche tous les trajets.
  void clearSearchFilters() => searchTrips();

  /// Calcule la distance entre [lieuDepart] et [lieuArrivee] via l'API
  /// Google (Distance Matrix).
  Future<DistanceResult> calculateDistance({
    required String lieuDepart,
    required String lieuArrivee,
  }) async {
    final result = await mapsApiClient.getDistance(
      origin: lieuDepart,
      destination: lieuArrivee,
    );
    lastDistance = result;
    notifyListeners();
    return result;
  }

  /// Publie un nouveau trajet. La distance est recalculée via l'API Google
  /// juste avant l'enregistrement. Retourne `true` en cas de succès.
  Future<bool> publishTrip({
    required String driverId,
    required String immatriculationVehicule,
    required String lieuDepart,
    required String lieuArrivee,
    required num prixParPlace,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      final distance = await calculateDistance(
        lieuDepart: lieuDepart,
        lieuArrivee: lieuArrivee,
      );

      final trip = TripEntity(
        id: '',
        driverId: driverId,
        immatriculationVehicule: immatriculationVehicule,
        lieuDepart: lieuDepart,
        lieuArrivee: lieuArrivee,
        distanceKm: distance.distanceKm,
        prixParPlace: prixParPlace,
        createdAt: DateTime.now(),
      );

      await publishTripUseCase(trip);
      return true;
    } catch (e) {
      saveError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Modifie un trajet existant. La distance est recalculée via l'API
  /// Google si le lieu de départ ou d'arrivée a changé. Retourne `true` en
  /// cas de succès.
  Future<bool> updateTrip({
    required TripEntity existing,
    required String immatriculationVehicule,
    required String lieuDepart,
    required String lieuArrivee,
    required num prixParPlace,
  }) async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      var distanceKm = existing.distanceKm;
      if (lieuDepart != existing.lieuDepart || lieuArrivee != existing.lieuArrivee) {
        final distance = await calculateDistance(
          lieuDepart: lieuDepart,
          lieuArrivee: lieuArrivee,
        );
        distanceKm = distance.distanceKm;
      }

      final trip = existing.copyWith(
        immatriculationVehicule: immatriculationVehicule,
        lieuDepart: lieuDepart,
        lieuArrivee: lieuArrivee,
        distanceKm: distanceKm,
        prixParPlace: prixParPlace,
      );

      await updateTripUseCase(trip);
      return true;
    } catch (e) {
      saveError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchSubscription?.cancel();
    super.dispose();
  }
}
