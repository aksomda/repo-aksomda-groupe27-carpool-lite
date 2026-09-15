import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  /// Crée un véhicule. [vehicle.id] peut être vide : un identifiant
  /// Firestore est alors généré par l'implémentation, et le véhicule
  /// persisté (avec son id définitif) est retourné.
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle);

  /// Modifie un véhicule existant ([vehicle.id] doit être renseigné).
  Future<void> updateVehicle(VehicleEntity vehicle);

  /// Liste, en temps réel, les véhicules appartenant à [ownerId].
  Stream<List<VehicleEntity>> getUserVehicles(String ownerId);
}
