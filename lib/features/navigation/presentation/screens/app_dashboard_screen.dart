
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class AppDashboardScreen extends StatelessWidget {
  final AuthProvider authProvider;
  const AppDashboardScreen({super.key, required this.authProvider});

  bool get isAdmin => (authProvider.user?.role ?? 'student').toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'CarPool Lite — Administration' : 'CarPool Lite'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen(authProvider: authProvider)),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: _AppDrawer(authProvider: authProvider, isAdmin: isAdmin),
      body: _HomeBody(userName: user?.name ?? '', isAdmin: isAdmin),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final String userName;
  final bool isAdmin;
  const _HomeBody({required this.userName, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final cards = isAdmin
        ? const [
            ['Utilisateurs', Icons.people_alt, '/admin/users'],
            ['Universités', Icons.account_balance, '/admin/universities'],
            ['Campus', Icons.location_city, '/admin/campuses'],
            ['Formations', Icons.school, '/admin/formations'],
            ['Levels', Icons.layers, '/admin/levels'],
          ]
        : const [
            ['Rechercher un trajet', Icons.search, '/trips/search'],
            ['Publier un trajet', Icons.add_road, '/trips/publish'],
            ['Mes réservations', Icons.event_seat, '/bookings'],
            ['Mes véhicules', Icons.directions_car, '/vehicles'],
            ['Notifications', Icons.notifications, '/notifications'],
            ['Chat', Icons.chat, '/chat'],
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonjour ${userName.isEmpty ? '!' : userName}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(isAdmin ? 'Centre de pilotage de la plateforme.' : 'Bienvenue sur votre espace étudiant.'),
        const SizedBox(height: 28),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280, mainAxisExtent: 125, crossAxisSpacing: 16, mainAxisSpacing: 16,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(cards[i][2] as String),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Icon(cards[i][1] as IconData, size: 34),
                  const SizedBox(width: 14),
                  Expanded(child: Text(cards[i][0] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AuthProvider authProvider;
  final bool isAdmin;
  const _AppDrawer({required this.authProvider, required this.isAdmin});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    context.push(route);
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: () => _go(context, route));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(children: [
          UserAccountsDrawerHeader(
            accountName: Text(authProvider.user?.name ?? 'Utilisateur'),
            accountEmail: Text(authProvider.user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
          ),
          _item(context, Icons.home, 'Accueil', '/home'),
          ExpansionTile(
            leading: const Icon(Icons.route),
            title: const Text('Trajet'),
            children: [
              _item(context, Icons.add_road, 'Publication', '/trips/publish'),
              _item(context, Icons.search, 'Recherche', '/trips/search'),
              _item(context, Icons.history, 'Historique', '/trips/history'),
              _item(context, Icons.star, 'Évaluation', '/reviews'),
            ],
          ),
          _item(context, Icons.event_seat, 'Reservation', '/bookings'),
          _item(context, Icons.directions_car, 'Véhicule', '/vehicles'),
          _item(context, Icons.notifications, 'Notification', '/notifications'),
          _item(context, Icons.chat, 'Chat', '/chat'),
          if (isAdmin) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('ADMINISTRATEUR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _item(context, Icons.people_alt, 'Gestion des users', '/admin/users'),
            _item(context, Icons.account_balance, 'Gestion des universities', '/admin/universities'),
            _item(context, Icons.location_city, 'Gestion des campus', '/admin/campuses'),
            _item(context, Icons.school, 'Gestion des formations', '/admin/formations'),
            _item(context, Icons.layers, 'Gestion des levels', '/admin/levels'),
          ],
        ]),
      ),
    );
  }
}
