import '../../../reviews/domain/entities/review.dart';
import '../entities/university_satisfaction_statistics.dart';

class GetUniversityStatistics {
  UniversitySatisfactionStatistics call({
    required String universityId,
    required String universityName,
    required List<Review> reviews,
    required int totalTrips,
    required int totalDrivers,
  }) {
    if (reviews.isEmpty) {
      return UniversitySatisfactionStatistics(
        universityId: universityId,
        universityName: universityName,
        averagePunctuality: 0,
        averageDriving: 0,
        averageAtmosphere: 0,
        averageOverall: 0,
        totalReviews: 0,
        totalTrips: totalTrips,
        totalDrivers: totalDrivers,
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

    return UniversitySatisfactionStatistics(
      universityId: universityId,
      universityName: universityName,
      averagePunctuality: punctuality / count,
      averageDriving: driving / count,
      averageAtmosphere: atmosphere / count,
      averageOverall: overall / count,
      totalReviews: count,
      totalTrips: totalTrips,
      totalDrivers: totalDrivers,
    );
  }
}