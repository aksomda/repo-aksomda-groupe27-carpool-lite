import 'package:flutter/material.dart';

/// Palette de couleurs centralisée de CarPool Lite.
///
/// Les valeurs ci-dessous sont extraites directement du logo et de l'écran
/// de démarrage (assets/images/logo_carpoollite.png,
/// assets/splash/splash_screen.png) afin que TOUT l'écosystème de l'app
/// (thème clair, boutons, champs, cartes de trajet, badges de note, etc.)
/// reste cohérent avec la maquette validée par le groupe.
///
/// Ne pas coder de couleurs "en dur" ailleurs dans le code : passer par
/// [AppColors] pour que la charte reste modifiable à un seul endroit.
class AppColors {
  AppColors._();

  // ==========================================================
  // COULEURS DE MARQUE (logo / écran de démarrage)
  // ==========================================================

  /// Bleu principal de la voiture du logo — couleur de marque n°1.
  /// Utilisé pour l'AppBar, les boutons principaux, les liens actifs.
  static const Color primary = Color(0xFF0A4DD6);

  /// Variante plus foncée du bleu principal (états pressés / dégradés).
  static const Color primaryDark = Color(0xFF0038A8);

  /// Bleu marine utilisé pour le texte "CarPool" du logo.
  /// Sert pour les titres et le texte fort sur fond clair.
  static const Color navy = Color(0xFF0B2A6B);

  /// Bleu clair utilisé pour les silhouettes des passagers du logo.
  /// Sert pour les icônes secondaires, badges et petits accents.
  static const Color lightBlue = Color(0xFF5AA9F5);

  /// Jaune/orangé de la route du logo — couleur d'accent n°2.
  /// Utilisé avec parcimonie : étoiles de notation, badges "prix", accents.
  static const Color accentYellow = Color(0xFFFFB800);

  /// Violet du bouton d'action flottant (+) de la maquette (barre du bas).
  static const Color accentPurple = Color(0xFF6C5DD3);

  // ==========================================================
  // NEUTRES / SURFACES
  // ==========================================================

  /// Fond général de l'application (gris très clair, cf. écran de connexion).
  static const Color background = Color(0xFFF5F7FB);

  /// Fond des cartes / feuilles blanches (résultats de recherche, profil...).
  static const Color surface = Colors.white;

  /// Fond des champs de saisie (ex. "Départ", "Arrivée" sur l'accueil).
  static const Color inputFill = Color(0xFFF1F3F8);

  /// Bordures discrètes (cartes, séparateurs, champs non focus).
  static const Color border = Color(0xFFE3E7F0);

  // ==========================================================
  // TEXTE
  // ==========================================================

  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Colors.white;

  // ==========================================================
  // ÉTATS / SÉMANTIQUE
  // ==========================================================

  /// Succès (ex. "Arrivée à destination", trajet confirmé).
  static const Color success = Color(0xFF22C55E);

  /// Erreur / alertes.
  static const Color error = Color(0xFFE23744);

  /// Note moyenne (étoile), même teinte que l'accent jaune de la route.
  static const Color rating = accentYellow;
}