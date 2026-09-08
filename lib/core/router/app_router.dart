import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/universities/presentation/pages/add_university_page.dart';
import '../../features/universities/presentation/pages/university_list_page.dart';
import '../../features/campus/presentation/pages/campus_list_page.dart';
import '../../features/ufrs/presentation/pages/ufr_list_page.dart';
import '../../features/formations/presentation/pages/formation_list_page.dart';
import '../../features/levels/presentation/pages/academic_level_list_page.dart';

final GoRouter appRouter = GoRouter(
  // Route de démarrage temporairement pointée sur la gestion des
  // universités pour faciliter les tests graphiques de cette fonctionnalité.
  // Remettez '/auth' une fois l'écran d'authentification implémenté.
  initialLocation: '/universities',
  routes: [
    // 1. Authentification & Profil
    GoRoute(
      path: '/auth',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Écran Authentification'))),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Écran Profil & Rôles'))),
    ),

    // 2. Universités
    GoRoute(
      path: '/universities',
      builder: (context, state) => const UniversityListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddUniversityPage(),
        ),
      ],
    ),

    // 2.4 Gestion académique : Campus, UFRs, Formations, Niveaux/Classes
    GoRoute(
      path: '/campus',
      builder: (context, state) => const CampusListPage(),
    ),
    GoRoute(
      path: '/ufrs',
      builder: (context, state) => const UfrListPage(),
    ),
    GoRoute(
      path: '/formations',
      builder: (context, state) => const FormationListPage(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const AcademicLevelListPage(),
    ),

    // 3. Véhicules
    GoRoute(
      path: '/vehicles',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Gestion des Véhicules'))),
    ),

    // 4. Trajets (Recherche, Création, Itinéraire)
    GoRoute(
      path: '/trips',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Gestion des Trajets'))),
    ),

    // 5. Réservations
    GoRoute(
      path: '/bookings',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Gestion des Réservations'))),
    ),

    // 6. Chat (Messagerie)
    GoRoute(
      path: '/chat',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Chat entre utilisateurs'))),
    ),

    // 7. Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Centre de Notifications'))),
    ),

    // 8. Avis
    GoRoute(
      path: '/reviews',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Gestion des Avis & Notes'))),
    ),

    // 9. Statistiques
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Tableau de bord Statistiques')),
      ),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route introuvable : ${state.error}'))),
);
