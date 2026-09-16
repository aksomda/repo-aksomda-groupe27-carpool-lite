class UniversitySatisfactionStatistics {
  final String universityId;
  final String universityName;

  final double averagePunctuality;
  final double averageDriving;
  final double averageAtmosphere;
  final double averageOverall;

  final int totalReviews;
  final int totalTrips;
  final int totalDrivers;

  const UniversitySatisfactionStatistics({
    required this.universityId,
    required this.universityName,
    required this.averagePunctuality,
    required this.averageDriving,
    required this.averageAtmosphere,
    required this.averageOverall,
    required this.totalReviews,
    required this.totalTrips,
    required this.totalDrivers,
  });

  /// Pourcentage de satisfaction globale de l'université. Les notes sont
  /// sur 10.
  double get satisfactionPercentage {
    if (totalReviews == 0) {
      return 0;
    }

    return (averageOverall / 10) * 100;
  }

  /// Moyenne des trois critères : ponctualité + conduite + ambiance.
  double get averageRating {
    return (averagePunctuality + averageDriving + averageAtmosphere) / 3;
  }

  /// Indique si l'université possède des évaluations.
  bool get hasReviews {
    return totalReviews > 0;
  }
}
