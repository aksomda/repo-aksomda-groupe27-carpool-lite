import '../../domain/entities/driver_satisfaction_statistics.dart';

class DriverSatisfactionStatisticsModel extends DriverSatisfactionStatistics {
  const DriverSatisfactionStatisticsModel({
    required super.driverId,
    required super.driverName,
    required super.punctuality,
    required super.driving,
    required super.atmosphere,
    required super.overall,
    required super.numberOfReviews,
  });

  factory DriverSatisfactionStatisticsModel.fromEntity(
    DriverSatisfactionStatistics entity,
  ) {
    return DriverSatisfactionStatisticsModel(
      driverId: entity.driverId,
      driverName: entity.driverName,
      punctuality: entity.punctuality,
      driving: entity.driving,
      atmosphere: entity.atmosphere,
      overall: entity.overall,
      numberOfReviews: entity.numberOfReviews,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'punctuality': punctuality,
      'driving': driving,
      'atmosphere': atmosphere,
      'overall': overall,
      'numberOfReviews': numberOfReviews,
    };
  }

  factory DriverSatisfactionStatisticsModel.fromMap(Map<String, dynamic> map) {
    return DriverSatisfactionStatisticsModel(
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      punctuality: (map['punctuality'] ?? 0).toDouble(),
      driving: (map['driving'] ?? 0).toDouble(),
      atmosphere: (map['atmosphere'] ?? 0).toDouble(),
      overall: (map['overall'] ?? 0).toDouble(),
      numberOfReviews: map['numberOfReviews'] ?? 0,
    );
  }
}
