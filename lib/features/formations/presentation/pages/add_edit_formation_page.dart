import 'package:flutter/material.dart';

import '../../../ufrs/data/models/ufr_model.dart';
import '../../../ufrs/data/repositories/ufr_repository.dart';
import '../../data/models/formation_model.dart';
import '../../data/repositories/formation_repository.dart';

const List<String> kDiplomaTypes = [
  'BTS/DUT',
  'Licence',
  'Master',
  'Ingénieur',
  'Doctorat',
];

/// Formulaire unique pour la création et la modification d'une formation.
class AddEditFormationPage extends StatefulWidget {
  const AddEditFormationPage({super.key, this.existing});

  final FormationModel? existing;

  @override
  State<AddEditFormationPage> createState() => _AddEditFormationPageState();
}

class _AddEditFormationPageState extends State<AddEditFormationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  String? _selectedDiploma;
  String? _selectedUfrId;
  String? _selectedUfrName;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _codeController = TextEditingController(text: widget.existing?.code ?? '');
    _selectedDiploma = widget.existing?.diploma;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUfrId == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une UFR.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final ufrId = _selectedUfrId ?? widget.existing!.ufrId;
    final ufrName = _selectedUfrName ?? widget.existing!.ufrName;

    try {
      if (_isEditing) {
        final updated = FormationModel(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          diploma: _selectedDiploma!,
          ufrId: ufrId,
          ufrName: ufrName,
        );
        await FormationRepository.instance.updateFormation(updated);
      } else {
        final created = FormationModel(
          id: '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          diploma: _selectedDiploma!,
          ufrId: ufrId,
          ufrName: ufrName,
        );
        await FormationRepository.instance.createFormation(created);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Formation modifiée.' : 'Formation ajoutée.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la formation' : 'Ajouter une formation'),
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
                  labelText: 'Nom de la formation',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'ex: LIC-INFO',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedDiploma,
                decoration: const InputDecoration(
                  labelText: 'Type de diplôme',
                  border: OutlineInputBorder(),
                ),
                items: kDiplomaTypes
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDiploma = value),
                validator: (value) => value == null ? 'Sélectionnez un type de diplôme' : null,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<UfrModel>>(
                stream: UfrRepository.instance.getUfrs(),
                builder: (context, snapshot) {
                  final ufrs = snapshot.data ?? [];

                  if (_isEditing && _selectedUfrId == null) {
                    final match = ufrs.where((u) => u.id == widget.existing!.ufrId).toList();
                    if (match.isNotEmpty) {
                      _selectedUfrId = match.first.id;
                      _selectedUfrName = match.first.name;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedUfrId,
                    decoration: const InputDecoration(
                      labelText: 'UFR de rattachement',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text(_isEditing ? widget.existing!.ufrName : 'Sélectionnez une UFR'),
                    items: ufrs
                        .map((u) => DropdownMenuItem(value: u.id, child: Text(u.name)))
                        .toList(),
                    onChanged: (value) {
                      final match = ufrs.where((u) => u.id == value).toList();
                      setState(() {
                        _selectedUfrId = value;
                        _selectedUfrName = match.isNotEmpty ? match.first.name : null;
                      });
                    },
                  );
                },
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
