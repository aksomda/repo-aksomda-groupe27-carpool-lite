/// Noms des collections Firestore utilisées par l'application.
///
/// Centraliser ces chaînes évite les fautes de frappe silencieuses
/// (`'universites'` au lieu de `'universities'` renvoie simplement une
/// collection vide, sans erreur) et permet de retrouver d'un coup d'œil
/// toutes les collections du projet.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String students = 'students';
  static const String devices = 'devices';

  static const String universities = 'universities';
  static const String campus = 'campus';
  static const String ufrs = 'ufrs';
  static const String formations = 'formations';
  static const String academicLevels = 'academic_levels';

  static const String trips = 'trips';
  static const String bookings = 'bookings';
  static const String rideRequests = 'rideRequests';
  static const String vehicles = 'vehicles';
  static const String favorites = 'favorites';

  static const String reviews = 'reviews';
  static const String reports = 'reports';
  static const String notifications = 'notifications';
  static const String messages = 'messages';
}
