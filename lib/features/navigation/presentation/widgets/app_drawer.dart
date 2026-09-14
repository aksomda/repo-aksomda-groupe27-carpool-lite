import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Menu latéral (Drawer) de l'espace étudiant.
///
/// Reprend l'identité visuelle du menu administrateur.
/// Le logo CarPool Lite est affiché en haut du Drawer,
/// avant les informations de l'utilisateur.
class AppDrawer extends StatelessWidget {
  final AuthProvider authProvider;

  const AppDrawer({super.key, required this.authProvider});

  static const _kBrandBlue = Color(0xFF1A56DB);
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

  @override
  Widget build(BuildContext context) {
    final user = authProvider.user;

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
