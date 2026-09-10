/// État de l'initialisation Firebase, utilisé par les dépôts qui disposent
/// d'un mode local de secours.
class FirebaseStatus {
  FirebaseStatus._();

  static bool _available = false;

  static bool get available => _available;

  static void markAvailable() => _available = true;

  static void markUnavailable() => _available = false;
}
