import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  final VehicleRepository repository;

  AddVehicleUseCase(this.repository);

  Future<VehicleEntity> call({
    required String ownerId,
    required String brand,
    required String model,
    required String plateNumber,
    required String color,
    required int seats,
  }) {
    return repository.addVehicle(
      ownerId: ownerId,
      brand: brand,
      model: model,
      plateNumber: plateNumber,
      color: color,
      seats: seats,
    );
  }
}
