import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'admin_dashboard_screen.dart';

class AppDashboardScreen extends StatelessWidget {
  final AuthProvider authProvider;
  const AppDashboardScreen({super.key, required this.authProvider});

  bool get isAdmin =>
      (authProvider.user?.role ?? 'student').toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final user = authProvider.user;

    if (isAdmin) {
      return Scaffold(
        drawer: _AdminDrawer(authProvider: authProvider),
        appBar: AppBar(
          title: const Text(
            'Tableau de bord',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Compte',
              onSelected: (value) async {
                if (value == 'logout') {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(authProvider: authProvider),
                      ),
                      (_) => false,
                    );
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 18),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: AdminDashboardBody(userName: user?.name ?? ''),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarPool Lite'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(authProvider: authProvider),
                  ),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: _AppDrawer(authProvider: authProvider, isAdmin: false),
      body: _HomeBody(userName: user?.name ?? '', isAdmin: false),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour ${userName.isEmpty ? '!' : userName}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Centre de pilotage de la plateforme.'
                : 'Bienvenue sur votre espace étudiant.',
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 125,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: cards.length,
            itemBuilder: (_, i) => Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go(cards[i][2] as String),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(cards[i][1] as IconData, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          cards[i][0] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final AuthProvider authProvider;
  const _AdminDrawer({required this.authProvider});

  static const _kBrandBlue = Color(0xFF2952E3);
  static const _kBrandGreen = Color(0xFF10B981);
  static const _kBrandRed = Color(0xFFEF4444);

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    context.push(route);
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: Colors.grey.shade800, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: trailing,
      onTap: () => _go(context, route),
    );
  }

  Widget _addItem(BuildContext context, String label, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: const Icon(
        Icons.add_circle_outline,
        color: _kBrandGreen,
        size: 22,
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: () => _go(context, route),
    );
  }

  Widget _activeItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Material(
        color: _kBrandBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _go(context, '/home'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: _kBrandBlue),
                SizedBox(width: 16),
                Text(
                  'Tableau de bord',
                  style: TextStyle(
                    color: _kBrandBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kBrandBlue, Color(0xFFF3DFA8)],
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Image.asset(
                'assets/images/logo_carpoollite.png',
                height: 96,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _activeItem(context),
                  _sectionLabel('GESTION'),
                  _menuItem(
                    context,
                    icon: Icons.directions_bus_filled_outlined,
                    label: 'Classes',
                    route: '/admin/levels',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.domain_outlined,
                    label: 'Unités de formation et de recherche (UFRs)',
                    route: '/admin/ufrs',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.grid_view_outlined,
                    label: 'Formations',
                    route: '/admin/formations',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.account_balance_outlined,
                    label: 'Universités',
                    route: '/admin/universities',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.location_city_outlined,
                    label: 'Campus',
                    route: '/admin/campuses',
                  ),
                  _sectionLabel('AJOUTER'),
                  _addItem(context, 'Ajouter une classe', '/admin/levels'),
                  _addItem(
                    context,
                    'Ajouter une formation',
                    '/admin/formations',
                  ),
                  _addItem(
                    context,
                    'Ajouter une université',
                    '/admin/universities',
                  ),
                  _sectionLabel('UTILISATEURS & CONTENU'),
                  _menuItem(
                    context,
                    icon: Icons.people_outline,
                    label: 'Utilisateurs',
                    route: '/admin/users',
                    trailing: _UserCountBadge(builder: _countBadge),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.directions_car_outlined,
                    label: 'Trajets',
                    route: '/trips',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    route: '/chat',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    route: '/notifications',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.warning_amber_rounded,
                    label: 'Signalements',
                    route: '/admin/reports',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.block_outlined,
                    label: 'Liste noire',
                    route: '/admin/blacklist',
                  ),
                  _sectionLabel('PARAMÈTRES'),
                  _menuItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Paramètres Généraux',
                    route: '/admin/settings',
                  ),
                  _menuItem(
                    context,
                    icon: Icons.history,
                    label: 'Logs / Historique',
                    route: '/admin/logs',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
              leading: const Icon(Icons.logout, color: _kBrandRed),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: _kBrandRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(authProvider: authProvider),
                    ),
                    (_) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Badge affichant le nombre total d'utilisateurs inscrits (comptage
/// Firestore agrégé, léger — ne télécharge pas la liste complète).
/// Les badges "Messages" et "Signalements" du visuel d'origine ne sont pas
/// reproduits ici : aucune fonctionnalité de messagerie ni de signalement
/// n'existe encore dans le projet pour en calculer un nombre réel.
class _UserCountBadge extends StatelessWidget {
  final Widget Function(String text, Color color) builder;
  const _UserCountBadge({required this.builder});

  String _format(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').count().get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.count == null) {
          return const SizedBox.shrink();
        }
        return builder(_format(snapshot.data!.count!), const Color(0xFF111827));
      },
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

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _go(context, route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.name ?? 'Utilisateur'),
              accountEmail: Text(authProvider.user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
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
            _item(
              context,
              Icons.notifications,
              'Notification',
              '/notifications',
            ),
            _item(context, Icons.chat, 'Chat', '/chat'),
            _item(context, Icons.bar_chart, 'Mes statistiques', '/statistics'),
            if (isAdmin) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'ADMINISTRATEUR',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _item(
                context,
                Icons.people_alt,
                'Gestion des users',
                '/admin/users',
              ),
              _item(
                context,
                Icons.account_balance,
                'Gestion des universities',
                '/admin/universities',
              ),
              _item(
                context,
                Icons.location_city,
                'Gestion des campus',
                '/admin/campuses',
              ),
              _item(
                context,
                Icons.school,
                'Gestion des formations',
                '/admin/formations',
              ),
              _item(
                context,
                Icons.layers,
                'Gestion des levels',
                '/admin/levels',
              ),
              _item(
                context,
                Icons.account_tree_outlined,
                'Gestion des unités de formations et de recherches (UFRs)',
                '/admin/ufrs',
              ),
              _item(
                context,
                Icons.leaderboard,
                'Statistiques université',
                '/admin/statistics',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
