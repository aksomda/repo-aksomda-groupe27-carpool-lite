import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  final VehicleRepository repository;

  AddVehicleUseCase(this.repository);

  Future<VehicleEntity> call({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required int year,
    required int seats,
    bool isDefault = false,
  }) {
    return repository.addVehicle(
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
}
