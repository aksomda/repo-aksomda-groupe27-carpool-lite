// Formulaire d'ajout / modification d'un véhicule.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_provider.dart';

/// Catégories usuelles de véhicule utilisées pour le covoiturage
/// universitaire. Champ libre également accepté via "Autre".
const List<String> kVehicleCategories = [
  'Berline',
  'SUV',
  'Citadine',
  'Minibus',
  'Moto',
  'Autre',
];

/// Formulaire unique pour la création et la modification d'un véhicule.
///
/// Passer [existing] bascule l'écran en mode modification (formulaire
/// pré-rempli, appel à [VehicleProvider.updateVehicle]) ; le laisser à
/// `null` garde le comportement d'ajout classique.
///
/// Nécessite un [VehicleProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart).
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key, this.existing});

  final VehicleEntity? existing;

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _immatriculationController;
  late final TextEditingController _chassisController;
  late final TextEditingController _marqueController;
  late final TextEditingController _modeleController;
  late final TextEditingController _placesController;
  late final TextEditingController _autreCategorieController;

  late String _categorie;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _immatriculationController = TextEditingController(
      text: existing?.immatriculation ?? '',
    );
    _chassisController = TextEditingController(
      text: existing?.numeroChassis ?? '',
    );
    _marqueController = TextEditingController(text: existing?.marque ?? '');
    _modeleController = TextEditingController(text: existing?.modele ?? '');
    _placesController = TextEditingController(
      text: existing != null ? existing.nombrePlaces.toString() : '',
    );

    final knownCategories = kVehicleCategories.where((c) => c != 'Autre');
    final isKnownCategory = existing != null && knownCategories.contains(existing.categorie);
    _categorie = existing == null
        ? kVehicleCategories.first
        : (isKnownCategory ? existing.categorie : 'Autre');
    _autreCategorieController = TextEditingController(
      text: (existing != null && !isKnownCategory) ? existing.categorie : '',
    );
  }

  @override
  void dispose() {
    _immatriculationController.dispose();
    _chassisController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _placesController.dispose();
    _autreCategorieController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  String? _placesValidator(String? value) {
    final places = int.tryParse((value ?? '').trim());
    if (places == null || places <= 0) {
      return 'Entrez un nombre de places valide';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final categorieFinale = _categorie == 'Autre'
        ? _autreCategorieController.text.trim()
        : _categorie;

    if (categorieFinale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Précisez la catégorie du véhicule.')),
      );
      return;
    }

    final ownerId = Injector.authProvider.user?.uid ?? '';
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour enregistrer un véhicule.')),
      );
      return;
    }

    final provider = context.read<VehicleProvider>();

    final vehicle = VehicleEntity(
      id: widget.existing?.id ?? '',
      ownerId: widget.existing?.ownerId ?? ownerId,
      immatriculation: _immatriculationController.text.trim(),
      numeroChassis: _chassisController.text.trim(),
      marque: _marqueController.text.trim(),
      modele: _modeleController.text.trim(),
      categorie: categorieFinale,
      nombrePlaces: int.parse(_placesController.text.trim()),
    );

    final success = _isEditing
        ? await provider.updateVehicle(vehicle)
        : await provider.addVehicle(vehicle);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Véhicule modifié.' : 'Véhicule ajouté.')),
      );
      Navigator.of(context).pop();
    } else if (provider.saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.saveError!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<VehicleProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le véhicule' : 'Ajouter un véhicule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _immatriculationController,
                decoration: const InputDecoration(
                  labelText: "Numéro d'immatriculation",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chassisController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de chassis',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marqueController,
                decoration: const InputDecoration(
                  labelText: 'Marque',
                  hintText: 'ex : Toyota',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modeleController,
                decoration: const InputDecoration(
                  labelText: 'Modèle',
                  hintText: 'ex : Corolla',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                decoration: const InputDecoration(
                  labelText: 'Catégorie du véhicule',
                  border: OutlineInputBorder(),
                ),
                items: kVehicleCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _categorie = value);
                },
              ),
              if (_categorie == 'Autre') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _autreCategorieController,
                  decoration: const InputDecoration(
                    labelText: 'Précisez la catégorie',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _categorie == 'Autre' ? _requiredValidator(value) : null,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _placesController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de places',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _placesValidator,
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
}
