import '../repositories/booking_repository.dart';

class RejectBookingRequestUseCase {
  final BookingRepository repository;

  RejectBookingRequestUseCase(this.repository);

  Future<void> call({
    required String requestId,
  }) {
    return repository.rejectBookingRequest(
      requestId: requestId,
    );
  }
}