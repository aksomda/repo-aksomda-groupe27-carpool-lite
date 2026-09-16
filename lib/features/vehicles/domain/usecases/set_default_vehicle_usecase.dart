import '../repositories/vehicle_repository.dart';

class SetDefaultVehicleUseCase {
  final VehicleRepository repository;

  SetDefaultVehicleUseCase(this.repository);

  Future<void> call({
    required String ownerId,
    required String vehicleId,
  }) {
    return repository.setDefaultVehicle(
      ownerId: ownerId,
      vehicleId: vehicleId,
    );
  }
}
