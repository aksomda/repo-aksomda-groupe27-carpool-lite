/// Délai maximum accordé à une opération Firestore avant d'abandonner et
/// d'afficher une erreur, plutôt que de laisser l'interface (bouton
/// "Enregistrer", liste, etc.) attendre indéfiniment.
///
/// Si ce délai est régulièrement dépassé, la cause est presque toujours une
/// mauvaise configuration côté Firebase (base Firestore non créée, règles de
/// sécurité qui bloquent l'accès) plutôt qu'un bug du code Flutter — voir
/// le fichier DEPANNAGE_FIRESTORE.md à la racine du projet.
const Duration kFirestoreTimeout = Duration(seconds: 15);
