import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injector.dart';

/// Menu commun utilisé par les écrans métier et d'administration.
/// Le rôle est récupéré depuis la session AuthProvider déjà partagée par
/// l'application ; aucun nouvel appel Firestore n'est nécessaire ici.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  bool get _isAdmin =>
      (Injector.authProvider.user?.role ?? 'student').toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final user = Injector.authProvider.user;
    final isAdmin = _isAdmin;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.name.isNotEmpty == true ? user!.name : 'Utilisateur',
              ),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            _item(context, Icons.home_outlined, 'Accueil', '/home'),
            const Divider(),
            ExpansionTile(
              leading: const Icon(Icons.route_outlined),
              title: const Text('Trajet'),
              children: [
                _subItem(
                  context,
                  Icons.add_road,
                  'Publication',
                  '/trips/publish',
                ),
                _subItem(context, Icons.search, 'Recherche', '/trips/search'),
                _subItem(
                  context,
                  Icons.history,
                  'Historique',
                  '/trips/history',
                ),
                _subItem(context, Icons.star_outline, 'Évaluation', '/reviews'),
              ],
            ),
            _item(
              context,
              Icons.event_seat_outlined,
              'Reservation',
              '/bookings',
            ),
            _item(
              context,
              Icons.directions_car_outlined,
              'Véhicule',
              '/vehicles',
            ),
            _item(
              context,
              Icons.notifications_none,
              'Notification',
              '/notifications',
            ),
            _item(context, Icons.chat_bubble_outline, 'Chat', '/chat'),
            if (isAdmin) ...[
              const Divider(),
              const ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined),
                title: Text(
                  'ADMINISTRATEUR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _item(
                context,
                Icons.people_alt_outlined,
                'Gestion des users',
                '/admin/users',
              ),
              _item(
                context,
                Icons.account_balance_outlined,
                'Gestion des universities',
                '/admin/universities',
              ),
              _item(
                context,
                Icons.location_city_outlined,
                'Gestion des campus',
                '/admin/campuses',
              ),
              _item(
                context,
                Icons.school_outlined,
                'Gestion des formations',
                '/admin/formations',
              ),
              _item(
                context,
                Icons.layers_outlined,
                'Gestion des levels',
                '/admin/levels',
              ),
              _item(
                context,
                Icons.account_tree_outlined,
                'Gestion des unités de formations et de recherches (UFRs)',
                '/admin/ufrs',
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                Navigator.of(context).pop();
                await Injector.authProvider.signOut();
                if (context.mounted) context.go('/auth');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

  Widget _subItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: _item(context, icon, label, route),
    );
  }
}
