import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<VehicleEntity> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String plateNumber,
    required String color,
    required int seats,
  });

  Stream<List<VehicleEntity>> getUserVehicles({
    required String ownerId,
  });
}
