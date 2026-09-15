// Cas d'usage : modification d'un véhicule existant.
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class UpdateVehicleUseCase {
  final VehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  Future<void> call(VehicleEntity vehicle) {
    if (vehicle.id.trim().isEmpty) {
      throw Exception('Véhicule invalide : identifiant manquant.');
    }
    if (vehicle.immatriculation.trim().isEmpty) {
      throw Exception("Le numéro d'immatriculation est requis.");
    }
    if (vehicle.nombrePlaces <= 0) {
      throw Exception('Le nombre de places doit être supérieur à 0.');
    }
    return repository.updateVehicle(vehicle);
  }
}
