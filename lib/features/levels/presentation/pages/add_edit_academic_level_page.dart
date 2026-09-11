import 'package:flutter/material.dart';

import '../../../formations/data/models/formation_model.dart';
import '../../../formations/data/repositories/formation_repository.dart';
import '../../data/models/academic_level_model.dart';
import '../../data/repositories/academic_level_repository.dart';

/// Formulaire unique pour la création et la modification d'un niveau/classe.
class AddEditAcademicLevelPage extends StatefulWidget {
  const AddEditAcademicLevelPage({super.key, this.existing});

  final AcademicLevelModel? existing;

  @override
  State<AddEditAcademicLevelPage> createState() => _AddEditAcademicLevelPageState();
}

class _AddEditAcademicLevelPageState extends State<AddEditAcademicLevelPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _academicYearController;

  String? _selectedFormationId;
  String? _selectedFormationName;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _academicYearController =
        TextEditingController(text: widget.existing?.academicYear ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFormationId == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une formation.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final formationId = _selectedFormationId ?? widget.existing!.formationId;
    final formationName = _selectedFormationName ?? widget.existing!.formationName;

    try {
      if (_isEditing) {
        final updated = AcademicLevelModel(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          academicYear: _academicYearController.text.trim(),
          formationId: formationId,
          formationName: formationName,
        );
        await AcademicLevelRepository.instance.updateLevel(updated);
      } else {
        final created = AcademicLevelModel(
          id: '',
          name: _nameController.text.trim(),
          academicYear: _academicYearController.text.trim(),
          formationId: formationId,
          formationName: formationName,
        );
        await AcademicLevelRepository.instance.createLevel(created);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Niveau modifié.' : 'Niveau ajouté.')),
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
        title: Text(_isEditing ? 'Modifier le niveau' : 'Ajouter un niveau/classe'),
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
                  labelText: 'Nom du niveau/classe',
                  hintText: 'ex: Licence 1',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(
                  labelText: 'Année académique',
                  hintText: 'ex: 2025-2026',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<FormationModel>>(
                stream: FormationRepository.instance.getFormations(),
                builder: (context, snapshot) {
                  final formations = snapshot.data ?? [];

                  if (_isEditing && _selectedFormationId == null) {
                    final match = formations
                        .where((f) => f.id == widget.existing!.formationId)
                        .toList();
                    if (match.isNotEmpty) {
                      _selectedFormationId = match.first.id;
                      _selectedFormationName = match.first.name;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedFormationId,
                    decoration: const InputDecoration(
                      labelText: 'Formation de rattachement',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text(
                      _isEditing ? widget.existing!.formationName : 'Sélectionnez une formation',
                    ),
                    items: formations
                        .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (value) {
                      final match = formations.where((f) => f.id == value).toList();
                      setState(() {
                        _selectedFormationId = value;
                        _selectedFormationName = match.isNotEmpty ? match.first.name : null;
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
