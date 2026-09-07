import 'package:flutter/material.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/formation_model.dart';
import '../../data/repositories/formation_repository.dart';
import '../widgets/formation_card.dart';
import 'add_edit_formation_page.dart';

class FormationListPage extends StatelessWidget {
  const FormationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FormationRepository.instance;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Gestion des Formations')),
      body: StreamBuilder<List<FormationModel>>(
        stream: repository.getFormations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final formations = snapshot.data ?? [];
          if (formations.isEmpty) {
            return const Center(child: Text('Aucune formation enregistrée.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: formations.length,
            itemBuilder: (context, index) {
              final formation = formations[index];
              return FormationCard(
                formation: formation,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditFormationPage(existing: formation),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await confirmSoftDelete(context, formation.name);
                  if (confirmed) {
                    await repository.softDeleteFormation(formation.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Formation "${formation.name}" supprimée.')),
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
          MaterialPageRoute(builder: (_) => const AddEditFormationPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
