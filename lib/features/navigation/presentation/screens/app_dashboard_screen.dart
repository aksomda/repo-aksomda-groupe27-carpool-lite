import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';

/// Tableau de bord réservé aux administrateurs, atteint via la route
/// '/admin/dashboard'. Un utilisateur étudiant n'arrive jamais ici : le
/// [appRouter] redirige tout non-admin vers '/home' (voir app_router.dart).
class AdminHomeScreen extends StatelessWidget {
  final AuthProvider authProvider;
  const AdminHomeScreen({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final user = authProvider.user;

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
                  context.go('/auth');
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
                  context.go('/auth');
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
