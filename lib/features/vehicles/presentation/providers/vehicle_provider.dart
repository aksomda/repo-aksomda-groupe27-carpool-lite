import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/delete_vehicle_usecase.dart';
import '../../domain/usecases/get_user_vehicles_usecase.dart';
import '../../domain/usecases/set_default_vehicle_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';

class VehicleProvider extends ChangeNotifier {
  final GetUserVehiclesUseCase getUserVehiclesUseCase;
  final AddVehicleUseCase addVehicleUseCase;
  final UpdateVehicleUseCase updateVehicleUseCase;
  final DeleteVehicleUseCase deleteVehicleUseCase;
  final SetDefaultVehicleUseCase setDefaultVehicleUseCase;

  VehicleProvider({
    required this.getUserVehiclesUseCase,
    required this.addVehicleUseCase,
    required this.updateVehicleUseCase,
    required this.deleteVehicleUseCase,
    required this.setDefaultVehicleUseCase,
  });

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<VehicleEntity> _vehicles = const [];

  StreamSubscription<List<VehicleEntity>>? _subscription;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<VehicleEntity> get vehicles => _vehicles;

  /// Véhicule sélectionné par défaut, s'il existe.
  VehicleEntity? get defaultVehicle {
    for (final vehicle in _vehicles) {
      if (vehicle.isDefault) return vehicle;
    }
    return _vehicles.isEmpty ? null : _vehicles.first;
  }

  bool get hasVehicles => _vehicles.isNotEmpty;

  // ============================================================
  // CHARGEMENT
  // ============================================================

  void loadUserVehicles(String ownerId) {
    _subscription?.cancel();

    if (ownerId.isEmpty) {
      _vehicles = const [];
      _isLoading = false;
      _errorMessage = 'Utilisateur non connecté.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _clearMessages();
    notifyListeners();

    _subscription = getUserVehiclesUseCase(ownerId).listen(
      (results) {
        _vehicles = results;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = messageFromError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ============================================================
  // CRÉATION / MISE À JOUR / SUPPRESSION
  // ============================================================

  Future<bool> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required int year,
    required int seats,
    bool isDefault = false,
  }) async {
    return _run(() async {
      await addVehicleUseCase(
        ownerId: ownerId,
        brand: brand,
        model: model,
        color: color,
        plateNumber: plateNumber,
        year: year,
        seats: seats,
        isDefault: isDefault,
      );
      _successMessage = 'Véhicule ajouté avec succès.';
    });
  }

  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    return _run(() async {
      await updateVehicleUseCase(vehicle);
      _successMessage = 'Véhicule mis à jour.';
    });
  }

  Future<bool> deleteVehicle({
    required String ownerId,
    required String vehicleId,
  }) async {
    return _run(() async {
      await deleteVehicleUseCase(ownerId: ownerId, vehicleId: vehicleId);
      _successMessage = 'Véhicule supprimé.';
    });
  }

  Future<bool> setDefaultVehicle({
    required String ownerId,
    required String vehicleId,
  }) async {
    return _run(() async {
      await setDefaultVehicleUseCase(ownerId: ownerId, vehicleId: vehicleId);
      _successMessage = 'Véhicule par défaut mis à jour.';
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isSubmitting = true;
    _clearMessages();
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      _errorMessage = messageFromError(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
