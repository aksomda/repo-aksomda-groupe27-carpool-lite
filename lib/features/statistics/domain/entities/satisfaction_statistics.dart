class SatisfactionStatistics {
  final double punctuality;
  final double driving;
  final double atmosphere;
  final double overall;

  final int numberOfReviews;

  const SatisfactionStatistics({
    required this.punctuality,
    required this.driving,
    required this.atmosphere,
    required this.overall,
    required this.numberOfReviews,
  });

  /// Moyenne des 3 sous-critères (ponctualité, conduite, ambiance).
  /// [overall] est déjà un résumé donné par l'évaluateur : il n'est pas
  /// remoyenné avec les sous-critères.
  double get averageRating {
    return (punctuality + driving + atmosphere) / 3;
  }

  /// Pourcentage de satisfaction globale. Les notes sont sur 10.
  double get satisfactionPercentage {
    return (overall / 10) * 100;
  }

  /// Vérifie si les données sont disponibles.
  bool get hasData {
    return numberOfReviews > 0;
  }
}
