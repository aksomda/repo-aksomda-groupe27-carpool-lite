import 'package:flutter/material.dart';

import '../../data/models/university_model.dart';
import '../../data/repositories/university_repository.dart';

/// Formulaire unique pour la création et la modification d'une université.
///
/// Passer [existing] bascule l'écran en mode modification (formulaire
/// pré-rempli, appel à [UniversityRepository.updateUniversity]) ; le laisser
/// à `null` garde le comportement d'ajout classique.
class AddEditUniversityPage extends StatefulWidget {
  const AddEditUniversityPage({super.key, this.existing});

  final UniversityModel? existing;

  @override
  State<AddEditUniversityPage> createState() => _AddEditUniversityPageState();
}

class _AddEditUniversityPageState extends State<AddEditUniversityPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _cityController = TextEditingController(text: widget.existing?.city ?? '');
    _addressController = TextEditingController(text: widget.existing?.address ?? '');
    _latitudeController = TextEditingController(text: widget.existing?.latitude ?? '');
    _longitudeController = TextEditingController(text: widget.existing?.longitude ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final updated = UniversityModel(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim(),
        );
        await UniversityRepository.instance.updateUniversity(updated);
      } else {
        final created = UniversityModel(
          id: '',
          name: _nameController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim(),
        );
        await UniversityRepository.instance.createUniversity(created);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Université modifiée.' : 'Université ajoutée.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Modifier l'université" : 'Ajouter une université'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'université",
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: 'ex: 11,20926° N',
                        border: OutlineInputBorder(),
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: 'ex: -4,41762° O',
                        border: OutlineInputBorder(),
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
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
