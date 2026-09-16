import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class ConfirmBookingUseCase {
  final BookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<BookingEntity> call({
    required String requestId,
  }) {
    return repository.confirmBooking(
      requestId: requestId,
    );
  }
}