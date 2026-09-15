// Cas d'usage : recherche parmi l'ensemble des trajets enregistrés.
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class SearchTripsUseCase {
  final TripRepository repository;

  SearchTripsUseCase(this.repository);

  /// Retourne tous les trajets enregistrés, éventuellement filtrés sur le
  /// lieu de départ et/ou le lieu d'arrivée.
  ///
  /// Le filtrage est fait côté client (insensible à la casse et aux
  /// correspondances partielles) : Firestore ne sait pas faire de
  /// recherche "contient" sur une chaîne, et le volume de trajets d'une
  /// application de covoiturage universitaire reste modeste.
  Stream<List<TripEntity>> call({String? lieuDepart, String? lieuArrivee}) {
    final depart = (lieuDepart ?? '').trim().toLowerCase();
    final arrivee = (lieuArrivee ?? '').trim().toLowerCase();

    return repository.getAllTrips().map((trips) {
      if (depart.isEmpty && arrivee.isEmpty) return trips;

      return trips.where((trip) {
        final matchDepart =
            depart.isEmpty || trip.lieuDepart.toLowerCase().contains(depart);
        final matchArrivee =
            arrivee.isEmpty || trip.lieuArrivee.toLowerCase().contains(arrivee);
        return matchDepart && matchArrivee;
      }).toList();
    });
  }
}
