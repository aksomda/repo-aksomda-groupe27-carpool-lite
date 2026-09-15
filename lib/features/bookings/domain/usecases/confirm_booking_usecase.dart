// Cas d'usage : acceptation d'une demande de réservation par le conducteur.
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class ConfirmBookingUseCase {
  final BookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.updateStatus(requestId, RideRequestStatus.acceptee);
  }
}
