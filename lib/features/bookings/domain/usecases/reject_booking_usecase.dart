// Cas d'usage : refus d'une demande de réservation par le conducteur.
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class RejectBookingUseCase {
  final BookingRepository repository;

  RejectBookingUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.updateStatus(requestId, RideRequestStatus.refusee);
  }
}
