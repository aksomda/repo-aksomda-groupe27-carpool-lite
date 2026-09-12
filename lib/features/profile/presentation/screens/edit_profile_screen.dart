import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileProvider profileProvider;
  final ProfileEntity profile;

  const EditProfileScreen({
    super.key,
    required this.profileProvider,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late Sex _sex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _sex = widget.profile.sex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = ProfileEntity(
      uid: widget.profile.uid,
      name: _nameController.text.trim(),
      email: widget.profile.email,
      phone: _phoneController.text.trim(),
      sex: _sex,
      universityId: widget.profile.universityId,
      campusId: widget.profile.campusId,
      isVerified: widget.profile.isVerified,
    );

    final success = await widget.profileProvider.updateProfile(updated);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.profileProvider.errorMessage ?? 'Erreur inconnue.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le téléphone est requis' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Sex>(
              initialValue: _sex,
              decoration: const InputDecoration(
                labelText: 'Sexe',
                border: OutlineInputBorder(),
              ),
              items: Sex.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s == Sex.homme ? 'Homme' : 'Femme'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _sex = v!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}