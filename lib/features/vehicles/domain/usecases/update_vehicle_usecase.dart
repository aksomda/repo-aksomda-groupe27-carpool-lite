import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class UpdateVehicleUseCase {
  final VehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  Future<VehicleEntity> call(VehicleEntity vehicle) {
    return repository.updateVehicle(vehicle);
  }
}
