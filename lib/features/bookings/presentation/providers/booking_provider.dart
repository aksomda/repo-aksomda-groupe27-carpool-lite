// Gestion d'état des demandes de réservation (création, acceptation,
// refus, annulation, filtrage par statut et par plage de dates).
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/ride_request_entity.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/confirm_booking_usecase.dart';
import '../../domain/usecases/get_driver_requests_usecase.dart';
import '../../domain/usecases/get_my_requests_usecase.dart';
import '../../domain/usecases/reject_booking_usecase.dart';
import '../../domain/usecases/request_booking_usecase.dart';

class BookingProvider extends ChangeNotifier {
  final RequestBookingUseCase requestBookingUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final RejectBookingUseCase rejectBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final GetDriverRequestsUseCase getDriverRequestsUseCase;
  final GetMyRequestsUseCase getMyRequestsUseCase;

  BookingProvider({
    required this.requestBookingUseCase,
    required this.confirmBookingUseCase,
    required this.rejectBookingUseCase,
    required this.cancelBookingUseCase,
    required this.getDriverRequestsUseCase,
    required this.getMyRequestsUseCase,
  });

  // ---------------------------------------------------------------------
  // Demandes reçues (conducteur) — avec filtrage par statut et par
  // plage de dates (date de la demande).
  // ---------------------------------------------------------------------

  List<RideRequestEntity> _driverRequests = [];
  bool isLoadingDriverRequests = true;
  String? driverRequestsError;

  RideRequestStatus? statutFiltre;
  DateTime? dateDebutFiltre;
  DateTime? dateFinFiltre;

  StreamSubscription<List<RideRequestEntity>>? _driverSubscription;
  String? _driverId;

  /// Demandes reçues, après application des filtres courants.
  List<RideRequestEntity> get filteredDriverRequests {
    return _driverRequests.where((r) {
      if (statutFiltre != null && r.statut != statutFiltre) return false;

      if (dateDebutFiltre != null) {
        final debut = DateTime(
          dateDebutFiltre!.year,
          dateDebutFiltre!.month,
          dateDebutFiltre!.day,
        );
        if (r.dateDemande.isBefore(debut)) return false;
      }

      if (dateFinFiltre != null) {
        // Borne incluse jusqu'à la fin de la journée sélectionnée.
        final fin = DateTime(
          dateFinFiltre!.year,
          dateFinFiltre!.month,
          dateFinFiltre!.day,
          23,
          59,
          59,
        );
        if (r.dateDemande.isAfter(fin)) return false;
      }

      return true;
    }).toList();
  }

  /// (Ré)abonne le provider aux demandes reçues par le conducteur connecté.
  void listenToDriverRequests(String driverId) {
    if (_driverId == driverId && _driverSubscription != null) return;

    _driverId = driverId;
    _driverSubscription?.cancel();
    isLoadingDriverRequests = true;
    notifyListeners();

    _driverSubscription = getDriverRequestsUseCase(driverId).listen(
      (data) {
        _driverRequests = data;
        isLoadingDriverRequests = false;
        driverRequestsError = null;
        notifyListeners();
      },
      onError: (e) {
        driverRequestsError = 'Impossible de charger les demandes reçues : $e';
        isLoadingDriverRequests = false;
        notifyListeners();
      },
    );
  }

  void setStatutFiltre(RideRequestStatus? statut) {
    statutFiltre = statut;
    notifyListeners();
  }

  void setDateRangeFiltre({DateTime? dateDebut, DateTime? dateFin}) {
    dateDebutFiltre = dateDebut;
    dateFinFiltre = dateFin;
    notifyListeners();
  }

  void clearFiltres() {
    statutFiltre = null;
    dateDebutFiltre = null;
    dateFinFiltre = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Demandes envoyées (passager)
  // ---------------------------------------------------------------------

  List<RideRequestEntity> myRequests = [];
  bool isLoadingMyRequests = true;
  String? myRequestsError;

  StreamSubscription<List<RideRequestEntity>>? _mySubscription;
  String? _passengerId;

  /// (Ré)abonne le provider aux demandes envoyées par le passager connecté.
  void listenToMyRequests(String passengerId) {
    if (_passengerId == passengerId && _mySubscription != null) return;

    _passengerId = passengerId;
    _mySubscription?.cancel();
    isLoadingMyRequests = true;
    notifyListeners();

    _mySubscription = getMyRequestsUseCase(passengerId).listen(
      (data) {
        myRequests = data;
        isLoadingMyRequests = false;
        myRequestsError = null;
        notifyListeners();
      },
      onError: (e) {
        myRequestsError = 'Impossible de charger vos demandes : $e';
        isLoadingMyRequests = false;
        notifyListeners();
      },
    );
  }

  // ---------------------------------------------------------------------
  // Actions (création, acceptation, refus, annulation)
  // ---------------------------------------------------------------------

  bool isSaving = false;
  String? saveError;

  Future<bool> requestBooking(RideRequestEntity request) async {
    return _runAction(() async {
      await requestBookingUseCase(request);
    });
  }

  Future<bool> confirmRequest(String requestId) async {
    return _runAction(() => confirmBookingUseCase(requestId));
  }

  Future<bool> rejectRequest(String requestId) async {
    return _runAction(() => rejectBookingUseCase(requestId));
  }

  Future<bool> cancelRequest(String requestId) async {
    return _runAction(() => cancelBookingUseCase(requestId));
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      await action();
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
    _driverSubscription?.cancel();
    _mySubscription?.cancel();
    super.dispose();
  }
}
