import 'package:flutter/material.dart';

import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleProvider vehicleProvider;
  final String ownerId;

  const AddVehicleScreen({
    super.key,
    required this.vehicleProvider,
    required this.ownerId,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _colorController = TextEditingController();

  int _seats = 4;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await widget.vehicleProvider.addVehicle(
      ownerId: widget.ownerId,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      plateNumber: _plateNumberController.text.trim(),
      color: _colorController.text.trim(),
      seats: _seats,
    );

    if (!mounted) return;

    final provider = widget.vehicleProvider;
    final message = provider.errorMessage ?? provider.successMessage;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    if (success && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.vehicleProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un véhicule'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marque',
                  hintText: 'Ex. Toyota',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La marque est obligatoire.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modèle',
                  hintText: 'Ex. Corolla',
                  prefixIcon: Icon(Icons.directions_car_filled_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le modèle est obligatoire.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de plaque',
                  hintText: 'Ex. AB-1234-C',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le numéro de plaque est obligatoire.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Couleur',
                  hintText: 'Ex. Gris',
                  prefixIcon: Icon(Icons.palette_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La couleur est obligatoire.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Nombre de places',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  IconButton(
                    onPressed: _seats > 1
                        ? () => setState(() => _seats--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_seats',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _seats < 8
                        ? () => setState(() => _seats++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    isSaving ? 'Enregistrement...' : 'Ajouter le véhicule',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
