import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Menu latéral simple pour naviguer entre les modules déjà implémentés,
/// utile pour les tests graphiques manuels.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Carpool Lite\nGestion académique des étudiants',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Universités'),
            onTap: () => context.go('/universities'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('UFRs'),
            onTap: () => context.go('/ufrs'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Formations'),
            onTap: () => context.go('/formations'),
          ),
          ListTile(
            leading: const Icon(Icons.stairs),
            title: const Text('Niveaux / Classes'),
            onTap: () => context.go('/levels'),
          ),
        ],
      ),
    );
  }
}
