import 'package:flutter/material.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/ufr_model.dart';
import '../../data/repositories/ufr_repository.dart';
import '../widgets/ufr_card.dart';
import 'add_edit_ufr_page.dart';

class UfrListPage extends StatelessWidget {
  const UfrListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = UfrRepository.instance;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Gestion des unités de formations et de recherches (UFRs)',
        ),
      ),
      body: StreamBuilder<List<UfrModel>>(
        stream: repository.getUfrs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final ufrs = snapshot.data ?? [];
          if (ufrs.isEmpty) {
            return const Center(child: Text('Aucune UFR enregistrée.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: ufrs.length,
            itemBuilder: (context, index) {
              final ufr = ufrs[index];
              return UfrCard(
                ufr: ufr,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditUfrPage(existing: ufr),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await confirmSoftDelete(context, ufr.name);
                  if (confirmed) {
                    await repository.softDeleteUfr(ufr.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('UFR "${ufr.name}" supprimée.')),
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
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEditUfrPage())),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
