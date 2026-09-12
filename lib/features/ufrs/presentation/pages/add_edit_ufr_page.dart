import 'package:flutter/material.dart';

import '../../../campus/data/models/campus_model.dart';
import '../../../campus/data/repositories/campus_repository.dart';
import '../../data/models/ufr_model.dart';
import '../../data/repositories/ufr_repository.dart';

/// Formulaire unique servant à la fois pour la création et la modification
/// d'une UFR (si [existing] est fourni, l'écran passe en mode édition).
class AddEditUfrPage extends StatefulWidget {
  const AddEditUfrPage({super.key, this.existing});

  final UfrModel? existing;

  @override
  State<AddEditUfrPage> createState() => _AddEditUfrPageState();
}

class _AddEditUfrPageState extends State<AddEditUfrPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  String? _selectedCampusId;
  String? _selectedCampusName;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _codeController = TextEditingController(text: widget.existing?.code ?? '');
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
    if (_selectedCampusId == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un campus.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final campusId = _selectedCampusId ?? widget.existing!.campusId;
    final campusName = _selectedCampusName ?? widget.existing!.campusName;

    try {
      if (_isEditing) {
        final updated = UfrModel(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          campusId: campusId,
          campusName: campusName,
        );
        await UfrRepository.instance.updateUfr(updated);
      } else {
        final created = UfrModel(
          id: '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          campusId: campusId,
          campusName: campusName,
        );
        await UfrRepository.instance.createUfr(created);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'UFR modifiée.' : 'UFR ajoutée.')),
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
      appBar: AppBar(title: Text(_isEditing ? 'Modifier l\'UFR' : 'Ajouter une UFR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l'UFR",
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code / Sigle',
                  hintText: 'ex: UFR-SEA',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<CampusModel>>(
                stream: CampusRepository.instance.getCampuses(),
                builder: (context, snapshot) {
                  final campuses = snapshot.data ?? [];

                  if (_isEditing && _selectedCampusId == null) {
                    final match = campuses
                        .where((c) => c.id == widget.existing!.campusId)
                        .toList();
                    if (match.isNotEmpty) {
                      _selectedCampusId = match.first.id;
                      _selectedCampusName = match.first.name;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCampusId,
                    decoration: const InputDecoration(
                      labelText: 'Campus de rattachement',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text(
                      _isEditing ? widget.existing!.campusName : 'Sélectionnez un campus',
                    ),
                    items: campuses
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) {
                      final match = campuses.where((c) => c.id == value).toList();
                      setState(() {
                        _selectedCampusId = value;
                        _selectedCampusName = match.isNotEmpty ? match.first.name : null;
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
