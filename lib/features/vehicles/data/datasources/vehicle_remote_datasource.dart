import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final FirebaseFirestore firestore;

  VehicleRemoteDataSource({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _vehiclesCollection {
    return firestore.collection('vehicles');
  }

  Future<VehicleModel> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String plateNumber,
    required String color,
    required int seats,
  }) async {
    final reference = _vehiclesCollection.doc();

    final vehicle = VehicleModel(
      id: reference.id,
      ownerId: ownerId,
      brand: brand,
      model: model,
      plateNumber: plateNumber,
      color: color,
      seats: seats,
    );

    await reference.set(vehicle.toFirestore());

    return vehicle;
  }

  Stream<List<VehicleModel>> getUserVehicles({
    required String ownerId,
  }) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(VehicleModel.fromFirestore).toList(),
        );
  }
}
