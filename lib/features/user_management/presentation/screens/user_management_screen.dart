
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = FirebaseFirestore.instance.collection('users').snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des utilisateurs')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: users,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Aucun utilisateur.'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final u = UserModel.fromFirestore(docs[i]);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase())),
                  title: Text(u.name.isEmpty ? u.email : u.name),
                  subtitle: Text('${u.email}\nRôle : ${u.role} • ${u.isActive ? 'Actif' : 'Inactif'}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'toggle') {
                        await docs[i].reference.update({'isActive': !u.isActive});
                      } else {
                        await docs[i].reference.update({'role': value});
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'toggle', child: Text(u.isActive ? 'Désactiver' : 'Activer')),
                      const PopupMenuItem(value: 'student', child: Text('Rôle étudiant')),
                      const PopupMenuItem(value: 'admin', child: Text('Rôle administrateur')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
