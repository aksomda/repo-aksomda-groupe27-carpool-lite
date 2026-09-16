import 'package:flutter/foundation.dart';

/// Représentation "propre" d'une erreur, pensée pour être affichée à
/// l'utilisateur (contrairement aux [Exception], qui sont un détail
/// d'implémentation de la couche données).
@immutable
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message);

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Une erreur de cache est survenue.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Aucune connexion Internet disponible.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Vous n\'êtes pas autorisé à effectuer cette action.',
  ]);
}

/// Transforme n'importe quelle erreur capturée dans un `catch` en un
/// message lisible, en retirant le préfixe `Exception: ` ajouté
/// automatiquement par Dart lorsqu'on fait `throw Exception('...')`.
String messageFromError(Object error) {
  final message = error.toString();
  const prefix = 'Exception: ';

  if (message.startsWith(prefix)) {
    return message.substring(prefix.length);
  }

  return message;
}
