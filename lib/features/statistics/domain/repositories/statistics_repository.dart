import '../entities/driver_satisfaction_statistics.dart';
import '../entities/university_satisfaction_statistics.dart';

abstract class StatisticsRepository {
  Future<DriverSatisfactionStatistics> getDriverStatistics(String driverId);

  Future<UniversitySatisfactionStatistics> getUniversityStatistics(
    String universityId,
  );
}
