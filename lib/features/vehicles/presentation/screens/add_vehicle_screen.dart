import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_provider.dart';

/// Formulaire d'ajout ou de modification d'un véhicule.
///
/// Si [vehicle] est fourni, l'écran passe en mode édition et pré-remplit
/// les champs ; sinon il crée un nouveau véhicule.
class AddVehicleScreen extends StatefulWidget {
  final String ownerId;
  final VehicleEntity? vehicle;

  const AddVehicleScreen({
    super.key,
    required this.ownerId,
    this.vehicle,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late final TextEditingController _plateController;
  late final TextEditingController _yearController;

  late int _seats;
  late bool _isDefault;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();

    final vehicle = widget.vehicle;

    _brandController = TextEditingController(text: vehicle?.brand ?? '');
    _modelController = TextEditingController(text: vehicle?.model ?? '');
    _colorController = TextEditingController(text: vehicle?.color ?? '');
    _plateController = TextEditingController(text: vehicle?.plateNumber ?? '');
    _yearController = TextEditingController(
      text: (vehicle?.year ?? DateTime.now().year).toString(),
    );

    _seats = vehicle?.seats ?? 4;
    _isDefault = vehicle?.isDefault ?? false;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VehicleProvider>();

    final year = int.parse(_yearController.text.trim());

    final success = _isEditing
        ? await provider.updateVehicle(
            widget.vehicle!.copyWith(
              brand: _brandController.text.trim(),
              model: _modelController.text.trim(),
              color: _colorController.text.trim(),
              plateNumber: _plateController.text.trim(),
              year: year,
              seats: _seats,
              isDefault: _isDefault,
            ),
          )
        : await provider.addVehicle(
            ownerId: widget.ownerId,
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            color: _colorController.text.trim(),
            plateNumber: _plateController.text.trim(),
            year: year,
            seats: _seats,
            isDefault: _isDefault,
          );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.successMessage ?? 'Véhicule enregistré.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Impossible d\'enregistrer le véhicule.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier le véhicule' : 'Ajouter un véhicule',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _brandController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Marque',
                hintText: 'Toyota, Hyundai, Peugeot...',
                prefixIcon: Icon(Icons.branding_watermark_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  Validators.required(value, field: 'La marque'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _modelController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Modèle',
                hintText: 'Corolla, Accent, 206...',
                prefixIcon: Icon(Icons.directions_car_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  Validators.required(value, field: 'Le modèle'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Plaque d\'immatriculation',
                hintText: 'RC-1234-A',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(),
              ),
              validator: Validators.plateNumber,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Année',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.vehicleYear,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _colorController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Couleur',
                      prefixIcon: Icon(Icons.palette_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.required(value, field: 'La couleur'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Nombre de places passagers',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _seats > 1
                      ? () => setState(() => _seats--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_seats',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _seats < AppConstants.maxSeatsPerTrip
                      ? () => setState(() => _seats++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
              title: const Text('Véhicule par défaut'),
              subtitle: const Text(
                'Proposé automatiquement lors de la publication d\'un trajet.',
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: provider.isSubmitting ? null : _submit,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isEditing ? 'Enregistrer les modifications' : 'Ajouter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
