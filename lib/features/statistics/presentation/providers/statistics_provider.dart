// Gestion d'état des statistiques.
import 'package:flutter/foundation.dart';

import '../../domain/entities/driver_satisfaction_statistics.dart';
import '../../domain/entities/university_satisfaction_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsRepository repository;

  StatisticsProvider({required this.repository});

  bool isLoadingDriverStats = false;
  String? driverStatsError;
  DriverSatisfactionStatistics? driverStatistics;

  bool isLoadingUniversityStats = false;
  String? universityStatsError;
  UniversitySatisfactionStatistics? universityStatistics;

  Future<void> loadDriverStatistics(String driverId) async {
    isLoadingDriverStats = true;
    driverStatsError = null;
    notifyListeners();

    try {
      driverStatistics = await repository.getDriverStatistics(driverId);
    } catch (e) {
      driverStatsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingDriverStats = false;
      notifyListeners();
    }
  }

  Future<void> loadUniversityStatistics(String universityId) async {
    isLoadingUniversityStats = true;
    universityStatsError = null;
    notifyListeners();

    try {
      universityStatistics =
          await repository.getUniversityStatistics(universityId);
    } catch (e) {
      universityStatsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingUniversityStats = false;
      notifyListeners();
    }
  }
}
