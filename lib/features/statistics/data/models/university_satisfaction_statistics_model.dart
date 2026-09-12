import '../../domain/entities/university_satisfaction_statistics.dart';

class UniversitySatisfactionStatisticsModel
    extends UniversitySatisfactionStatistics {
  const UniversitySatisfactionStatisticsModel({
    required super.universityId,
    required super.universityName,
    required super.averagePunctuality,
    required super.averageDriving,
    required super.averageAtmosphere,
    required super.averageOverall,
    required super.totalReviews,
    required super.totalTrips,
    required super.totalDrivers,
  });

  factory UniversitySatisfactionStatisticsModel.fromEntity(
    UniversitySatisfactionStatistics entity,
  ) {
    return UniversitySatisfactionStatisticsModel(
      universityId: entity.universityId,
      universityName: entity.universityName,
      averagePunctuality: entity.averagePunctuality,
      averageDriving: entity.averageDriving,
      averageAtmosphere: entity.averageAtmosphere,
      averageOverall: entity.averageOverall,
      totalReviews: entity.totalReviews,
      totalTrips: entity.totalTrips,
      totalDrivers: entity.totalDrivers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'universityId': universityId,
      'universityName': universityName,
      'averagePunctuality': averagePunctuality,
      'averageDriving': averageDriving,
      'averageAtmosphere': averageAtmosphere,
      'averageOverall': averageOverall,
      'totalReviews': totalReviews,
      'totalTrips': totalTrips,
      'totalDrivers': totalDrivers,
    };
  }

  factory UniversitySatisfactionStatisticsModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UniversitySatisfactionStatisticsModel(
      universityId: map['universityId'] ?? '',
      universityName: map['universityName'] ?? '',
      averagePunctuality: (map['averagePunctuality'] ?? 0).toDouble(),
      averageDriving: (map['averageDriving'] ?? 0).toDouble(),
      averageAtmosphere: (map['averageAtmosphere'] ?? 0).toDouble(),
      averageOverall: (map['averageOverall'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalTrips: map['totalTrips'] ?? 0,
      totalDrivers: map['totalDrivers'] ?? 0,
    );
  }
}
