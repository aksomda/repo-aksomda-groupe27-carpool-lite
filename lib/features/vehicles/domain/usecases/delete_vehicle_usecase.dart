import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository repository;

  DeleteVehicleUseCase(this.repository);

  Future<void> call({
    required String ownerId,
    required String vehicleId,
  }) {
    return repository.deleteVehicle(
      ownerId: ownerId,
      vehicleId: vehicleId,
    );
  }
}
