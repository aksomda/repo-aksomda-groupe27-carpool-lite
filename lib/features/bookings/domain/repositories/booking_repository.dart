import '../entities/booking_entity.dart';
import '../entities/ride_request_entity.dart';

abstract class BookingRepository {
  Future<RideRequestEntity> requestBooking({
    required String tripId,
    required String passengerId,
    required String driverId,
    required int numberOfSeats,
    required double totalPrice,
  });

  Future<BookingEntity> confirmBooking({
    required String requestId,
  });

  Future<void> rejectBookingRequest({
    required String requestId,
  });

  Future<void> cancelBooking({
    required String tripId,
    required String bookingId,
  });

  Stream<List<BookingEntity>> getUserBookings({
    required String passengerId,
  });

  Stream<List<RideRequestEntity>> getDriverRequests({
    required String driverId,
  });
}