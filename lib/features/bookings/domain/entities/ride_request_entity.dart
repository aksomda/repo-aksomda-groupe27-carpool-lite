/// Statut d'une demande de réservation.
enum RideRequestStatus { enAttente, acceptee, refusee, annulee }

extension RideRequestStatusX on RideRequestStatus {
  /// Valeur stockée dans Firestore (champ `statut`).
  String get value {
    switch (this) {
      case RideRequestStatus.enAttente:
        return 'en_attente';
      case RideRequestStatus.acceptee:
        return 'acceptee';
      case RideRequestStatus.refusee:
        return 'refusee';
      case RideRequestStatus.annulee:
        return 'annulee';
    }
  }

  /// Libellé affiché à l'utilisateur.
  String get label {
    switch (this) {
      case RideRequestStatus.enAttente:
        return 'En attente';
      case RideRequestStatus.acceptee:
        return 'Acceptée';
      case RideRequestStatus.refusee:
        return 'Refusée';
      case RideRequestStatus.annulee:
        return 'Annulée';
    }
  }

  static RideRequestStatus fromValue(String value) {
    switch (value) {
      case 'acceptee':
        return RideRequestStatus.acceptee;
      case 'refusee':
        return RideRequestStatus.refusee;
      case 'annulee':
        return RideRequestStatus.annulee;
      case 'en_attente':
      default:
        return RideRequestStatus.enAttente;
    }
  }
}

/// Entité RideRequest : demande de réservation d'un passager sur un
/// trajet, avant confirmation par le conducteur.
class RideRequestEntity {
  /// id_demande : identifiant Firestore généré automatiquement.
  final String id;

  /// Trajet concerné par la demande.
  final String tripId;

  /// uid du conducteur du trajet (dénormalisé depuis le trajet, pour
  /// permettre au conducteur de lister les demandes qu'il a reçues).
  final String driverId;

  /// uid du passager à l'origine de la demande.
  final String passengerId;

  /// Lieu de départ / d'arrivée du trajet (dénormalisés depuis le trajet,
  /// pour afficher la demande sans requête supplémentaire).
  final String lieuDepart;
  final String lieuArrivee;

  final int nombrePlaces;
  final RideRequestStatus statut;
  final DateTime dateDemande;

  const RideRequestEntity({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.passengerId,
    required this.lieuDepart,
    required this.lieuArrivee,
    required this.nombrePlaces,
    required this.statut,
    required this.dateDemande,
  });

  RideRequestEntity copyWith({
    String? id,
    String? tripId,
    String? driverId,
    String? passengerId,
    String? lieuDepart,
    String? lieuArrivee,
    int? nombrePlaces,
    RideRequestStatus? statut,
    DateTime? dateDemande,
  }) {
    return RideRequestEntity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      lieuDepart: lieuDepart ?? this.lieuDepart,
      lieuArrivee: lieuArrivee ?? this.lieuArrivee,
      nombrePlaces: nombrePlaces ?? this.nombrePlaces,
      statut: statut ?? this.statut,
      dateDemande: dateDemande ?? this.dateDemande,
    );
  }
}
