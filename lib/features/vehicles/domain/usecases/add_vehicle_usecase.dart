// Cas d'usage : ajout d'un véhicule au profil conducteur.
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  final VehicleRepository repository;

  AddVehicleUseCase(this.repository);

  Future<VehicleEntity> call(VehicleEntity vehicle) {
    _validate(vehicle);
    return repository.addVehicle(vehicle);
  }

  void _validate(VehicleEntity vehicle) {
    if (vehicle.immatriculation.trim().isEmpty) {
      throw Exception("Le numéro d'immatriculation est requis.");
    }
    if (vehicle.numeroChassis.trim().isEmpty) {
      throw Exception('Le numéro de chassis est requis.');
    }
    if (vehicle.marque.trim().isEmpty) {
      throw Exception('La marque du véhicule est requise.');
    }
    if (vehicle.modele.trim().isEmpty) {
      throw Exception('Le modèle du véhicule est requis.');
    }
    if (vehicle.categorie.trim().isEmpty) {
      throw Exception('La catégorie du véhicule est requise.');
    }
    if (vehicle.nombrePlaces <= 0) {
      throw Exception('Le nombre de places doit être supérieur à 0.');
    }
  }
}
