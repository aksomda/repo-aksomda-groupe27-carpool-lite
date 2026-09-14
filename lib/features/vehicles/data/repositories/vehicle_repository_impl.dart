import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

import '../datasources/vehicles_remote_datasource.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehiclesRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl(this.remoteDataSource);

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final model = VehicleModel.fromEntity(vehicle);

    return await remoteDataSource.addVehicle(model);
  }

  @override
  Future<List<Vehicle>> getUserVehicles(String ownerId) async {
    return await remoteDataSource.getUserVehicles(ownerId);
  }
}
