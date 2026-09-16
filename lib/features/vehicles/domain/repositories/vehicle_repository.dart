import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  /// Flux temps réel des véhicules d'un conducteur.
  Stream<List<VehicleEntity>> getUserVehicles(String ownerId);

  Future<VehicleEntity> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required int year,
    required int seats,
    bool isDefault,
  });

  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle);

  Future<void> deleteVehicle({
    required String ownerId,
    required String vehicleId,
  });

  /// Désigne [vehicleId] comme véhicule par défaut et retire ce statut
  /// aux autres véhicules du même propriétaire.
  Future<void> setDefaultVehicle({
    required String ownerId,
    required String vehicleId,
  });
}
