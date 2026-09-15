// Cas d'usage : demandes envoyées par le passager connecté.
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class GetMyRequestsUseCase {
  final BookingRepository repository;

  GetMyRequestsUseCase(this.repository);

  Stream<List<RideRequestEntity>> call(String passengerId) {
    return repository.getMyRequests(passengerId);
  }
}
