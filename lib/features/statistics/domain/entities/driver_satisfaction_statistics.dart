class DriverSatisfactionStatistics {
  final String driverId;
  final String driverName;

  final double punctuality;
  final double driving;
  final double atmosphere;
  final double overall;

  final int numberOfReviews;

  const DriverSatisfactionStatistics({
    required this.driverId,
    required this.driverName,
    required this.punctuality,
    required this.driving,
    required this.atmosphere,
    required this.overall,
    required this.numberOfReviews,
  });

  /// Moyenne des 3 sous-critères (ponctualité, conduite, ambiance).
  double get averageRating {
    return (punctuality + driving + atmosphere) / 3;
  }

  /// Pourcentage de satisfaction globale. Les notes sont sur 10.
  double get satisfactionPercentage {
    return (overall / 10) * 100;
  }

  /// Indique si le conducteur possède au moins une évaluation.
  bool get hasReviews {
    return numberOfReviews > 0;
  }
}
