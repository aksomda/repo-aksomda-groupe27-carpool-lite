/// Exceptions génériques levées par les sources de données (datasources).
///
/// Ces classes normalisent les erreurs techniques (réseau, serveur, cache)
/// afin que les repositories puissent les intercepter et les transformer,
/// si besoin, en [Failure] exploitables par la couche présentation.
library;

/// Erreur provenant d'un service distant (Firestore, API HTTP, etc.).
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Une erreur serveur est survenue.']);

  @override
  String toString() => message;
}

/// Erreur provenant du stockage local (cache, mode hors-ligne).
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Une erreur de cache est survenue.']);

  @override
  String toString() => message;
}

/// Erreur liée à l'absence ou à l'instabilité de la connexion réseau.
class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message = 'Aucune connexion Internet disponible.',
  ]);

  @override
  String toString() => message;
}

/// Erreur de validation des données saisies par l'utilisateur, avant
/// même l'appel à une source de données.
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => message;
}

/// Erreur levée lorsqu'un utilisateur tente une action pour laquelle il
/// n'est pas autorisé (ex. modifier une ressource qui ne lui appartient pas).
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([
    this.message = 'Vous n\'êtes pas autorisé à effectuer cette action.',
  ]);

  @override
  String toString() => message;
}
