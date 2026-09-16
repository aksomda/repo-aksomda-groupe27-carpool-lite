import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/user_management/data/user_management_remote_datasource.dart';

/// Écran de sélection d'un utilisateur (destinataire d'un nouveau message ou
/// d'une nouvelle notification) parmi les comptes de l'application.
class UserPickerScreen extends StatefulWidget {
  final String title;
  final String currentUserId;

  const UserPickerScreen({
    super.key,
    required this.title,
    required this.currentUserId,
  });

  @override
  State<UserPickerScreen> createState() => _UserPickerScreenState();
}

class _UserPickerScreenState extends State<UserPickerScreen> {
  final _dataSource = UserManagementRemoteDataSource(
    firestore: FirebaseFirestore.instance,
  );

  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _search = value.toLowerCase().trim());
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom ou e-mail...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _dataSource.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                final users = (snapshot.data ?? [])
                    .where((user) => user.uid != widget.currentUserId)
                    .where((user) {
                      if (_search.isEmpty) return true;

                      return user.name.toLowerCase().contains(_search) ||
                          user.email.toLowerCase().contains(_search);
                    })
                    .toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text('Aucun utilisateur trouvé.'),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () => Navigator.of(context).pop(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
