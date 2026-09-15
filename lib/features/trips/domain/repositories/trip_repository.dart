import '../entities/trip_entity.dart';

abstract class TripRepository {
  /// Publie un nouveau trajet. [trip.id] peut être vide : un identifiant
  /// Firestore est alors généré par l'implémentation, et le trajet
  /// persisté (avec son id définitif) est retourné.
  Future<TripEntity> publishTrip(TripEntity trip);

  /// Modifie un trajet existant ([trip.id] doit être renseigné).
  Future<void> updateTrip(TripEntity trip);

  /// Historique des trajets publiés par [driverId] (l'utilisateur
  /// connecté), du plus récent au plus ancien.
  Stream<List<TripEntity>> getTripHistory(String driverId);

  /// Ensemble des trajets enregistrés, tous conducteurs confondus, du plus
  /// récent au plus ancien (module de recherche de trajets).
  Stream<List<TripEntity>> getAllTrips();
}
