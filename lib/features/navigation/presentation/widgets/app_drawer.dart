import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';

/// Menu latéral (Drawer) commun à tout l'espace étudiant ET à l'espace
/// administrateur (section ADMINISTRATEUR affichée conditionnellement).
///
/// Fichier canonique unique : avant, deux Drawer distincts coexistaient
/// (un pour l'accueil étudiant, un pour les pages admin/véhicules/trajets)
/// à la suite de la fusion des codes des différents contributeurs. Celui-ci
/// reprend l'identité visuelle (logo, en-tête coloré) et regroupe toutes
/// les sections des deux anciens menus.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _kBrandBlue = Color(0xFF1A56DB);
  static const _kBrandRed = Color(0xFFEF4444);

  bool get _isAdmin =>
      (Injector.authProvider.user?.role ?? 'student').toLowerCase() == 'admin';

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
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
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: Colors.grey.shade800, size: 22),
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
                  'Accueil',
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

  Future<void> _signOut(BuildContext context) async {
    Navigator.pop(context);
    await Injector.authProvider.signOut();
    if (context.mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = Injector.authProvider.user;
    final isAdmin = _isAdmin;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==========================================================
            // LOGO CARPOOL LITE
            // ==========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              color: Colors.white,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/menu_carpoollite_logo.png',
                  width: 250,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),

            // ==========================================================
            // EN-TÊTE UTILISATEUR
            // ==========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: const BoxDecoration(
                color: _kBrandBlue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Utilisateur',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // MENU
            // ==========================================================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _activeItem(context),

                  _sectionLabel('NAVIGATION'),

                  ExpansionTile(
                    leading: Icon(
                      Icons.route,
                      color: Colors.grey.shade800,
                      size: 22,
                    ),
                    title: const Text('Trajet', style: TextStyle(fontSize: 15)),
                    childrenPadding: const EdgeInsets.only(left: 8),
                    children: [
                      _menuItem(
                        context,
                        icon: Icons.add_road,
                        label: 'Publication',
                        route: '/trips/publish',
                      ),
                      _menuItem(
                        context,
                        icon: Icons.search,
                        label: 'Recherche',
                        route: '/trips/search',
                      ),
                      _menuItem(
                        context,
                        icon: Icons.history,
                        label: 'Historique de mes trajets',
                        route: '/trips/history',
                      ),
                      _menuItem(
                        context,
                        icon: Icons.star,
                        label: 'Évaluation d\'un trajet',
                        route: '/reviews',
                      ),
                    ],
                  ),

                  _menuItem(
                    context,
                    icon: Icons.event_seat,
                    label: 'Demandes de réservation',
                    route: '/bookings',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.directions_car,
                    label: 'Véhicules',
                    route: '/vehicles',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.notifications,
                    label: 'Notifications',
                    route: '/notifications',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.chat,
                    label: 'Messages',
                    route: '/chat',
                  ),

                  _menuItem(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Statistiques',
                    route: '/statistics',
                  ),

                  _sectionLabel('COMPTE'),

                  _menuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    label: 'Profil',
                    route: '/profile',
                  ),

                  if (isAdmin) ...[
                    _sectionLabel('ADMINISTRATEUR'),

                    _menuItem(
                      context,
                      icon: Icons.people_alt_outlined,
                      label: 'Gestion des utilisateurs',
                      route: '/admin/users',
                    ),
                    _menuItem(
                      context,
                      icon: Icons.account_balance_outlined,
                      label: 'Gestion des universités',
                      route: '/admin/universities',
                    ),
                    _menuItem(
                      context,
                      icon: Icons.location_city_outlined,
                      label: 'Gestion des campus',
                      route: '/admin/campuses',
                    ),
                    _menuItem(
                      context,
                      icon: Icons.school_outlined,
                      label: 'Gestion des formations',
                      route: '/admin/formations',
                    ),
                    _menuItem(
                      context,
                      icon: Icons.layers_outlined,
                      label: 'Gestion des niveaux',
                      route: '/admin/levels',
                    ),
                    _menuItem(
                      context,
                      icon: Icons.account_tree_outlined,
                      label: 'Gestion des UFR',
                      route: '/admin/ufrs',
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ==========================================================
            // DÉCONNEXION
            // ==========================================================
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
              onTap: () => _signOut(context),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
