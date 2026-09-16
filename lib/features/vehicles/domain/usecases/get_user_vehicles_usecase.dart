import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetUserVehiclesUseCase {
  final VehicleRepository repository;

  GetUserVehiclesUseCase(this.repository);

  Stream<List<VehicleEntity>> call(String ownerId) {
    return repository.getUserVehicles(ownerId);
  }
}
