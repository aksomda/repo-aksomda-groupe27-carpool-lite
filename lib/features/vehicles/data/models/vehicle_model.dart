import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.ownerId,
    required super.brand,
    required super.model,
    required super.plateNumber,
    required super.color,
    required super.seats,
  });

  factory VehicleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return VehicleModel(
      id: document.id,
      ownerId: data['ownerId']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      model: data['model']?.toString() ?? '',
      plateNumber: data['plateNumber']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      seats: (data['seats'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'plateNumber': plateNumber,
      'color': color,
      'seats': seats,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
