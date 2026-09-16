import '../../../reviews/domain/entities/review.dart';
import '../entities/driver_satisfaction_statistics.dart';

class GetDriverStatistics {
  DriverSatisfactionStatistics call({
    required String driverId,
    required String driverName,
    required List<Review> reviews,
  }) {
    if (reviews.isEmpty) {
      return DriverSatisfactionStatistics(
        driverId: driverId,
        driverName: driverName,
        punctuality: 0,
        driving: 0,
        atmosphere: 0,
        overall: 0,
        numberOfReviews: 0,
      );
    }

    double punctuality = 0;
    double driving = 0;
    double atmosphere = 0;
    double overall = 0;

    for (final review in reviews) {
      punctuality += review.punctualityRating;
      driving += review.drivingRating;
      atmosphere += review.atmosphereRating;
      overall += review.overallRating;
    }

    final count = reviews.length;

    return DriverSatisfactionStatistics(
      driverId: driverId,
      driverName: driverName,
      punctuality: punctuality / count,
      driving: driving / count,
      atmosphere: atmosphere / count,
      overall: overall / count,
      numberOfReviews: count,
    );
  }
}
