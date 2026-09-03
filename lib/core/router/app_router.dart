import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
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
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Gestion des Universités'))),
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
