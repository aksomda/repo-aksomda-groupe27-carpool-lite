/// Indique si Firebase a pu être initialisé avec succès au démarrage.
///
/// Sans fichier `firebase_options.dart` (généré par `flutterfire configure`)
/// ou sans `google-services.json` / `GoogleService-Info.plist`, l'appel à
/// `Firebase.initializeApp()` échoue, en particulier sur Flutter Web.
///
/// Ce flag permet aux repositories de basculer automatiquement vers une
/// source de données locale (en mémoire) lorsque Firebase n'est pas
/// disponible, afin que l'application reste testable graphiquement.
class FirebaseStatus {
  FirebaseStatus._();

  static bool available = false;
}
