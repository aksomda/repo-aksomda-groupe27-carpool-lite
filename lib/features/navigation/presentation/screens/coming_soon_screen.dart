import 'package:flutter/material.dart';

/// Écran générique "à venir", utilisé pour les liens du menu admin dont la
/// fonctionnalité n'est pas encore développée (signalements, liste noire,
/// paramètres, logs). Évite un lien mort tout en restant honnête sur l'état
/// d'avancement.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('$title — module à venir', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
