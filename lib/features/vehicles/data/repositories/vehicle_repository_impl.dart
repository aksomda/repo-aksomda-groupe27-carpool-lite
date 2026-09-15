// Implémentation concrète de VehicleRepository.
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl(this.remoteDataSource);

  @override
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle) async {
    final id = vehicle.id.isNotEmpty
        ? vehicle.id
        : remoteDataSource.newVehicleId();

    final model = VehicleModel.fromEntity(vehicle.copyWith(id: id));
    await remoteDataSource.createVehicle(model);
    return model;
  }

  @override
  Future<void> updateVehicle(VehicleEntity vehicle) {
    final model = VehicleModel.fromEntity(vehicle);
    return remoteDataSource.updateVehicle(model);
  }

  @override
  Stream<List<VehicleEntity>> getUserVehicles(String ownerId) {
    return remoteDataSource.getUserVehicles(ownerId);
  }
}
