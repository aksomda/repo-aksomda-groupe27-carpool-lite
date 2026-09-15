import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/ride_request_entity.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/confirm_booking_usecase.dart';
import '../../domain/usecases/reject_booking_request_usecase.dart';
import '../../domain/usecases/request_booking_usecase.dart';
import '../../domain/repositories/booking_repository.dart';


class BookingProvider extends ChangeNotifier {
  final RequestBookingUseCase requestBookingUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final RejectBookingRequestUseCase rejectBookingRequestUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final BookingRepository repository;

  BookingProvider({
    required this.requestBookingUseCase,
    required this.confirmBookingUseCase,
    required this.rejectBookingRequestUseCase,
    required this.cancelBookingUseCase,
    required this.repository,
  });

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<BookingEntity> _userBookings = [];
  List<RideRequestEntity> _driverRequests = [];

  StreamSubscription<List<BookingEntity>>? _bookingsSubscription;
  StreamSubscription<List<RideRequestEntity>>? _requestsSubscription;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  List<BookingEntity> get userBookings => _userBookings;

  List<RideRequestEntity> get driverRequests => _driverRequests;

  Future<void> requestBooking({
    required String tripId,
    required String passengerId,
    required String driverId,
    required int numberOfSeats,
    required double totalPrice,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await requestBookingUseCase(
        tripId: tripId,
        passengerId: passengerId,
        driverId: driverId,
        numberOfSeats: numberOfSeats,
        totalPrice: totalPrice,
      );

      _successMessage = 'Demande de réservation envoyée avec succès.';
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmBooking({
    required String requestId,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await confirmBookingUseCase(
        requestId: requestId,
      );

      _successMessage = 'Réservation confirmée avec succès.';
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectBookingRequest({
    required String requestId,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await rejectBookingRequestUseCase(
        requestId: requestId,
      );

      _successMessage = 'Demande de réservation refusée.';
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelBooking({
    required String tripId,
    required String bookingId,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await cancelBookingUseCase(
        tripId: tripId,
        bookingId: bookingId,
      );

      _successMessage = 'Réservation annulée avec succès.';
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  void listenToUserBookings({
    required String passengerId,
  }) {
    _bookingsSubscription?.cancel();

    _bookingsSubscription = repository
        .getUserBookings(
          passengerId: passengerId,
        )
        .listen(
          (bookings) {
            _userBookings = bookings;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = _cleanError(error);
            notifyListeners();
          },
        );
  }

  void listenToDriverRequests({
    required String driverId,
  }) {
    _requestsSubscription?.cancel();

    _requestsSubscription = repository
        .getDriverRequests(
          driverId: driverId,
        )
        .listen(
          (requests) {
            _driverRequests = requests;
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
    _bookingsSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }
}