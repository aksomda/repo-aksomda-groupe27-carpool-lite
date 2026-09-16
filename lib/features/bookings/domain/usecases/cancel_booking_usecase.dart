import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> call({
    required String tripId,
    required String bookingId,
  }) {
    return repository.cancelBooking(
      tripId: tripId,
      bookingId: bookingId,
    );
  }
}