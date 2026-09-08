import 'package:connectivity_plus/connectivity_plus.dart';

/// Politique de nouvelle tentative pour les opérations Firestore.
///
/// Une simple erreur de timeout (réseau mobile instable, micro-coupure) ne
/// doit pas se traduire immédiatement par un écran d'erreur définitif pour
/// l'utilisateur. Ce helper réessaie automatiquement l'opération avec un
/// délai croissant (backoff), et — quand c'est possible de le détecter —
/// attend le retour du réseau plutôt que de retenter dans le vide.
///
/// Ceci absorbe les micro-coupures typiques d'une connexion mobile (APK),
/// mais ne peut pas corriger un problème de fond côté Firebase (base
/// Firestore non créée, règles de sécurité qui bloquent l'accès, clé API
/// mal restreinte) : voir DEPANNAGE_FIRESTORE.md pour ces cas-là.
class FirestoreRetry {
  FirestoreRetry._();

  static const List<Duration> _defaultBackoff = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
  ];

  /// Exécute [action] (un appel ponctuel : create/update/delete) et
  /// réessaie automatiquement en cas d'échec, jusqu'à [maxAttempts]
  /// tentatives au total.
  static Future<T> run<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
  }) async {
    assert(maxAttempts >= 1);
    for (var attempt = 0; ; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (attempt >= maxAttempts - 1) rethrow;
        await _waitForConnectionOrDelay(_delayFor(attempt));
      }
    }
  }

  /// Version "stream" : réabonne automatiquement [createStream] en cas
  /// d'erreur (timeout, coupure réseau), au lieu de laisser la première
  /// erreur remonter telle quelle jusqu'à l'UI. Utile pour les
  /// `snapshots()` Firestore affichés en direct dans une liste.
  static Stream<T> runStream<T>(
    Stream<T> Function() createStream, {
    int maxAttempts = 5,
  }) async* {
    assert(maxAttempts >= 1);
    for (var attempt = 0; ; attempt++) {
      try {
        yield* createStream();
        return; // Le flux s'est terminé normalement (rare pour snapshots()).
      } catch (e) {
        if (attempt >= maxAttempts - 1) rethrow;
        await _waitForConnectionOrDelay(_delayFor(attempt));
      }
    }
  }

  static Duration _delayFor(int attempt) =>
      _defaultBackoff[attempt.clamp(0, _defaultBackoff.length - 1)];

  static Future<void> _waitForConnectionOrDelay(Duration delay) async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        // Hors-ligne : on attend le retour du réseau plutôt que de
        // consommer une tentative pour rien (jusqu'à 3x le délai prévu,
        // au-delà on retente quand même au cas où la détection soit en
        // défaut sur cette plateforme).
        await Connectivity()
            .onConnectivityChanged
            .firstWhere((r) => !r.contains(ConnectivityResult.none))
            .timeout(delay * 3, onTimeout: () => <ConnectivityResult>[]);
        return;
      }
    } catch (_) {
      // connectivity_plus indisponible sur cette plateforme (ex: certains
      // environnements web/desktop) : on retombe sur le délai fixe.
    }
    await Future.delayed(delay);
  }
}
