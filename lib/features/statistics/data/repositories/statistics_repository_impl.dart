import '../../domain/entities/driver_satisfaction_statistics.dart';
import '../../domain/entities/university_satisfaction_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/usecases/get_driver_statistics.dart';
import '../../domain/usecases/get_university_statistics.dart';
import '../datasources/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final GetDriverStatistics getDriverStatisticsUseCase;
  final GetUniversityStatistics getUniversityStatisticsUseCase;

  StatisticsRepositoryImpl({
    required this.remoteDataSource,
    required this.getDriverStatisticsUseCase,
    required this.getUniversityStatisticsUseCase,
  });

  @override
  Future<DriverSatisfactionStatistics> getDriverStatistics(
    String driverId,
  ) async {
    final reviews = await remoteDataSource.getReviewsByDriver(driverId);
    final driverName = await remoteDataSource.getUserName(driverId);

    return getDriverStatisticsUseCase.call(
      driverId: driverId,
      driverName: driverName,
      reviews: reviews,
    );
  }

  @override
  Future<UniversitySatisfactionStatistics> getUniversityStatistics(
    String universityId,
  ) async {
    final reviews = await remoteDataSource.getReviewsByUniversity(universityId);
    final universityName = await remoteDataSource.getUniversityName(universityId);
    final totalTrips = await remoteDataSource.getTotalTrips(universityId);
    final totalDrivers = await remoteDataSource.getTotalDrivers(universityId);

    return getUniversityStatisticsUseCase.call(
      universityId: universityId,
      universityName: universityName,
      reviews: reviews,
      totalTrips: totalTrips,
      totalDrivers: totalDrivers,
    );
  }
}
