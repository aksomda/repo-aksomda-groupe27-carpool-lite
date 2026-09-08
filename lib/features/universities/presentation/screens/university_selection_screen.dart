import 'package:flutter/material.dart';
import '../providers/university_provider.dart';
import '../widgets/university_card.dart';

class UniversitySelectionScreen extends StatelessWidget {
  const UniversitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UniversityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choisis ton université')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.universities.isEmpty) {
            return const Center(child: Text('Aucune université enregistrée.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.universities.length,
            itemBuilder: (context, i) {
              final uni = provider.universities[i];
              return UniversityCard(
                university: uni,
                onTap: () => Navigator.of(context).pop(uni),
              );
            },
          );
        },
      ),
    );
  }
}