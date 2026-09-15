// Cas d'usage : modification d'un trajet existant.
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class UpdateTripUseCase {
  final TripRepository repository;

  UpdateTripUseCase(this.repository);

  Future<void> call(TripEntity trip) {
    if (trip.id.trim().isEmpty) {
      throw Exception('Trajet invalide : identifiant manquant.');
    }
    if (trip.lieuDepart.trim().isEmpty) {
      throw Exception('Le lieu de départ est requis.');
    }
    if (trip.lieuArrivee.trim().isEmpty) {
      throw Exception("Le lieu d'arrivée est requis.");
    }
    if (trip.distanceKm <= 0) {
      throw Exception('La distance du trajet doit être calculée avant l\'enregistrement.');
    }
    if (trip.prixParPlace <= 0) {
      throw Exception('Le prix par place doit être supérieur à 0.');
    }
    return repository.updateTrip(trip);
  }
}
