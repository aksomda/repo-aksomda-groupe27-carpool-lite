/// Un trajet mis en favori par un utilisateur.
///
/// Les informations du trajet sont dupliquées (dénormalisées) au moment
/// de l'ajout : l'écran « Mes favoris » peut ainsi s'afficher avec une
/// seule lecture Firestore, sans recharger chaque trajet un par un, et
/// reste consultable même si le trajet a depuis été supprimé.
class FavoriteEntity {
  final String id;
  final String userId;
  final String tripId;

  final String departure;
  final String arrival;
  final DateTime departureDateTime;
  final double pricePerSeat;
  final String driverId;

  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.departure,
    required this.arrival,
    required this.departureDateTime,
    required this.pricePerSeat,
    required this.driverId,
    required this.createdAt,
  });

  /// Vrai si la date de départ est déjà passée.
  bool get isExpired => departureDateTime.isBefore(DateTime.now());

  FavoriteEntity copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? departure,
    String? arrival,
    DateTime? departureDateTime,
    double? pricePerSeat,
    String? driverId,
    DateTime? createdAt,
  }) {
    return FavoriteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
