import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<Vehicle> addVehicle(Vehicle vehicle);

  Future<List<Vehicle>> getUserVehicles(String ownerId);
}
