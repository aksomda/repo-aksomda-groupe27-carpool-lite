/// Entité Vehicle : véhicule appartenant à un conducteur (utilisateur
/// connecté), utilisé pour publier des trajets.
class VehicleEntity {
  /// id_vehicule : identifiant Firestore généré automatiquement.
  final String id;

  /// uid du conducteur propriétaire du véhicule.
  final String ownerId;

  final String immatriculation;
  final String numeroChassis;
  final String marque;
  final String modele;
  final String categorie;
  final int nombrePlaces;

  const VehicleEntity({
    required this.id,
    required this.ownerId,
    required this.immatriculation,
    required this.numeroChassis,
    required this.marque,
    required this.modele,
    required this.categorie,
    required this.nombrePlaces,
  });

  VehicleEntity copyWith({
    String? id,
    String? ownerId,
    String? immatriculation,
    String? numeroChassis,
    String? marque,
    String? modele,
    String? categorie,
    int? nombrePlaces,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      immatriculation: immatriculation ?? this.immatriculation,
      numeroChassis: numeroChassis ?? this.numeroChassis,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
      categorie: categorie ?? this.categorie,
      nombrePlaces: nombrePlaces ?? this.nombrePlaces,
    );
  }
}
