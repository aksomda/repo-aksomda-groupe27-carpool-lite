import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vehicle_model.dart';

class VehiclesRemoteDataSource {
  final FirebaseFirestore firestore;

  VehiclesRemoteDataSource(this.firestore);

  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    final document = firestore.collection('vehicles').doc();

    await document.set(vehicle.toFirestore());

    final snapshot = await document.get();

    return VehicleModel.fromFirestore(snapshot);
  }

  Future<List<VehicleModel>> getUserVehicles(String ownerId) async {
    final snapshot = await firestore
        .collection('vehicles')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map((doc) => VehicleModel.fromFirestore(doc)).toList();
  }
}
