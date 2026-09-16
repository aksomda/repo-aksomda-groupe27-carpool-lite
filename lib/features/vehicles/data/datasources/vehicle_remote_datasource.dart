import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final FirebaseFirestore firestore;

  VehicleRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _vehiclesCollection =>
      firestore.collection(FirestorePaths.vehicles);

  Stream<List<VehicleModel>> getUserVehicles(String ownerId) {
    if (ownerId.isEmpty) {
      return Stream.value(const []);
    }

    return _vehiclesCollection
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final vehicles =
          snapshot.docs.map(VehicleModel.fromFirestore).toList();

      // Le véhicule par défaut remonte en tête, puis les plus récents.
      // Le tri est fait côté client pour éviter d'exiger un index
      // composite Firestore sur (ownerId, isDefault, createdAt).
      vehicles.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

      return vehicles;
    });
  }

  Future<VehicleModel> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required int year,
    required int seats,
    bool isDefault = false,
  }) async {
    if (ownerId.isEmpty) {
      throw Exception('Utilisateur non identifié.');
    }

    final normalizedPlate = plateNumber.trim().toUpperCase();

    _validate(
      brand: brand,
      model: model,
      plateNumber: normalizedPlate,
      year: year,
      seats: seats,
    );

    final existing =
        await _vehiclesCollection.where('ownerId', isEqualTo: ownerId).get();

    if (existing.docs.length >= AppConstants.maxVehiclesPerUser) {
      throw Exception(
        'Vous ne pouvez pas enregistrer plus de '
        '${AppConstants.maxVehiclesPerUser} véhicules.',
      );
    }

    final alreadyRegistered = existing.docs.any(
      (document) =>
          (document.data()['plateNumber']?.toString() ?? '').toUpperCase() ==
          normalizedPlate,
    );

    if (alreadyRegistered) {
      throw Exception(
        'Un véhicule avec cette plaque d\'immatriculation existe déjà.',
      );
    }

    // Le tout premier véhicule devient automatiquement le véhicule
    // par défaut, sinon l'utilisateur n'en aurait aucun de sélectionné.
    final shouldBeDefault = isDefault || existing.docs.isEmpty;

    final document = _vehiclesCollection.doc();

    final vehicle = VehicleModel(
      id: document.id,
      ownerId: ownerId,
      brand: brand.trim(),
      model: model.trim(),
      color: color.trim(),
      plateNumber: normalizedPlate,
      year: year,
      seats: seats,
      isDefault: shouldBeDefault,
      createdAt: DateTime.now(),
    );

    await document.set(vehicle.toFirestore());

    if (shouldBeDefault) {
      await _clearOtherDefaults(ownerId: ownerId, keptVehicleId: document.id);
    }

    return vehicle;
  }

  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    if (vehicle.id.isEmpty) {
      throw Exception('Véhicule introuvable.');
    }

    final normalizedPlate = vehicle.plateNumber.trim().toUpperCase();

    _validate(
      brand: vehicle.brand,
      model: vehicle.model,
      plateNumber: normalizedPlate,
      year: vehicle.year,
      seats: vehicle.seats,
    );

    final updated = VehicleModel.fromEntity(
      vehicle.copyWith(plateNumber: normalizedPlate),
    );

    await _vehiclesCollection.doc(vehicle.id).update(updated.toFirestore());

    if (updated.isDefault) {
      await _clearOtherDefaults(
        ownerId: updated.ownerId,
        keptVehicleId: updated.id,
      );
    }

    return updated;
  }

  Future<void> deleteVehicle({
    required String ownerId,
    required String vehicleId,
  }) async {
    final reference = _vehiclesCollection.doc(vehicleId);
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      throw Exception('Véhicule introuvable.');
    }

    if ((snapshot.data()?['ownerId']?.toString() ?? '') != ownerId) {
      throw Exception(
        'Vous ne pouvez supprimer que vos propres véhicules.',
      );
    }

    final wasDefault = snapshot.data()?['isDefault'] == true;

    await reference.delete();

    // Si on vient de supprimer le véhicule par défaut, on promeut le
    // plus récent des véhicules restants pour ne pas laisser le
    // conducteur sans véhicule sélectionné.
    if (wasDefault) {
      final remaining =
          await _vehiclesCollection.where('ownerId', isEqualTo: ownerId).get();

      if (remaining.docs.isNotEmpty) {
        final sorted = remaining.docs.map(VehicleModel.fromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        await _vehiclesCollection
            .doc(sorted.first.id)
            .update({'isDefault': true});
      }
    }
  }

  Future<void> setDefaultVehicle({
    required String ownerId,
    required String vehicleId,
  }) async {
    final snapshot = await _vehiclesCollection.doc(vehicleId).get();

    if (!snapshot.exists) {
      throw Exception('Véhicule introuvable.');
    }

    if ((snapshot.data()?['ownerId']?.toString() ?? '') != ownerId) {
      throw Exception(
        'Vous ne pouvez modifier que vos propres véhicules.',
      );
    }

    final batch = firestore.batch();

    final vehicles =
        await _vehiclesCollection.where('ownerId', isEqualTo: ownerId).get();

    for (final document in vehicles.docs) {
      batch.update(document.reference, {
        'isDefault': document.id == vehicleId,
      });
    }

    await batch.commit();
  }

  Future<void> _clearOtherDefaults({
    required String ownerId,
    required String keptVehicleId,
  }) async {
    final vehicles = await _vehiclesCollection
        .where('ownerId', isEqualTo: ownerId)
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = firestore.batch();
    var hasChanges = false;

    for (final document in vehicles.docs) {
      if (document.id != keptVehicleId) {
        batch.update(document.reference, {'isDefault': false});
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit();
    }
  }

  void _validate({
    required String brand,
    required String model,
    required String plateNumber,
    required int year,
    required int seats,
  }) {
    if (brand.trim().isEmpty) {
      throw Exception('La marque du véhicule est obligatoire.');
    }

    if (model.trim().isEmpty) {
      throw Exception('Le modèle du véhicule est obligatoire.');
    }

    if (plateNumber.isEmpty) {
      throw Exception('La plaque d\'immatriculation est obligatoire.');
    }

    final currentYear = DateTime.now().year;
    if (year < 1970 || year > currentYear + 1) {
      throw Exception('L\'année du véhicule est invalide.');
    }

    if (seats <= 0 || seats > AppConstants.maxSeatsPerTrip) {
      throw Exception(
        'Le nombre de places doit être compris entre 1 et '
        '${AppConstants.maxSeatsPerTrip}.',
      );
    }
  }
}
