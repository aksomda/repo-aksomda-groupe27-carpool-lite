import 'package:flutter/material.dart';

import '../../../universities/data/models/university_model.dart';
import '../../../universities/data/repositories/university_repository.dart';
import '../../data/models/campus_model.dart';
import '../../data/repositories/campus_repository.dart';

/// Formulaire unique pour la création et la modification d'un campus.
class AddEditCampusPage extends StatefulWidget {
  const AddEditCampusPage({super.key, this.existing});

  final CampusModel? existing;

  @override
  State<AddEditCampusPage> createState() => _AddEditCampusPageState();
}

class _AddEditCampusPageState extends State<AddEditCampusPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  String? _selectedUniversityId;
  String? _selectedUniversityName;
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
    if (_selectedUniversityId == null && widget.existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une université.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final universityId = _selectedUniversityId ?? widget.existing!.universityId;
    final universityName = _selectedUniversityName ?? widget.existing!.universityName;

    try {
      if (_isEditing) {
        final updated = CampusModel(
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          universityId: universityId,
          universityName: universityName,
        );
        await CampusRepository.instance.updateCampus(updated);
      } else {
        final created = CampusModel(
          id: '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          universityId: universityId,
          universityName: universityName,
        );
        await CampusRepository.instance.createCampus(created);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Campus modifié.' : 'Campus ajouté.')),
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
      appBar: AppBar(title: Text(_isEditing ? 'Modifier le campus' : 'Ajouter un campus')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du campus',
                  hintText: 'ex: Campus de Nasso',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: 'ex: CAMP-NASSO',
                  border: OutlineInputBorder(),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<UniversityModel>>(
                stream: UniversityRepository.instance.getUniversities(),
                builder: (context, snapshot) {
                  final universities = snapshot.data ?? [];

                  if (_isEditing && _selectedUniversityId == null) {
                    final match = universities
                        .where((u) => u.id == widget.existing!.universityId)
                        .toList();
                    if (match.isNotEmpty) {
                      _selectedUniversityId = match.first.id;
                      _selectedUniversityName = match.first.name;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedUniversityId,
                    decoration: const InputDecoration(
                      labelText: 'Université de rattachement',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text(
                      _isEditing
                          ? widget.existing!.universityName
                          : 'Sélectionnez une université',
                    ),
                    items: universities
                        .map((u) => DropdownMenuItem(value: u.id, child: Text(u.name)))
                        .toList(),
                    onChanged: (value) {
                      final match = universities.where((u) => u.id == value).toList();
                      setState(() {
                        _selectedUniversityId = value;
                        _selectedUniversityName = match.isNotEmpty ? match.first.name : null;
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
