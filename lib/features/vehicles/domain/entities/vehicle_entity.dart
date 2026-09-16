/// Un véhicule enregistré par un conducteur.
class VehicleEntity {
  final String id;

  /// Identifiant du propriétaire (uid de l'utilisateur).
  final String ownerId;

  final String brand;
  final String model;
  final String color;
  final String plateNumber;

  final int year;

  /// Nombre de places passagers (hors conducteur).
  final int seats;

  /// Vrai si c'est le véhicule proposé par défaut à la publication
  /// d'un trajet. Un seul véhicule par utilisateur peut l'être.
  final bool isDefault;

  final DateTime createdAt;

  const VehicleEntity({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.year,
    required this.seats,
    required this.isDefault,
    required this.createdAt,
  });

  /// Libellé lisible, ex. « Toyota Corolla (2018) ».
  String get displayName => '$brand $model ($year)';

  VehicleEntity copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    String? color,
    String? plateNumber,
    int? year,
    int? seats,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      year: year ?? this.year,
      seats: seats ?? this.seats,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
