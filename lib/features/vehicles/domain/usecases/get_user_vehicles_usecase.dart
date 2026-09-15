// Cas d'usage : lister les véhicules d'un utilisateur (conducteur connecté).
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class GetUserVehiclesUseCase {
  final VehicleRepository repository;

  GetUserVehiclesUseCase(this.repository);

  Stream<List<VehicleEntity>> call(String ownerId) {
    return repository.getUserVehicles(ownerId);
  }
}
