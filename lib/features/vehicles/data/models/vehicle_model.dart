import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.ownerId,
    required super.brand,
    required super.model,
    required super.color,
    required super.plateNumber,
    required super.year,
    required super.seats,
    required super.isDefault,
    required super.createdAt,
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
      color: data['color']?.toString() ?? '',
      plateNumber: data['plateNumber']?.toString() ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      seats: (data['seats'] as num?)?.toInt() ?? 1,
      isDefault: data['isDefault'] == true,
      createdAt: _toDate(data['createdAt']),
    );
  }

  factory VehicleModel.fromEntity(VehicleEntity vehicle) {
    return VehicleModel(
      id: vehicle.id,
      ownerId: vehicle.ownerId,
      brand: vehicle.brand,
      model: vehicle.model,
      color: vehicle.color,
      plateNumber: vehicle.plateNumber,
      year: vehicle.year,
      seats: vehicle.seats,
      isDefault: vehicle.isDefault,
      createdAt: vehicle.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'color': color,
      'plateNumber': plateNumber,
      'year': year,
      'seats': seats,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
