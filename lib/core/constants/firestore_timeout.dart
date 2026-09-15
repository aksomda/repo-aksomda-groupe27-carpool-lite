/// Délai maximal d'une opération Firestore **ponctuelle** (`get`, `set`,
/// `update`, `add`) avant de remonter une erreur lisible à l'utilisateur.
///
/// ⚠️ Ne jamais appliquer ce délai à un flux `snapshots()` : `Stream.timeout`
/// se déclenche dès qu'aucun *nouvel* événement n'arrive pendant la durée
/// donnée. Or un écouteur Firestore émet l'état courant puis reste
/// silencieux tant que rien ne change — la liste serait donc coupée au bout
/// de quelques secondes d'inactivité parfaitement normale. Les flux se
/// reposent sur la gestion hors-ligne native de Firestore et sur
/// [FirestoreRetry.runStream].
const Duration kFirestoreTimeout = Duration(seconds: 20);
