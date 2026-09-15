// Cas d'usage : demande de réservation par un passager (fonctionnalité 06).
import '../entities/ride_request_entity.dart';
import '../repositories/booking_repository.dart';

class RequestBookingUseCase {
  final BookingRepository repository;

  RequestBookingUseCase(this.repository);

  Future<RideRequestEntity> call(RideRequestEntity request) {
    if (request.tripId.trim().isEmpty) {
      throw Exception('Trajet invalide : identifiant manquant.');
    }
    if (request.passengerId.trim().isEmpty) {
      throw Exception('Vous devez être connecté pour réserver un trajet.');
    }
    if (request.driverId == request.passengerId) {
      throw Exception('Vous ne pouvez pas réserver votre propre trajet.');
    }
    if (request.nombrePlaces <= 0) {
      throw Exception('Le nombre de places doit être supérieur à 0.');
    }

    // Une nouvelle demande démarre toujours en attente, à la date du jour,
    // quoi qu'ait pu contenir l'entité passée en paramètre.
    final normalized = request.copyWith(
      statut: RideRequestStatus.enAttente,
      dateDemande: DateTime.now(),
    );
    return repository.requestBooking(normalized);
  }
}
