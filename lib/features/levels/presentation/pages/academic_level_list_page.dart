import 'package:flutter/material.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/academic_level_model.dart';
import '../../data/repositories/academic_level_repository.dart';
import '../widgets/academic_level_card.dart';
import 'add_edit_academic_level_page.dart';

class AcademicLevelListPage extends StatelessWidget {
  const AcademicLevelListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AcademicLevelRepository.instance;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Gestion des Niveaux / Classes')),
      body: StreamBuilder<List<AcademicLevelModel>>(
        stream: repository.getLevels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final levels = snapshot.data ?? [];
          if (levels.isEmpty) {
            return const Center(child: Text('Aucun niveau/classe enregistré.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return AcademicLevelCard(
                level: level,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditAcademicLevelPage(existing: level),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await confirmSoftDelete(context, level.name);
                  if (confirmed) {
                    await repository.softDeleteLevel(level.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Niveau "${level.name}" supprimé.')),
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
          MaterialPageRoute(builder: (_) => const AddEditAcademicLevelPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
