import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/// Réessaie une opération Firestore **temporairement** indisponible.
///
/// Règle essentielle : seules les pannes passagères (réseau coupé, backend
/// momentanément indisponible) justifient un retry. Une erreur de
/// configuration — index composite manquant, règle de sécurité qui refuse
/// la lecture — ne se corrigera jamais toute seule : la retenter en boucle
/// ne fait que masquer le vrai message d'erreur derrière un spinner
/// interminable. Ces erreurs-là doivent remonter **immédiatement** à
/// l'utilisateur (et au développeur), avec le lien de création d'index que
/// Firestore fournit dans son message.
class FirestoreRetry {
  FirestoreRetry._();

  /// Codes d'erreur Firestore considérés comme passagers.
  static const Set<String> _transientCodes = {
    'unavailable',
    'deadline-exceeded',
    'internal',
    'resource-exhausted',
    'aborted',
    'cancelled',
  };

  /// Une erreur mérite-t-elle une nouvelle tentative ?
  ///
  /// Tout ce qui n'est pas explicitement passager (`permission-denied`,
  /// `failed-precondition` = index manquant, `not-found`, `invalid-argument`…)
  /// est remonté tel quel, sans attendre.
  static bool _isTransient(Object error) {
    if (error is TimeoutException) return true;
    if (error is FirebaseException) return _transientCodes.contains(error.code);
    return false;
  }

  /// Délai d'attente progressif entre deux tentatives (250 ms, 500 ms, 1 s…).
  static Duration _backoff(int attempt) =>
      Duration(milliseconds: 250 * attempt);

  /// Exécute une opération ponctuelle (lecture/écriture unique).
  static Future<T> run<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await operation();
      } catch (error) {
        if (attempt >= maxAttempts || !_isTransient(error)) rethrow;
        await Future<void>.delayed(_backoff(attempt));
      }
    }
  }

  /// Exécute un flux temps réel (`snapshots()`) en le rétablissant après une
  /// coupure passagère.
  ///
  /// On consomme le flux avec `await for` et non `yield*` : `yield*` transmet
  /// les erreurs du flux source directement à l'auditeur sans passer par le
  /// `try/catch` de ce générateur, ce qui rendait la boucle de retry
  /// inopérante.
  static Stream<T> runStream<T>(
    Stream<T> Function() operation, {
    int maxAttempts = 3,
  }) async* {
    for (var attempt = 1; ; attempt++) {
      try {
        await for (final event in operation()) {
          yield event;
        }
        return; // Flux terminé normalement.
      } catch (error) {
        if (attempt >= maxAttempts || !_isTransient(error)) rethrow;
        await Future<void>.delayed(_backoff(attempt));
      }
    }
  }
}
