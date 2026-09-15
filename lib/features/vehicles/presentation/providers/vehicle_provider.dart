// Gestion d'état des véhicules de l'utilisateur.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/get_user_vehicles_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';

class VehicleProvider extends ChangeNotifier {
  final AddVehicleUseCase addVehicleUseCase;
  final UpdateVehicleUseCase updateVehicleUseCase;
  final GetUserVehiclesUseCase getUserVehiclesUseCase;

  VehicleProvider({
    required this.addVehicleUseCase,
    required this.updateVehicleUseCase,
    required this.getUserVehiclesUseCase,
  });

  List<VehicleEntity> vehicles = [];
  bool isLoading = true;
  String? errorMessage;

  bool isSaving = false;
  String? saveError;

  StreamSubscription<List<VehicleEntity>>? _subscription;
  String? _ownerId;

  /// (Ré)abonne le provider aux véhicules du conducteur connecté.
  /// Sans effet si déjà abonné pour le même [ownerId].
  void listenToUserVehicles(String ownerId) {
    if (_ownerId == ownerId && _subscription != null) return;

    _ownerId = ownerId;
    _subscription?.cancel();
    isLoading = true;
    notifyListeners();

    _subscription = getUserVehiclesUseCase(ownerId).listen(
      (data) {
        vehicles = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Impossible de charger vos véhicules : $e';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Ajoute un véhicule. Retourne `true` en cas de succès.
  Future<bool> addVehicle(VehicleEntity vehicle) async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      await addVehicleUseCase(vehicle);
      return true;
    } catch (e) {
      saveError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Modifie un véhicule existant. Retourne `true` en cas de succès.
  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    isSaving = true;
    saveError = null;
    notifyListeners();

    try {
      await updateVehicleUseCase(vehicle);
      return true;
    } catch (e) {
      saveError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
