import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<VehicleEntity>> getUserVehicles(String ownerId) {
    return remoteDataSource.getUserVehicles(ownerId);
  }

  @override
  Future<VehicleEntity> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required int year,
    required int seats,
    bool isDefault = false,
  }) {
    return remoteDataSource.addVehicle(
      ownerId: ownerId,
      brand: brand,
      model: model,
      color: color,
      plateNumber: plateNumber,
      year: year,
      seats: seats,
      isDefault: isDefault,
    );
  }

  @override
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) {
    return remoteDataSource.updateVehicle(
      VehicleModel.fromEntity(vehicle),
    );
  }

  @override
  Future<void> deleteVehicle({
    required String ownerId,
    required String vehicleId,
  }) {
    return remoteDataSource.deleteVehicle(
      ownerId: ownerId,
      vehicleId: vehicleId,
    );
  }

  @override
  Future<void> setDefaultVehicle({
    required String ownerId,
    required String vehicleId,
  }) {
    return remoteDataSource.setDefaultVehicle(
      ownerId: ownerId,
      vehicleId: vehicleId,
    );
  }
}
