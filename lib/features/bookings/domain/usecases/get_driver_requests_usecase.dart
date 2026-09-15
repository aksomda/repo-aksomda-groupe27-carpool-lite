// Cas d'usage : demandes reçues par le conducteur connecté.
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class GetDriverRequestsUseCase {
  final BookingRepository repository;

  GetDriverRequestsUseCase(this.repository);

  Stream<List<RideRequestEntity>> call(String driverId) {
    return repository.getDriverRequests(driverId);
  }
}
