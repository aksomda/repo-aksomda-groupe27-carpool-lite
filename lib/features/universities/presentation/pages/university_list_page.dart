import 'package:flutter/material.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/university_model.dart';
import '../../data/repositories/university_repository.dart';
import '../widgets/university_card.dart';
import 'add_edit_university_page.dart';
import 'university_detail_page.dart';

/// Écran principal de la gestion des universités : affiche la liste des
/// universités enregistrées et permet d'en ajouter une nouvelle.
class UniversityListPage extends StatelessWidget {
  const UniversityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = UniversityRepository.instance;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Gestion des Universités'),
        bottom: repository.isUsingFirestore
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: const Text(
                    'Mode hors-ligne : Firebase non configuré, données locales temporaires.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
      ),
      body: StreamBuilder<List<UniversityModel>>(
        stream: repository.getUniversities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Erreur lors du chargement des universités :\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final universities = snapshot.data ?? [];

          if (universities.isEmpty) {
            return const Center(
              child: Text('Aucune université enregistrée pour le moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: universities.length,
            itemBuilder: (context, index) {
              final university = universities[index];
              return UniversityCard(
                university: university,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UniversityDetailPage(university: university),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditUniversityPage(existing: university),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditUniversityPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
