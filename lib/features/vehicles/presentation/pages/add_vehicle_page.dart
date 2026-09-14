import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/vehicle.dart';
import '../../data/datasources/vehicles_remote_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();

  final _modelController = TextEditingController();

  final _plateController = TextEditingController();

  final _seatsController = TextEditingController();

  bool _isLoading = false;

  late final VehicleRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;

    final remoteDataSource = VehiclesRemoteDataSource(firestore);

    _repository = VehicleRepositoryImpl(remoteDataSource);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _seatsController.dispose();

    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = Vehicle(
        id: '',
        ownerId: 'CURRENT_USER_ID',
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        plate: _plateController.text.trim(),
        seats: int.parse(_seatsController.text),
      );

      await _repository.addVehicle(vehicle);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Véhicule ajouté avec succès !')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(title: const Text('Ajouter un véhicule')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                const Icon(Icons.directions_car_outlined, size: 75, color: Color(0xFF1769E0)),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _brandController,

                  decoration: _inputDecoration('MARQUE', 'Ex : Toyota', Icons.directions_car),

                  validator: _requiredValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _modelController,

                  decoration: _inputDecoration('MODÈLE', 'Ex : Corolla', Icons.car_rental_outlined),

                  validator: _requiredValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _plateController,

                  decoration: _inputDecoration(
                    'IMMATRICULATION',
                    'Ex : 1234 BF 01',
                    Icons.pin_outlined,
                  ),

                  validator: _requiredValidator,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _seatsController,

                  keyboardType: TextInputType.number,

                  decoration: _inputDecoration('NOMBRE DE PLACES', 'Ex : 4', Icons.people_outline),

                  validator: (value) {
                    final seats = int.tryParse(value ?? '');

                    if (seats == null || seats <= 0) {
                      return 'Nombre de places invalide';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveVehicle,

                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add),

                    label: Text(_isLoading ? 'Ajout...' : 'Ajouter le véhicule'),

                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1769E0),

                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF1769E0)),

      filled: true,

      fillColor: const Color(0xFFF2F4F7),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ obligatoire';
    }

    return null;
  }
}
