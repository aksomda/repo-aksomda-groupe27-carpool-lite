class Vehicle {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final String plate;
  final int seats;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.plate,
    required this.seats,
  });

  String get displayName => '$brand $model';
}
