class VehicleEntity {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final int seats;

  const VehicleEntity({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.seats,
  });

  VehicleEntity copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    String? plateNumber,
    String? color,
    int? seats,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      seats: seats ?? this.seats,
    );
  }

  @override
  String toString() {
    return 'VehicleEntity('
        'id: $id, '
        'ownerId: $ownerId, '
        'brand: $brand, '
        'model: $model, '
        'plateNumber: $plateNumber, '
        'color: $color, '
        'seats: $seats'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VehicleEntity &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.brand == brand &&
        other.model == model &&
        other.plateNumber == plateNumber &&
        other.color == color &&
        other.seats == seats;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      ownerId,
      brand,
      model,
      plateNumber,
      color,
      seats,
    );
  }
}
