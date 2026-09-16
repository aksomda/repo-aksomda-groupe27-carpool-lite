import 'dart:math' as math;

/// Résultat d'une estimation d'itinéraire entre deux points.
class RouteEstimate {
  /// Distance à vol d'oiseau corrigée, en kilomètres.
  final double distanceKm;

  /// Durée de trajet estimée.
  final Duration duration;

  const RouteEstimate({
    required this.distanceKm,
    required this.duration,
  });

  /// Ex. « 42 km ».
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(distanceKm < 10 ? 1 : 0)} km';
  }

  /// Ex. « 1 h 05 » ou « 45 min ».
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) return '$minutes min';

    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }
}

/// Calculs d'itinéraire entre deux positions géographiques.
///
/// Volontairement sans appel réseau : le projet ne dépend d'aucun client
/// HTTP, et l'API Directions de Google est payante et nécessite une clé.
/// Les valeurs produites ici sont des **estimations** suffisantes pour
/// afficher une distance et une durée indicatives sur les cartes de
/// trajet. Si un jour une vraie API est branchée, seule l'implémentation
/// de [estimateRoute] est à remplacer : les écrans n'en sauront rien.
class MapsApiClient {
  MapsApiClient._();

  static const double _earthRadiusKm = 6371;

  /// Facteur de détour : la route réelle est toujours plus longue que la
  /// ligne droite. 1,3 est l'ordre de grandeur usuel en milieu routier.
  static const double _detourFactor = 1.3;

  /// Vitesse moyenne retenue, en km/h, trajets urbains et interurbains
  /// confondus.
  static const double _averageSpeedKmh = 45;

  /// Distance orthodromique (à vol d'oiseau) en kilomètres.
  static double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final deltaLatitude = _toRadians(endLatitude - startLatitude);
    final deltaLongitude = _toRadians(endLongitude - startLongitude);

    final a = math.pow(math.sin(deltaLatitude / 2), 2) +
        math.cos(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.pow(math.sin(deltaLongitude / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Estime la distance routière et la durée d'un trajet.
  ///
  /// Retourne `null` si l'une des coordonnées est absente ou nulle
  /// (cas des trajets enregistrés sans position sur la carte).
  static RouteEstimate? estimateRoute({
    required double? startLatitude,
    required double? startLongitude,
    required double? endLatitude,
    required double? endLongitude,
  }) {
    if (startLatitude == null ||
        startLongitude == null ||
        endLatitude == null ||
        endLongitude == null) {
      return null;
    }

    // (0, 0) correspond à une position non renseignée dans Firestore,
    // pas à un point réel exploitable ici.
    if (startLatitude == 0 && startLongitude == 0) return null;
    if (endLatitude == 0 && endLongitude == 0) return null;

    final straightLine = distanceBetween(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );

    final roadDistance = straightLine * _detourFactor;

    final minutes = (roadDistance / _averageSpeedKmh * 60).round();

    return RouteEstimate(
      distanceKm: roadDistance,
      duration: Duration(minutes: math.max(minutes, 1)),
    );
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
