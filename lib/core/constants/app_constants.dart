/// Constantes générales de l'application.
class AppConstants {
  AppConstants._();

  static const String appName = 'CarPool Lite';

  /// Devise utilisée pour l'affichage des prix des trajets.
  static const String currency = 'FCFA';

  // ============================================================
  // RÔLES
  // ============================================================

  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // ============================================================
  // TRAJETS ET RÉSERVATIONS
  // ============================================================

  /// Nombre maximal de places proposables dans un trajet.
  static const int maxSeatsPerTrip = 8;

  /// Nombre maximal de places réservables en une fois par un passager.
  static const int maxSeatsPerBooking = 4;

  /// Nombre maximal de véhicules qu'un conducteur peut enregistrer.
  static const int maxVehiclesPerUser = 5;

  // ============================================================
  // ÉVALUATIONS
  // ============================================================

  static const int minRating = 1;
  static const int maxRating = 5;

  /// Longueur maximale du commentaire d'un avis.
  static const int maxReviewLength = 500;
}
