class TripStatistics {
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final int pendingTrips;

  final int totalPassengers;
  final int totalDrivers;

  const TripStatistics({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.pendingTrips,
    required this.totalPassengers,
    required this.totalDrivers,
  });

  /// Taux de réalisation des trajets.
  double get completionRate {
    if (totalTrips == 0) {
      return 0;
    }

    return (completedTrips / totalTrips) * 100;
  }

  /// Taux d'annulation.
  double get cancellationRate {
    if (totalTrips == 0) {
      return 0;
    }

    return (cancelledTrips / totalTrips) * 100;
  }
}
