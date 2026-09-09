import 'package:flutter/material.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/campus_model.dart';
import '../../data/repositories/campus_repository.dart';
import '../widgets/campus_card.dart';
import 'add_edit_campus_page.dart';

class CampusListPage extends StatelessWidget {
  const CampusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = CampusRepository.instance;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Gestion des Campus')),
      body: StreamBuilder<List<CampusModel>>(
        stream: repository.getCampuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final campuses = snapshot.data ?? [];
          if (campuses.isEmpty) {
            return const Center(child: Text('Aucun campus enregistré.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: campuses.length,
            itemBuilder: (context, index) {
              final campus = campuses[index];
              return CampusCard(
                campus: campus,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditCampusPage(existing: campus),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await confirmSoftDelete(context, campus.name);
                  if (confirmed) {
                    await repository.softDeleteCampus(campus.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Campus "${campus.name}" supprimé.')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditCampusPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
