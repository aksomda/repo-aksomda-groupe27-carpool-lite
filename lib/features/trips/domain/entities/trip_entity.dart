/// Entité Trip : trajet publié par un conducteur (utilisateur connecté).
class TripEntity {
  /// id_trajet : identifiant Firestore généré automatiquement.
  final String id;

  /// uid du conducteur qui a publié le trajet.
  final String driverId;

  /// Immatriculation du véhicule utilisé pour ce trajet.
  final String immatriculationVehicule;

  final String lieuDepart;
  final String lieuArrivee;

  /// Distance en kilomètres, calculée par le système via l'API Google
  /// (Distance Matrix) à partir du lieu de départ et du lieu d'arrivée.
  final double distanceKm;

  /// Prix par place (place réservée par un passager).
  final num prixParPlace;

  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.driverId,
    required this.immatriculationVehicule,
    required this.lieuDepart,
    required this.lieuArrivee,
    required this.distanceKm,
    required this.prixParPlace,
    required this.createdAt,
  });

  TripEntity copyWith({
    String? id,
    String? driverId,
    String? immatriculationVehicule,
    String? lieuDepart,
    String? lieuArrivee,
    double? distanceKm,
    num? prixParPlace,
    DateTime? createdAt,
  }) {
    return TripEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      immatriculationVehicule: immatriculationVehicule ?? this.immatriculationVehicule,
      lieuDepart: lieuDepart ?? this.lieuDepart,
      lieuArrivee: lieuArrivee ?? this.lieuArrivee,
      distanceKm: distanceKm ?? this.distanceKm,
      prixParPlace: prixParPlace ?? this.prixParPlace,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
