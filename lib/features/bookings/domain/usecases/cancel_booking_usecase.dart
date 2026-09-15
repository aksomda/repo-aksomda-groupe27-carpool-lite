// Cas d'usage : annulation d'une demande par le passager qui l'a envoyée.
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.updateStatus(requestId, RideRequestStatus.annulee);
  }
}
