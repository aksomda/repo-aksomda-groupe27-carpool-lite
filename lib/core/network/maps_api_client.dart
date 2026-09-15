// Client HTTP dédié UNIQUEMENT à l'API de cartes Google (calcul de
// distance entre le lieu de départ et le lieu d'arrivée d'un trajet).
// Ne pas utiliser pour Firestore.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Clé API Google Maps (Distance Matrix API), fournie **au moment de la
/// compilation**, jamais écrite dans le code source.
///
/// Contrairement aux clés Firebase (publiques par conception, protégées par
/// les règles de sécurité), une clé Google Maps est facturée à l'usage :
/// commitée dans un dépôt, elle est immédiatement exploitable par un tiers.
///
/// Utilisation :
/// ```bash
/// flutter run   --dart-define=GOOGLE_MAPS_API_KEY=votre_cle
/// flutter build --dart-define=GOOGLE_MAPS_API_KEY=votre_cle
/// ```
/// Pensez aussi à restreindre la clé dans la console Google Cloud
/// (API et services > Identifiants > Restrictions d'application) et à
/// n'y activer que « Distance Matrix API ».
const String kGoogleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
);

/// Résultat du calcul de distance/durée entre deux lieux.
class DistanceResult {
  final double distanceKm;
  final String distanceText;
  final String durationText;

  const DistanceResult({
    required this.distanceKm,
    required this.distanceText,
    required this.durationText,
  });
}

/// Client pour la fonction Google "Distance Matrix", utilisée pour calculer
/// automatiquement la distance d'un trajet à partir du lieu de départ et
/// du lieu d'arrivée saisis par le conducteur.
class MapsApiClient {
  final http.Client _client;
  final String apiKey;

  MapsApiClient({http.Client? client, this.apiKey = kGoogleMapsApiKey})
    : _client = client ?? http.Client();

  /// Calcule la distance routière entre [origin] et [destination] (noms de
  /// lieux ou adresses en texte libre : la Distance Matrix API se charge
  /// elle-même du géocodage).
  ///
  /// Lève une [Exception] avec un message lisible si l'appel échoue ou si
  /// aucun itinéraire n'a pu être trouvé.
  Future<DistanceResult> getDistance({
    required String origin,
    required String destination,
  }) async {
    if (apiKey.isEmpty || apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      throw Exception(
        "Clé API Google Maps non configurée. Relancez l'application avec "
        "--dart-define=GOOGLE_MAPS_API_KEY=votre_cle.",
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/distancematrix/json',
      {
        'origins': origin,
        'destinations': destination,
        'units': 'metric',
        'key': apiKey,
      },
    );

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception(
        'Délai dépassé en contactant le service de calcul de distance.',
      );
    } catch (e) {
      throw Exception(
        'Impossible de contacter le service de calcul de distance : $e',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Le service de calcul de distance a répondu avec une erreur '
        '(${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String?;
    if (status != 'OK') {
      throw Exception(
        "Impossible de calculer la distance (statut : ${status ?? 'inconnu'}). "
        "Vérifiez le lieu de départ et le lieu d'arrivée saisis.",
      );
    }

    final rows = body['rows'] as List<dynamic>? ?? [];
    if (rows.isEmpty) {
      throw Exception('Aucun itinéraire trouvé entre ces deux lieux.');
    }
    final elements = rows.first['elements'] as List<dynamic>? ?? [];
    if (elements.isEmpty) {
      throw Exception('Aucun itinéraire trouvé entre ces deux lieux.');
    }
    final element = elements.first as Map<String, dynamic>;
    final elementStatus = element['status'] as String?;
    if (elementStatus != 'OK') {
      throw Exception(
        "Aucun itinéraire trouvé entre le lieu de départ et le lieu "
        "d'arrivée saisis.",
      );
    }

    final distance = element['distance'] as Map<String, dynamic>;
    final duration = element['duration'] as Map<String, dynamic>?;
    final meters = (distance['value'] as num).toDouble();

    return DistanceResult(
      distanceKm: meters / 1000,
      distanceText: distance['text'] as String? ?? '',
      durationText: duration?['text'] as String? ?? '',
    );
  }
}
