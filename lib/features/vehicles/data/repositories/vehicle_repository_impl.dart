import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<VehicleEntity> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String plateNumber,
    required String color,
    required int seats,
  }) {
    return remoteDataSource.addVehicle(
      ownerId: ownerId,
      brand: brand,
      model: model,
      plateNumber: plateNumber,
      color: color,
      seats: seats,
    );
  }

  @override
  Stream<List<VehicleEntity>> getUserVehicles({
    required String ownerId,
  }) {
    return remoteDataSource.getUserVehicles(
      ownerId: ownerId,
    );
  }
}
