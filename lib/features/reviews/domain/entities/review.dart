class Review {
  final String id;
  final String tripId;
  final String bookingId;
  final String reviewerId;
  final String reviewedUserId;

  /// Université du trajet évalué, dupliquée ici au moment de la création
  /// pour permettre le filtrage des statistiques par université sans
  /// jointure (Firestore ne fait pas de jointures).
  final String universityId;

  final int punctualityRating;
  final int drivingRating;
  final int atmosphereRating;
  final int overallRating;

  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.tripId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.universityId,
    required this.punctualityRating,
    required this.drivingRating,
    required this.atmosphereRating,
    required this.overallRating,
    this.comment,
    required this.createdAt,
  });

  /// Moyenne des 3 sous-critères (ponctualité, conduite, ambiance).
  /// [overallRating] est l'impression globale donnée par l'évaluateur
  /// lui-même : c'est un résumé, pas un 4e critère à re-moyenner avec
  /// les autres.
  double get averageRating {
    return (punctualityRating + drivingRating + atmosphereRating) / 3;
  }
}
