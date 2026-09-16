import 'dart:convert';

import 'package:http/http.dart' as http;

class GoogleMapsDataSource {
  GoogleMapsDataSource({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  static final Uri _routesUri = Uri.parse(
    'https://routes.googleapis.com/directions/v2:computeRoutes',
  );

  Future<Map<String, dynamic>> getRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé Google Routes API manquante.',
      );
    }

    final response = await _client.post(
      _routesUri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
        'routes.distanceMeters,'
            'routes.duration,'
            'routes.polyline.encodedPolyline',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': originLatitude,
              'longitude': originLongitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destinationLatitude,
              'longitude': destinationLongitude,
            },
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'languageCode': 'fr-FR',
        'units': 'METRIC',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Google Routes API '
            '${response.statusCode}: '
            '${response.body}',
      );
    }

    final data =
    jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Réponse Google Routes API invalide.',
      );
    }

    return data;
  }

  void dispose() {
    _client.close();
  }
}