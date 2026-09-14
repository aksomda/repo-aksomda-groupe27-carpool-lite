import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.ownerId,
    required super.brand,
    required super.model,
    required super.plate,
    required super.seats,
  });

  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      ownerId: vehicle.ownerId,
      brand: vehicle.brand,
      model: vehicle.model,
      plate: vehicle.plate,
      seats: vehicle.seats,
    );
  }

  factory VehicleModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return VehicleModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      plate: data['plate'] ?? '',
      seats: data['seats'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'ownerId': ownerId, 'brand': brand, 'model': model, 'plate': plate, 'seats': seats};
  }
}
