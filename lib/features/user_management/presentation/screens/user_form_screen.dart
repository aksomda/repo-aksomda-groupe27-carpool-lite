import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/admin_create_user_datasource.dart';

/// Formulaire unique pour la création et la modification d'un utilisateur,
/// depuis l'écran "Gestion des utilisateurs" (accès administrateur).
///
/// En modification, l'email n'est pas modifiable ici : il est géré par
/// Firebase Authentication (pas seulement par le document Firestore), le
/// changer sans passer par Auth désynchroniserait la connexion de
/// l'utilisateur. Seules les informations du profil Firestore sont
/// éditables (nom, téléphone, sexe, université, campus, rôle, statut).
class UserFormScreen extends StatefulWidget {
  final String? docId;
  final UserModel? existing;

  const UserFormScreen({super.key, this.docId, this.existing});

  bool get isEditing => existing != null;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();

  late Sex _sex;
  late String _role;
  late bool _isActive;
  String? _universityId;
  String? _campusId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _sex = existing?.sex ?? Sex.homme;
    _role = existing?.role ?? 'student';
    _isActive = existing?.isActive ?? true;
    _universityId = existing?.universityId;
    _campusId = existing?.campusId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        final docId = widget.docId;
        if (docId == null) {
          throw Exception('Identifiant utilisateur manquant : modification impossible.');
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'sex': _sex.name,
          'universityId': _universityId,
          'campusId': _campusId,
          'role': _role,
          'isActive': _isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await AdminCreateUserDataSource(firestore: FirebaseFirestore.instance)
            .createUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          sex: _sex,
          role: _role,
          isActive: _isActive,
          universityId: _universityId,
          campusId: _campusId,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? 'Utilisateur modifié.' : 'Utilisateur créé.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom complet'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              enabled: !widget.isEditing,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                helperText: widget.isEditing
                    ? 'Non modifiable ici (géré par Firebase Authentication).'
                    : null,
              ),
              validator: (value) {
                if (widget.isEditing) return null;
                if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
                if (!value.contains('@')) return 'Adresse email invalide';
                return null;
              },
            ),
            if (!widget.isEditing) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe provisoire',
                  helperText: '6 caractères minimum',
                ),
                validator: (value) {
                  if (widget.isEditing) return null;
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Sex>(
              initialValue: _sex,
              decoration: const InputDecoration(labelText: 'Sexe'),
              items: Sex.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s == Sex.homme ? 'Homme' : 'Femme')))
                  .toList(),
              onChanged: (value) => setState(() => _sex = value ?? _sex),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rôle'),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              ],
              onChanged: (value) => setState(() => _role = value ?? _role),
            ),
            const SizedBox(height: 12),
            _UniversityDropdown(
              value: _universityId,
              onChanged: (value) => setState(() {
                _universityId = value;
                _campusId = null;
              }),
            ),
            if (_universityId != null) ...[
              const SizedBox(height: 12),
              _CampusDropdown(
                universityId: _universityId!,
                value: _campusId,
                onChanged: (value) => setState(() => _campusId = value),
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Compte actif'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.isEditing ? 'Enregistrer' : 'Créer l\'utilisateur'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _UniversityDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('universities').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        final validValue = docs.any((d) => d.id == value) ? value : null;

        return DropdownButtonFormField<String?>(
          initialValue: validValue,
          decoration: const InputDecoration(labelText: 'Université (optionnel)'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Aucune')),
            ...docs.map(
              (d) => DropdownMenuItem<String?>(
                value: d.id,
                child: Text((d.data()['name'] as String?) ?? d.id),
              ),
            ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

class _CampusDropdown extends StatelessWidget {
  final String universityId;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CampusDropdown({
    required this.universityId,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('campus')
          .where('universityId', isEqualTo: universityId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        final validValue = docs.any((d) => d.id == value) ? value : null;

        return DropdownButtonFormField<String?>(
          initialValue: validValue,
          decoration: const InputDecoration(labelText: 'Campus (optionnel)'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Aucun')),
            ...docs.map(
              (d) => DropdownMenuItem<String?>(
                value: d.id,
                child: Text((d.data()['name'] as String?) ?? d.id),
              ),
            ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}
