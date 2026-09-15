import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

/// Formulaire unique pour la publication et la modification d'un trajet.
///
/// Passer [existing] bascule l'écran en mode modification (formulaire
/// pré-rempli, appel à [TripProvider.updateTrip]) ; le laisser à `null`
/// garde le comportement de publication classique.
///
/// Nécessite un [TripProvider] et un [VehicleProvider] fournis plus haut
/// dans l'arbre (voir app_router.dart).
class PublishTripScreen extends StatefulWidget {
  const PublishTripScreen({super.key, this.existing});

  final TripEntity? existing;

  @override
  State<PublishTripScreen> createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _departController;
  late final TextEditingController _arriveeController;
  late final TextEditingController _prixController;

  String? _selectedImmatriculation;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _departController = TextEditingController(text: existing?.lieuDepart ?? '');
    _arriveeController = TextEditingController(text: existing?.lieuArrivee ?? '');
    _prixController = TextEditingController(
      text: existing != null ? existing.prixParPlace.toString() : '',
    );
    _selectedImmatriculation = existing?.immatriculationVehicule;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = Injector.authProvider.user?.uid ?? '';
      context.read<VehicleProvider>().listenToUserVehicles(ownerId);
    });
  }

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  String? _prixValidator(String? value) {
    final prix = num.tryParse((value ?? '').trim());
    if (prix == null || prix <= 0) {
      return 'Entrez un prix par place valide';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImmatriculation == null || _selectedImmatriculation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez le véhicule utilisé pour ce trajet.')),
      );
      return;
    }

    final driverId = Injector.authProvider.user?.uid ?? '';
    if (driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour publier un trajet.')),
      );
      return;
    }

    final tripProvider = context.read<TripProvider>();
    final lieuDepart = _departController.text.trim();
    final lieuArrivee = _arriveeController.text.trim();
    final prix = num.parse(_prixController.text.trim());

    final success = _isEditing
        ? await tripProvider.updateTrip(
            existing: widget.existing!,
            immatriculationVehicule: _selectedImmatriculation!,
            lieuDepart: lieuDepart,
            lieuArrivee: lieuArrivee,
            prixParPlace: prix,
          )
        : await tripProvider.publishTrip(
            driverId: driverId,
            immatriculationVehicule: _selectedImmatriculation!,
            lieuDepart: lieuDepart,
            lieuArrivee: lieuArrivee,
            prixParPlace: prix,
          );

    if (!mounted) return;

    if (success) {
      final distanceText = tripProvider.lastDistance?.distanceText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Trajet modifié.'
                : 'Trajet publié'
                    '${distanceText != null ? ' ($distanceText)' : ''}.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else if (tripProvider.saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tripProvider.saveError!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TripProvider>().isSaving;
    final vehicleProvider = context.watch<VehicleProvider>();
    final vehicles = vehicleProvider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le trajet' : "Publication d'un trajet"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (vehicleProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (vehicles.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Vous n'avez encore aucun véhicule enregistré. "
                    "Ajoutez-en un depuis \"Mes véhicules\" avant de publier un trajet.",
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedImmatriculation,
                  decoration: const InputDecoration(
                    labelText: 'Véhicule (immatriculation)',
                    border: OutlineInputBorder(),
                  ),
                  items: _dropdownItems(vehicles),
                  onChanged: (value) {
                    setState(() => _selectedImmatriculation = value);
                  },
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de départ',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _arriveeController,
                decoration: const InputDecoration(
                  labelText: "Lieu d'arrivée",
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(
                  labelText: 'Prix par place (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _prixValidator,
              ),
              const SizedBox(height: 8),
              Text(
                "La distance du trajet est calculée automatiquement à "
                "l'enregistrement, à partir du lieu de départ et du lieu "
                "d'arrivée saisis.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems(List<VehicleEntity> vehicles) {
    final items = vehicles
        .map(
          (v) => DropdownMenuItem(
            value: v.immatriculation,
            child: Text('${v.immatriculation} · ${v.marque} ${v.modele}'),
          ),
        )
        .toList();

    // Garantit que le véhicule pré-sélectionné en mode édition apparaît
    // bien dans la liste, même s'il n'a pas (encore) été chargé.
    if (_selectedImmatriculation != null &&
        !vehicles.any((v) => v.immatriculation == _selectedImmatriculation)) {
      items.insert(
        0,
        DropdownMenuItem(
          value: _selectedImmatriculation,
          child: Text(_selectedImmatriculation!),
        ),
      );
    }

    return items;
  }
}
