import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/get_user_vehicles_usecase.dart';

class VehicleProvider extends ChangeNotifier {
  final AddVehicleUseCase addVehicleUseCase;
  final GetUserVehiclesUseCase getUserVehiclesUseCase;

  VehicleProvider({
    required this.addVehicleUseCase,
    required this.getUserVehiclesUseCase,
  });

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<VehicleEntity> _vehicles = [];

  StreamSubscription<List<VehicleEntity>>? _vehiclesSubscription;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  List<VehicleEntity> get vehicles => _vehicles;

  Future<bool> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String plateNumber,
    required String color,
    required int seats,
  }) async {
    _setLoading(true);
    _clearMessages();

    var success = false;

    try {
      await addVehicleUseCase(
        ownerId: ownerId,
        brand: brand,
        model: model,
        plateNumber: plateNumber,
        color: color,
        seats: seats,
      );

      _successMessage = 'Véhicule ajouté avec succès.';
      success = true;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _setLoading(false);
    }

    return success;
  }

  void listenToUserVehicles({
    required String ownerId,
  }) {
    _vehiclesSubscription?.cancel();

    _vehiclesSubscription = getUserVehiclesUseCase(
      ownerId: ownerId,
    ).listen(
      (vehicles) {
        _vehicles = vehicles;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _cleanError(error);
        notifyListeners();
      },
    );
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  @override
  void dispose() {
    _vehiclesSubscription?.cancel();
    super.dispose();
  }
}
